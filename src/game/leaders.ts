import { ABILITIES, WEATHER } from '@/lib/terminology'
import type {
  Card,
  GameState,
  PlayerRow,
  PlayerState,
  RowState,
  UnitCard,
  WeatherCard,
} from '@/types/game'
import { computeStrength } from './computeStrength'

function markUsed(state: GameState, playerIndex: 0 | 1): GameState {
  const player = state.players[playerIndex]
  const updated: PlayerState = { ...player, leaderAbilityUsed: true }
  const players: [PlayerState, PlayerState] =
    playerIndex === 0 ? [updated, state.players[1]] : [state.players[0], updated]
  return { ...state, players }
}

function setRowWarCry(state: GameState, playerIndex: 0 | 1, rowKey: keyof PlayerRow): GameState {
  const player = state.players[playerIndex]
  if (player.board[rowKey].warCry) return state
  const board: PlayerRow = {
    ...player.board,
    [rowKey]: { ...player.board[rowKey], warCry: true },
  }
  const updated: PlayerState = { ...player, board }
  const players: [PlayerState, PlayerState] =
    playerIndex === 0 ? [updated, state.players[1]] : [state.players[0], updated]
  return { ...state, players }
}

function destroyStrongestInRow(
  state: GameState,
  targetIndex: 0 | 1,
  rowKey: keyof PlayerRow,
): GameState {
  const target = state.players[targetIndex]
  const rowState: RowState = target.board[rowKey]
  const rowTotal = rowState.cards.reduce(
    (sum, c) => sum + computeStrength(c.id, rowState, state),
    0,
  )
  if (rowTotal < 10) return state

  const nonHeroes = rowState.cards.filter((c) => !c.isHero)
  if (nonHeroes.length === 0) return state

  const strengths = nonHeroes.map((c) => computeStrength(c.id, rowState, state))
  const maxStrength = Math.max(...strengths)
  const toDestroy = new Set(
    nonHeroes.filter((_, i) => strengths[i] === maxStrength).map((c) => c.id),
  )

  const destroyed = rowState.cards.filter((c) => toDestroy.has(c.id))
  const board: PlayerRow = {
    ...target.board,
    [rowKey]: { ...rowState, cards: rowState.cards.filter((c) => !toDestroy.has(c.id)) },
  }
  const updated: PlayerState = { ...target, board, discard: [...target.discard, ...destroyed] }
  const players: [PlayerState, PlayerState] =
    targetIndex === 0 ? [updated, state.players[1]] : [state.players[0], updated]
  return { ...state, players }
}

function playWeatherFromDeck(state: GameState, playerIndex: 0 | 1, weatherType: string): GameState {
  const player = state.players[playerIndex]
  const card = player.deck.find(
    (c): c is WeatherCard => c.type === 'weather' && c.weatherType === weatherType,
  )
  if (!card) return state

  const deck = player.deck.filter((c) => c.id !== card.id)
  const updated: PlayerState = { ...player, deck }
  const players: [PlayerState, PlayerState] =
    playerIndex === 0 ? [updated, state.players[1]] : [state.players[0], updated]
  const withDeck: GameState = { ...state, players }

  if (card.weatherType === WEATHER.DISPEL) return { ...withDeck, weatherZone: [] }
  return { ...withDeck, weatherZone: [...withDeck.weatherZone, card] }
}

function pickRandom<T>(items: T[], count: number, rng: () => number): T[] {
  const pool = [...items]
  const result: T[] = []
  const n = Math.min(count, pool.length)
  for (let i = 0; i < n; i++) {
    const idx = Math.floor(rng() * (pool.length - i))
    result.push(pool[idx])
    pool[idx] = pool[pool.length - 1 - i]
  }
  return result
}

// ---- Faction A ----

export function leaderA1(state: GameState, playerIndex: 0 | 1): GameState {
  return markUsed(playWeatherFromDeck(state, playerIndex, WEATHER.SHROUD), playerIndex)
}

export function leaderA2(state: GameState, playerIndex: 0 | 1): GameState {
  return markUsed({ ...state, weatherZone: [] }, playerIndex)
}

export function leaderA3(state: GameState, playerIndex: 0 | 1): GameState {
  const opponentIndex: 0 | 1 = playerIndex === 0 ? 1 : 0
  return markUsed(destroyStrongestInRow(state, opponentIndex, 'ranged'), playerIndex)
}

export function leaderA4(state: GameState, playerIndex: 0 | 1): GameState {
  return markUsed(setRowWarCry(state, playerIndex, 'siege'), playerIndex)
}

