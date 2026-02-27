import { computeStrength } from '../computeStrength'
import { ROW_KEY } from '../rows'
import type { Card, GameState, PlayerRow, PlayerState, UnitCard } from '@/types/game'

export function resolveRowScorch(state: GameState, cardId: string, playerIndex: 0 | 1): GameState {
  const player = state.players[playerIndex]
  const card = player.hand.find((c) => c.id === cardId) as UnitCard | undefined
  if (!card) return state

  const hand = player.hand.filter((c) => c.id !== cardId)
  const rowKey = ROW_KEY[card.row]
  const board: PlayerRow = {
    ...player.board,
    [rowKey]: {
      ...player.board[rowKey],
      cards: [...player.board[rowKey].cards, card],
    },
  }
  const updatedPlayer: PlayerState = { ...player, hand, board }
  const players: [PlayerState, PlayerState] =
    playerIndex === 0 ? [updatedPlayer, state.players[1]] : [state.players[0], updatedPlayer]
  const withCardPlaced: GameState = { ...state, players }

  const opponentIndex: 0 | 1 = playerIndex === 0 ? 1 : 0
  const opponent = withCardPlaced.players[opponentIndex]
  const opponentRow = opponent.board[rowKey]

  const rowTotal = opponentRow.cards.reduce(
    (sum, c) => sum + computeStrength(c.id, opponentRow, withCardPlaced),
    0,
  )
  if (rowTotal < 10) return withCardPlaced

  const nonHeroUnits = opponentRow.cards.filter((c) => !c.isHero)
  if (nonHeroUnits.length === 0) return withCardPlaced

  const unitStrengths = nonHeroUnits.map((c) => computeStrength(c.id, opponentRow, withCardPlaced))
  const maxStrength = Math.max(...unitStrengths)
  const toDestroy = new Set<string>(
    nonHeroUnits.filter((_, i) => unitStrengths[i] === maxStrength).map((c) => c.id),
  )

  const destroyed: UnitCard[] = opponentRow.cards.filter((c) => toDestroy.has(c.id))
  const newOpponentBoard: PlayerRow = {
    ...opponent.board,
    [rowKey]: {
      ...opponentRow,
      cards: opponentRow.cards.filter((c) => !toDestroy.has(c.id)),
    },
  }
  const newOpponentDiscard: Card[] = [...opponent.discard, ...destroyed]
  const newOpponent: PlayerState = {
    ...opponent,
    board: newOpponentBoard,
    discard: newOpponentDiscard,
  }
  const finalPlayers: [PlayerState, PlayerState] =
    opponentIndex === 0
      ? [newOpponent, withCardPlaced.players[1]]
      : [withCardPlaced.players[0], newOpponent]

  return { ...withCardPlaced, players: finalPlayers }
}
