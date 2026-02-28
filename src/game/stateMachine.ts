import { ABILITIES, FACTIONS, LEADERS } from '@/lib/terminology'
import type {
  Card,
  GameState,
  MatchResult,
  PlayerRow,
  PlayerState,
  RowType,
  UnitCard,
} from '@/types/game'
import { computeStrength } from './computeStrength'
import { applyFactionADraw, applyFactionDRetain, resolveRoundGems } from './factions'
import { completeAgileSelection, resolveAgile } from './resolvers/agile'
import { completeDecoySelection, resolveDecoy } from './resolvers/decoy'
import { resolveFormation } from './resolvers/formation'
import { resolveInfiltrator } from './resolvers/infiltrator'
import { completeMedicSelection, resolveMedic } from './resolvers/medic'
import type { ResolverDispatch } from './resolvers/medic'
import { resolveRally } from './resolvers/rally'
import { resolveRowScorch } from './resolvers/rowScorch'
import { resolveScorch } from './resolvers/scorch'
import {
  completeWarCrySelection,
  resolveWarCrySpecial,
  resolveWarCryUnit,
} from './resolvers/warCry'
import { resolveWeather } from './resolvers/weather'
import {
  leaderA1,
  leaderA2,
  leaderA3,
  leaderA4,
  leaderA5,
  leaderB1,
  leaderB2,
  leaderB3,
  leaderB4,
  leaderB5,
  leaderC1,
  leaderC2,
  leaderC3,
  leaderC4,
  leaderC5,
  leaderD1,
  leaderD2,
  leaderD3,
  leaderD4,
  leaderD5,
} from './leaders'
import { ROW_KEY } from './rows'

// ---- Helpers ----

function findCard(state: GameState, cardId: string, playerIndex: 0 | 1): Card | undefined {
  const player = state.players[playerIndex]
  return (
    player.hand.find((c) => c.id === cardId) ??
    player.board.melee.cards.find((c) => c.id === cardId) ??
    player.board.ranged.cards.find((c) => c.id === cardId) ??
    player.board.siege.cards.find((c) => c.id === cardId)
  )
}

function placeUnit(state: GameState, cardId: string, playerIndex: 0 | 1): GameState {
  const player = state.players[playerIndex]
  const card = player.hand.find((c) => c.id === cardId) as UnitCard | undefined
  if (!card) return state

  const hand = player.hand.filter((c) => c.id !== cardId)
  const rowKey = ROW_KEY[card.row]
  const board = {
    ...player.board,
    [rowKey]: {
      ...player.board[rowKey],
      cards: [...player.board[rowKey].cards, card],
    },
  }
  const updated: PlayerState = { ...player, hand, board }
  const players: [PlayerState, PlayerState] =
    playerIndex === 0 ? [updated, state.players[1]] : [state.players[0], updated]
  return { ...state, players }
}

// ---- Central dispatcher ----

export const dispatch: ResolverDispatch = (
  state: GameState,
  cardId: string,
  playerIndex: 0 | 1,
  rng: () => number,
): GameState => {
  const card = findCard(state, cardId, playerIndex)
  if (!card) return state

  if (card.type === 'weather') {
    return resolveWeather(state, cardId, playerIndex)
  }

  if (card.type === 'special') {
    switch (card.ability) {
      case ABILITIES.SCORCH:
        return resolveScorch(state, cardId, playerIndex)
      case ABILITIES.WAR_CRY:
        return resolveWarCrySpecial(state, cardId, playerIndex)
      case ABILITIES.DECOY:
        return resolveDecoy(state, cardId, playerIndex)
    }
  }

  // card.type === 'unit'
  const unit = card as UnitCard
  switch (unit.ability) {
    case ABILITIES.INFILTRATOR:
      return resolveInfiltrator(state, cardId, playerIndex)
    case ABILITIES.MEDIC:
      return resolveMedic(state, cardId, playerIndex, rng, dispatch)
    case ABILITIES.FORMATION:
      return resolveFormation(state, cardId, playerIndex)
    case ABILITIES.RALLY:
      return resolveRally(state, cardId, playerIndex)
    case ABILITIES.AGILE:
      return resolveAgile(state, cardId, playerIndex)
    case ABILITIES.ROW_SCORCH:
      return resolveRowScorch(state, cardId, playerIndex)
    case ABILITIES.WAR_CRY:
      return resolveWarCryUnit(state, cardId, playerIndex)
    default:
      // Hero (isHero=true), Morale Boost, null ability: plain placement
      return placeUnit(state, cardId, playerIndex)
  }
}

// ---- Turn flow ----