export function leaderA5(state: GameState, playerIndex: 0 | 1): GameState {
  const opponentIndex: 0 | 1 = playerIndex === 0 ? 1 : 0
  return markUsed(destroyStrongestInRow(state, opponentIndex, 'siege'), playerIndex)
}

// ---- Faction B ----

export function leaderB1(
  state: GameState,
  playerIndex: 0 | 1,
  rng: () => number,
): { state: GameState; revealed: Card[] } {
  const opponentIndex: 0 | 1 = playerIndex === 0 ? 1 : 0
  const revealed = pickRandom(state.players[opponentIndex].hand, 3, rng)
  return { state: markUsed(state, playerIndex), revealed }
}

export function leaderB2(state: GameState, playerIndex: 0 | 1): GameState {
  return markUsed(playWeatherFromDeck(state, playerIndex, WEATHER.DELUGE), playerIndex)
}

export function leaderB3(state: GameState, playerIndex: 0 | 1): GameState {
  return markUsed({ ...state, randomRestoration: true }, playerIndex)
}

export function leaderB4(state: GameState, playerIndex: 0 | 1, cardId: string): GameState {
  const opponentIndex: 0 | 1 = playerIndex === 0 ? 1 : 0
  const opponent = state.players[opponentIndex]
  const card = opponent.discard.find((c) => c.id === cardId)
  if (!card) return markUsed(state, playerIndex)

  const opponentUpdated: PlayerState = {
    ...opponent,
    discard: opponent.discard.filter((c) => c.id !== cardId),
  }
  const player = state.players[playerIndex]
  const playerUpdated: PlayerState = {
    ...player,
    hand: [...player.hand, card],
    leaderAbilityUsed: true,
  }
  const players: [PlayerState, PlayerState] =
    playerIndex === 0 ? [playerUpdated, opponentUpdated] : [opponentUpdated, playerUpdated]
  return { ...state, players }
}

export function leaderB5(state: GameState, playerIndex: 0 | 1): GameState {
  const opponentIndex: 0 | 1 = playerIndex === 0 ? 1 : 0
  const canceledOpponent: PlayerState = { ...state.players[opponentIndex], leaderAbilityUsed: true }
  const activePlayer: PlayerState = { ...state.players[playerIndex], leaderAbilityUsed: true }
  const players: [PlayerState, PlayerState] =
    playerIndex === 0 ? [activePlayer, canceledOpponent] : [canceledOpponent, activePlayer]
  return { ...state, players }
}

// ---- Faction C ----

export function leaderC1(state: GameState, playerIndex: 0 | 1): GameState {
  const player = state.players[playerIndex]
  if (player.deck.length === 0) return markUsed(state, playerIndex)
  const [drawn, ...deck] = player.deck
  const updated: PlayerState = {
    ...player,
    hand: [...player.hand, drawn],
    deck,
    leaderAbilityUsed: true,
  }
  const players: [PlayerState, PlayerState] =
    playerIndex === 0 ? [updated, state.players[1]] : [state.players[0], updated]
  return { ...state, players }
}

export function leaderC2(state: GameState, playerIndex: 0 | 1): GameState {
  const player = state.players[playerIndex]
  let currentBoard = player.board

  const agileCardIds = [
    ...currentBoard.melee.cards.filter((c) => c.ability === ABILITIES.AGILE).map((c) => c.id),
    ...currentBoard.ranged.cards.filter((c) => c.ability === ABILITIES.AGILE).map((c) => c.id),
  ]

  for (const cardId of agileCardIds) {
    const currentRowKey: keyof PlayerRow = currentBoard.melee.cards.some((c) => c.id === cardId)
      ? 'melee'
      : 'ranged'
    const otherRowKey: keyof PlayerRow = currentRowKey === 'melee' ? 'ranged' : 'melee'
    const card = currentBoard[currentRowKey].cards.find((c) => c.id === cardId)!

    const stateWithCurrent: GameState = {
      ...state,
      players:
        playerIndex === 0
          ? [{ ...player, board: currentBoard }, state.players[1]]
          : [state.players[0], { ...player, board: currentBoard }],
    }
    const strengthInCurrent = computeStrength(cardId, currentBoard[currentRowKey], stateWithCurrent)

    const boardMoved: PlayerRow = {
      ...currentBoard,
      [currentRowKey]: {
        ...currentBoard[currentRowKey],
        cards: currentBoard[currentRowKey].cards.filter((c) => c.id !== cardId),
      },
      [otherRowKey]: {
        ...currentBoard[otherRowKey],
        cards: [...currentBoard[otherRowKey].cards, card],
      },
    }
    const stateWithMoved: GameState = {
      ...state,
      players:
        playerIndex === 0
          ? [{ ...player, board: boardMoved }, state.players[1]]
          : [state.players[0], { ...player, board: boardMoved }],
    }
    const strengthInOther = computeStrength(cardId, boardMoved[otherRowKey], stateWithMoved)

    if (
      strengthInOther > strengthInCurrent ||
      (strengthInOther === strengthInCurrent && otherRowKey === 'melee')
    ) {
      currentBoard = boardMoved
    }
  }

  const updated: PlayerState = { ...player, board: currentBoard, leaderAbilityUsed: true }
  const players: [PlayerState, PlayerState] =
    playerIndex === 0 ? [updated, state.players[1]] : [state.players[0], updated]
  return { ...state, players }
}

