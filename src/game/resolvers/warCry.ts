import { ROW_KEY } from '../rows'
import type { Card, GameState, PlayerRow, PlayerState, RowType, UnitCard } from '@/types/game'

export function resolveWarCrySpecial(
  state: GameState,
  cardId: string,
  playerIndex: 0 | 1,
): GameState {
  const player = state.players[playerIndex]
  const card = player.hand.find((c) => c.id === cardId)
  if (!card) return state

  const hand = player.hand.filter((c) => c.id !== cardId)
  const discard: Card[] = [...player.discard, card]
  const updatedPlayer: PlayerState = { ...player, hand, discard }
  const players: [PlayerState, PlayerState] =
    playerIndex === 0 ? [updatedPlayer, state.players[1]] : [state.players[0], updatedPlayer]

  return { ...state, players, selectionMode: 'warCry' }
}

export function completeWarCrySelection(
  state: GameState,
  row: RowType,
  playerIndex: 0 | 1,
): GameState {
  const player = state.players[playerIndex]
  const rowKey = ROW_KEY[row]
  const rowState = player.board[rowKey]

  if (rowState.warCry) return { ...state, selectionMode: 'default' }

  const board: PlayerRow = {
    ...player.board,
    [rowKey]: { ...rowState, warCry: true },
  }
  const updatedPlayer: PlayerState = { ...player, board }
  const players: [PlayerState, PlayerState] =
    playerIndex === 0 ? [updatedPlayer, state.players[1]] : [state.players[0], updatedPlayer]

  return { ...state, players, selectionMode: 'default' }
}

export function resolveWarCryUnit(state: GameState, cardId: string, playerIndex: 0 | 1): GameState {
  const player = state.players[playerIndex]
  const card = player.hand.find((c) => c.id === cardId) as UnitCard | undefined
  if (!card) return state

  const hand = player.hand.filter((c) => c.id !== cardId)
  const rowKey = ROW_KEY[card.row]
  const rowState = player.board[rowKey]
  const board: PlayerRow = {
    ...player.board,
    [rowKey]: {
      ...rowState,
      cards: [...rowState.cards, card],
      warCry: true,
    },
  }
  const updatedPlayer: PlayerState = { ...player, hand, board }
  const players: [PlayerState, PlayerState] =
    playerIndex === 0 ? [updatedPlayer, state.players[1]] : [state.players[0], updatedPlayer]

  return { ...state, players }
}
