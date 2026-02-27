import type { GameState, PlayerState, UnitCard } from '@/types/game'
import { ROW_KEY } from '../rows'

export function resolveFormation(state: GameState, cardId: string, playerIndex: 0 | 1): GameState {
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

  const updatedPlayer: PlayerState = { ...player, hand, board }
  const players: [PlayerState, PlayerState] =
    playerIndex === 0 ? [updatedPlayer, state.players[1]] : [state.players[0], updatedPlayer]

  return { ...state, players }
}