export function leaderC3(state: GameState, playerIndex: 0 | 1): GameState {
  return markUsed(playWeatherFromDeck(state, playerIndex, WEATHER.BLIZZARD), playerIndex)
}

export function leaderC4(state: GameState, playerIndex: 0 | 1): GameState {
  const opponentIndex: 0 | 1 = playerIndex === 0 ? 1 : 0
  return markUsed(destroyStrongestInRow(state, opponentIndex, 'melee'), playerIndex)
}

export function leaderC5(state: GameState, playerIndex: 0 | 1): GameState {
  return markUsed(setRowWarCry(state, playerIndex, 'ranged'), playerIndex)
}

// ---- Faction D ----

export function leaderD1(state: GameState, playerIndex: 0 | 1): GameState {
  return markUsed({ ...state, leaderD1Active: true }, playerIndex)
}

export function leaderD2(
  state: GameState,
  playerIndex: 0 | 1,
  cardId: string,
  rng: () => number,
): GameState {
  const player = state.players[playerIndex]
  const eligible = player.discard.filter((c): c is UnitCard => c.type === 'unit' && !c.isHero)
  if (eligible.length === 0) return markUsed(state, playerIndex)

  const card = state.randomRestoration
    ? eligible[Math.floor(rng() * eligible.length)]
    : eligible.find((c) => c.id === cardId)
  if (!card) return markUsed(state, playerIndex)

  const updated: PlayerState = {
    ...player,
    hand: [...player.hand, card],
    discard: player.discard.filter((c) => c.id !== card.id),
    leaderAbilityUsed: true,
  }
  const players: [PlayerState, PlayerState] =
    playerIndex === 0 ? [updated, state.players[1]] : [state.players[0], updated]
  return { ...state, players }
}

export function leaderD3(state: GameState, playerIndex: 0 | 1): GameState {
  return markUsed(setRowWarCry(state, playerIndex, 'melee'), playerIndex)
}

export function leaderD4(
  state: GameState,
  playerIndex: 0 | 1,
  discardedIds: [string, string],
  chosenCardId: string,
): GameState {
  const player = state.players[playerIndex]
  const cardsToDiscard = discardedIds
    .map((id) => player.hand.find((c) => c.id === id))
    .filter((c): c is Card => c !== undefined)
  const hand = player.hand.filter((c) => !discardedIds.includes(c.id))
  const discard = [...player.discard, ...cardsToDiscard]

  const chosenCard = player.deck.find((c) => c.id === chosenCardId)
  const deck = chosenCard ? player.deck.filter((c) => c.id !== chosenCardId) : player.deck
  const finalHand = chosenCard ? [...hand, chosenCard] : hand

  const updated: PlayerState = {
    ...player,
    hand: finalHand,
    deck,
    discard,
    leaderAbilityUsed: true,
  }
  const players: [PlayerState, PlayerState] =
    playerIndex === 0 ? [updated, state.players[1]] : [state.players[0], updated]
  return { ...state, players }
}

export function leaderD5(state: GameState, playerIndex: 0 | 1, cardId: string): GameState {
  const player = state.players[playerIndex]
  const card = player.deck.find((c): c is WeatherCard => c.type === 'weather' && c.id === cardId)
  if (!card) return markUsed(state, playerIndex)

  const deck = player.deck.filter((c) => c.id !== cardId)
  const updated: PlayerState = { ...player, deck }
  const players: [PlayerState, PlayerState] =
    playerIndex === 0 ? [updated, state.players[1]] : [state.players[0], updated]
  const withDeck: GameState = { ...state, players }

  if (card.weatherType === WEATHER.DISPEL)
    return markUsed({ ...withDeck, weatherZone: [] }, playerIndex)
  return markUsed({ ...withDeck, weatherZone: [...withDeck.weatherZone, card] }, playerIndex)
}
