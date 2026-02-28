import { ABILITIES, FACTIONS } from '@/lib/terminology'
import type { Card, GameState, PlayerRow, PlayerState, RowType, UnitCard } from '@/types/game'
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

  // 2. Clear all board cards to discard; reset warCry flags and passed
  const cleared0 = clearPlayerBoard(next.players[0])
  const cleared1 = clearPlayerBoard(next.players[1])
  next = {
    ...next,
    players: [cleared0, cleared1],
    weatherZone: [],
    round: next.round + 1,
    selectionMode: 'default',
    pendingOptions: [],
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