function advanceTurn(state: GameState, playerIndex: 0 | 1): GameState {
  // If waiting for player input, hold on active player
  if (state.selectionMode !== 'default') return state

  const opponentIndex: 0 | 1 = playerIndex === 0 ? 1 : 0
  // If opponent has passed, active player keeps going until round ends
  if (state.players[opponentIndex].passed) return state

  return { ...state, activePlayer: opponentIndex }
}

export function playCard(
  state: GameState,
  cardId: string,
  playerIndex: 0 | 1,
  rng: () => number,
): GameState {
  if (state.activePlayer !== playerIndex) return state
  if (state.players[playerIndex].passed) return state
  if (state.selectionMode !== 'default') return state

  const resolved = dispatch(state, cardId, playerIndex, rng)
  return advanceTurn(resolved, playerIndex)
}

export function pass(state: GameState, playerIndex: 0 | 1): GameState {
  if (state.activePlayer !== playerIndex) return state
  if (state.players[playerIndex].passed) return state
  if (state.selectionMode !== 'default') return state

  const player = state.players[playerIndex]
  const updated: PlayerState = { ...player, passed: true }
  const players: [PlayerState, PlayerState] =
    playerIndex === 0 ? [updated, state.players[1]] : [state.players[0], updated]
  const withPass: GameState = { ...state, players }

  const opponentIndex: 0 | 1 = playerIndex === 0 ? 1 : 0
  // Both passed — caller checks isRoundOver and calls endRound
  if (withPass.players[opponentIndex].passed) return withPass

  return { ...withPass, activePlayer: opponentIndex }
}

// ---- Selection completion ----

export type SelectionCompletion =
  | { mode: 'medic'; selectedCardId: string }
  | { mode: 'decoy'; selectedCardId: string }
  | { mode: 'agile'; row: RowType }
  | { mode: 'warCry'; row: RowType }

export function completeSelection(
  state: GameState,
  completion: SelectionCompletion,
  playerIndex: 0 | 1,
  rng: () => number,
): GameState {
  if (state.activePlayer !== playerIndex) return state

  let resolved: GameState
  switch (completion.mode) {
    case 'medic':
      resolved = completeMedicSelection(
        state,
        completion.selectedCardId,
        playerIndex,
        dispatch,
        rng,
      )
      break
    case 'decoy':
      resolved = completeDecoySelection(state, completion.selectedCardId, playerIndex)
      break
    case 'agile':
      resolved = completeAgileSelection(state, completion.row, playerIndex)
      break
    case 'warCry':
      resolved = completeWarCrySelection(state, completion.row, playerIndex)
      break
    default:
      return state
  }

  return advanceTurn(resolved, playerIndex)
}

// ---- Leader ability ----

export function useLeaderAbility(
  state: GameState,
  playerIndex: 0 | 1,
  rng: () => number,
): GameState {
  const player = state.players[playerIndex]
  if (player.leaderAbilityUsed) return state
  if (state.activePlayer !== playerIndex) return state
  if (state.selectionMode !== 'default') return state
  if (!player.leader) return state

  switch (player.leader) {
    case LEADERS.A1:
      return leaderA1(state, playerIndex)
    case LEADERS.A2:
      return leaderA2(state, playerIndex)
    case LEADERS.A3:
      return leaderA3(state, playerIndex)
    case LEADERS.A4:
      return leaderA4(state, playerIndex)
    case LEADERS.A5:
      return leaderA5(state, playerIndex)
    case LEADERS.B1: {
      const { state: next, revealed } = leaderB1(state, playerIndex, rng)
      return { ...next, revealedCards: revealed }
    }
    case LEADERS.B2:
      return leaderB2(state, playerIndex)
    case LEADERS.B3:
      return leaderB3(state, playerIndex)
    case LEADERS.B4:
      return { ...state, selectionMode: 'leaderB4' }
    case LEADERS.B5:
      return leaderB5(state, playerIndex)
    case LEADERS.C1:
      return leaderC1(state, playerIndex)
    case LEADERS.C2:
      return leaderC2(state, playerIndex)
    case LEADERS.C3:
      return leaderC3(state, playerIndex)
    case LEADERS.C4:
      return leaderC4(state, playerIndex)
    case LEADERS.C5:
      return leaderC5(state, playerIndex)
    case LEADERS.D1:
      return leaderD1(state, playerIndex)
    case LEADERS.D2: {
      if (state.randomRestoration) return leaderD2(state, playerIndex, '', rng)
      const eligible = player.discard.filter((c): c is UnitCard => c.type === 'unit' && !c.isHero)
      if (eligible.length === 0) return leaderD2(state, playerIndex, '', rng)
      return { ...state, selectionMode: 'leaderD2' }
    }
    case LEADERS.D3:
      return leaderD3(state, playerIndex)
    case LEADERS.D4: {
      if (player.hand.length === 0) return leaderD4(state, playerIndex, ['', ''], '')
      return { ...state, selectionMode: 'leaderD4discard', pendingLeaderD4Discards: [] }
    }
    case LEADERS.D5: {
      const weatherCards = player.deck.filter((c) => c.type === 'weather')
      if (weatherCards.length === 0) return leaderD5(state, playerIndex, '')
      return { ...state, selectionMode: 'leaderD5' }
    }
    default:
      return state
  }
}

