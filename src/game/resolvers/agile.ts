import type { GameState, PlayerState, RowType, UnitCard } from '@/types/game'
import { ROW_KEY } from '../rows'

export function resolveAgile(state: GameState, cardId: string, playerIndex: 0 | 1): GameState {
  const player = state.players[playerIndex]
  const card = player.hand.find((c) => c.id === cardId) as UnitCard | undefined
  if (!card) return state

  const hand = player.hand.filter((c) => c.id !== cardId)
  const updatedPlayer: PlayerState = { ...player, hand }
  const players: [PlayerState, PlayerState] =
    playerIndex === 0 ? [updatedPlayer, state.players[1]] : [state.players[0], updatedPlayer]

  return { ...state, players, selectionMode: 'agile', pendingOptions: [card] }
}

export function completeAgileSelection(
  state: GameState,
  row: RowType,
  playerIndex: 0 | 1,
): GameState {
  const card = state.pendingOptions[0]
  if (!card) return state

  const placed: UnitCard = { ...card, row }
  const player = state.players[playerIndex]
  const rowKey = ROW_KEY[row]
  const board = {
    ...player.board,
    [rowKey]: {
      ...player.board[rowKey],
      cards: [...player.board[rowKey].cards, placed],
    },
  }

  const updatedPlayer: PlayerState = { ...player, board }
  const players: [PlayerState, PlayerState] =
    playerIndex === 0 ? [updatedPlayer, state.players[1]] : [state.players[0], updatedPlayer]

  return { ...state, players, selectionMode: 'default', pendingOptions: [] }
}
