import { ROWS } from '@/lib/terminology'
import type { GameState, PlayerRow, PlayerState, UnitCard } from '@/types/game'

const ROW_KEY: Record<string, keyof PlayerRow> = {
  [ROWS.MELEE]: 'melee',
  [ROWS.RANGED]: 'ranged',
  [ROWS.SIEGE]: 'siege',
}

export function resolveInfiltrator(
  state: GameState,
  cardId: string,
  playerIndex: 0 | 1,
): GameState {
  const opponentIndex: 0 | 1 = playerIndex === 0 ? 1 : 0
  const player = state.players[playerIndex]
  const card = player.hand.find((c) => c.id === cardId) as UnitCard | undefined
  if (!card) return state

  const hand = player.hand.filter((c) => c.id !== cardId)
  const drawn = player.deck.slice(0, 2)
  const deck = player.deck.slice(2)

  const opponent = state.players[opponentIndex]
  const rowKey = ROW_KEY[card.row]
  const opponentBoard: PlayerRow = {
    ...opponent.board,
    [rowKey]: {
      ...opponent.board[rowKey],
      cards: [...opponent.board[rowKey].cards, card],
    },
  }

  const updatedPlayer: PlayerState = { ...player, hand: [...hand, ...drawn], deck }
  const updatedOpponent: PlayerState = { ...opponent, board: opponentBoard }
  const players: [PlayerState, PlayerState] =
    playerIndex === 0 ? [updatedPlayer, updatedOpponent] : [updatedOpponent, updatedPlayer]

  return { ...state, players }
}