export type LeaderSelectionCompletion =
  | { mode: 'leaderB4'; selectedCardId: string }
  | { mode: 'leaderD2'; selectedCardId: string }
  | { mode: 'leaderD4discard'; selectedCardId: string }
  | { mode: 'leaderD4draw'; selectedCardId: string }
  | { mode: 'leaderD5'; selectedCardId: string }

export function completeLeaderAbilitySelection(
  state: GameState,
  completion: LeaderSelectionCompletion,
  playerIndex: 0 | 1,
  rng: () => number,
): GameState {
  if (state.activePlayer !== playerIndex) return state

  switch (completion.mode) {
    case 'leaderB4':
      return {
        ...leaderB4(state, playerIndex, completion.selectedCardId),
        selectionMode: 'default',
      }
    case 'leaderD2':
      return {
        ...leaderD2(state, playerIndex, completion.selectedCardId, rng),
        selectionMode: 'default',
      }
    case 'leaderD4discard': {
      const newDiscards = [...(state.pendingLeaderD4Discards ?? []), completion.selectedCardId]
      if (newDiscards.length < 2) {
        return { ...state, pendingLeaderD4Discards: newDiscards }
      }
      return { ...state, pendingLeaderD4Discards: newDiscards, selectionMode: 'leaderD4draw' }
    }
    case 'leaderD4draw': {
      const discards = state.pendingLeaderD4Discards ?? []
      const discardTuple: [string, string] = [discards[0] ?? '', discards[1] ?? '']
      return {
        ...leaderD4(state, playerIndex, discardTuple, completion.selectedCardId),
        selectionMode: 'default',
        pendingLeaderD4Discards: [],
      }
    }
    case 'leaderD5':
      return {
        ...leaderD5(state, playerIndex, completion.selectedCardId),
        selectionMode: 'default',
      }
    default:
      return state
  }
}

export function dismissReveal(state: GameState): GameState {
  return { ...state, revealedCards: undefined }
}

// ---- Round checks ----

export function isRoundOver(state: GameState): boolean {
  if (state.selectionMode !== 'default') return false

  const [p0, p1] = state.players
  if (p0.passed && p1.passed) return true
  if (p0.hand.length === 0 && p1.hand.length === 0) return true
  if (p0.passed && p1.hand.length === 0) return true
  if (p1.passed && p0.hand.length === 0) return true

  return false
}

export function computeBoardScore(state: GameState, playerIndex: 0 | 1): number {
  const board = state.players[playerIndex].board
  let total = 0
  for (const rowKey of ['melee', 'ranged', 'siege'] as const) {
    const row = board[rowKey]
    for (const card of row.cards) {
      total += computeStrength(card.id, row, state)
    }
  }
  return total
}

// ---- Round end ----

function clearPlayerBoard(player: PlayerState): PlayerState {
  const allBoardCards: Card[] = [
    ...player.board.melee.cards,
    ...player.board.ranged.cards,
    ...player.board.siege.cards,
  ]
  const board: PlayerRow = {
    melee: { ...player.board.melee, cards: [], warCry: false },
    ranged: { ...player.board.ranged, cards: [], warCry: false },
    siege: { ...player.board.siege, cards: [], warCry: false },
  }
  return { ...player, board, discard: [...player.discard, ...allBoardCards], passed: false }
}

function drawCards(state: GameState, playerIndex: 0 | 1, count: number): GameState {
  const player = state.players[playerIndex]
  const drawn = player.deck.slice(0, count)
  const deck = player.deck.slice(count)
  const updated: PlayerState = { ...player, hand: [...player.hand, ...drawn], deck }
  const players: [PlayerState, PlayerState] =
    playerIndex === 0 ? [updated, state.players[1]] : [state.players[0], updated]
  return { ...state, players }
}

export function endRound(state: GameState, rng: () => number): GameState {
  const p0Score = computeBoardScore(state, 0)
  const p1Score = computeBoardScore(state, 1)

  // Determine round winner for Faction A bonus draw
  let roundWinner: 0 | 1 | null = p0Score > p1Score ? 0 : p1Score > p0Score ? 1 : null
  if (roundWinner === null) {
    if (state.players[0].faction === FACTIONS.B) roundWinner = 0
    else if (state.players[1].faction === FACTIONS.B) roundWinner = 1
  }

  // 1. Deduct gems based on round result
  let next = resolveRoundGems(state, p0Score, p1Score)

  // 2. Clear all board cards to discard; reset warCry flags and passed; update round wins
  const roundWins: [number, number] = [next.roundWins[0], next.roundWins[1]]
  if (roundWinner !== null) roundWins[roundWinner]++
  const cleared0 = clearPlayerBoard(next.players[0])
  const cleared1 = clearPlayerBoard(next.players[1])
  next = {
    ...next,
    players: [cleared0, cleared1],
    weatherZone: [],
    round: next.round + 1,
    selectionMode: 'default',
    pendingOptions: [],
    pendingLeaderD4Discards: [],
    roundWins,
    roundScores: [...(state.roundScores ?? []), [p0Score, p1Score]],
    revealedCards: undefined,
  }

  // 3. Faction D: retain one random unit on board before drawing
  next = applyFactionDRetain(next, 0, rng)
  next = applyFactionDRetain(next, 1, rng)

  // 4. Each player draws 2 cards
  next = drawCards(next, 0, 2)
  next = drawCards(next, 1, 2)

  // 5. Faction A draws 1 extra card on a round win
  if (roundWinner !== null) {
    next = applyFactionADraw(next, roundWinner)
  }

  return next
}

// ---- Match flow ----

export function initMatch(p0: PlayerState, p1: PlayerState, rng: () => number): GameState {
  const base: GameState = {
    players: [p0, p1],
    weatherZone: [],
    round: 1,
    activePlayer: rng() < 0.5 ? 0 : 1,
    selectionMode: 'mulligan',
    pendingOptions: [],
    pendingLeaderD4Discards: [],
    randomRestoration: false,
    leaderD1Active: false,
    mulligansUsed: [0, 0],
    mulliganedCardIds: [[], []],
    mulligansConfirmed: [false, false],
    roundWins: [0, 0],
    roundScores: [],
  }
  let state = drawCards(base, 0, 10)
  state = drawCards(state, 1, 10)
  return state
}

export function performMulligan(state: GameState, cardId: string, playerIndex: 0 | 1): GameState {
  if (state.selectionMode !== 'mulligan') return state
  if (state.mulligansConfirmed[playerIndex]) return state
  if (state.mulligansUsed[playerIndex] >= 2) return state
  if (state.mulliganedCardIds[playerIndex].includes(cardId)) return state

  const player = state.players[playerIndex]
  const card = player.hand.find((c) => c.id === cardId)
  if (!card) return state

  const hand = player.hand.filter((c) => c.id !== cardId)
  const deckWithCard = [...player.deck, card]
  const [drawn, ...deckAfterDraw] = deckWithCard
  const updated: PlayerState = { ...player, hand: [...hand, drawn], deck: deckAfterDraw }
  const players: [PlayerState, PlayerState] =
    playerIndex === 0 ? [updated, state.players[1]] : [state.players[0], updated]

  const mulligansUsed: [number, number] = [state.mulligansUsed[0], state.mulligansUsed[1]]
  mulligansUsed[playerIndex]++
  const mulliganedCardIds: [string[], string[]] = [
    [...state.mulliganedCardIds[0]],
    [...state.mulliganedCardIds[1]],
  ]
  mulliganedCardIds[playerIndex] = [...mulliganedCardIds[playerIndex], cardId]

  return { ...state, players, mulligansUsed, mulliganedCardIds }
}

export function confirmMulligan(state: GameState, playerIndex: 0 | 1): GameState {
  if (state.selectionMode !== 'mulligan') return state

  const mulligansConfirmed: [boolean, boolean] = [
    state.mulligansConfirmed[0],
    state.mulligansConfirmed[1],
  ]
  mulligansConfirmed[playerIndex] = true
  const bothDone = mulligansConfirmed[0] && mulligansConfirmed[1]

  return {
    ...state,
    mulligansConfirmed,
    selectionMode: bothDone ? 'default' : 'mulligan',
  }
}

export function isMatchOver(state: GameState): boolean {
  return state.players[0].gems === 0 || state.players[1].gems === 0
}

export function getMatchResult(state: GameState): MatchResult | null {
  const [p0, p1] = state.players
  if (p0.gems > 0 && p1.gems > 0) return null
  if (p0.gems === 0 && p1.gems === 0) return { winner: null }
  return { winner: p0.gems === 0 ? 1 : 0 }
}
