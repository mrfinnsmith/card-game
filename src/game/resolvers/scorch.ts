import { computeStrength } from '../computeStrength'
import type { Card, GameState, PlayerRow, PlayerState, RowState, UnitCard } from '@/types/game'

type ScorchEntry = {
  card: UnitCard
  row: RowState
  playerIndex: 0 | 1
  rowKey: keyof PlayerRow
}

function collectNonHeroEntries(state: GameState): ScorchEntry[] {
  const entries: ScorchEntry[] = []
  for (const playerIndex of [0, 1] as const) {
    const board = state.players[playerIndex].board
    for (const rowKey of ['melee', 'ranged', 'siege'] as const) {
      const row = board[rowKey]
      for (const card of row.cards) {
        if (!card.isHero) {
          entries.push({ card, row, playerIndex, rowKey })
        }
      }
    }
  }
  return entries
}

export function resolveScorch(state: GameState, cardId: string, playerIndex: 0 | 1): GameState {
  const player = state.players[playerIndex]
  const card = player.hand.find((c) => c.id === cardId)
  if (!card) return state

  const hand = player.hand.filter((c) => c.id !== cardId)
  const discard: Card[] = [...player.discard, card]
  const updatedPlayer: PlayerState = { ...player, hand, discard }
  const players: [PlayerState, PlayerState] =
    playerIndex === 0 ? [updatedPlayer, state.players[1]] : [state.players[0], updatedPlayer]
  const withCardPlayed: GameState = { ...state, players }

  const entries = collectNonHeroEntries(withCardPlayed)
  if (entries.length === 0) return withCardPlayed

  const strengths = entries.map((e) => computeStrength(e.card.id, e.row, withCardPlayed))
  const maxStrength = Math.max(...strengths)
  const toDestroy = new Set<string>(
    entries.filter((_, i) => strengths[i] === maxStrength).map((e) => e.card.id),
  )

  let newState = withCardPlayed
  for (const pIdx of [0, 1] as const) {
    const p = newState.players[pIdx]
    const { board } = p
    const destroyed = (['melee', 'ranged', 'siege'] as const).flatMap((rowKey) =>
      board[rowKey].cards.filter((c) => toDestroy.has(c.id)),
    )
    if (destroyed.length === 0) continue
    const newBoard: PlayerRow = {
      melee: { ...board.melee, cards: board.melee.cards.filter((c) => !toDestroy.has(c.id)) },
      ranged: { ...board.ranged, cards: board.ranged.cards.filter((c) => !toDestroy.has(c.id)) },
      siege: { ...board.siege, cards: board.siege.cards.filter((c) => !toDestroy.has(c.id)) },
    }
    const newP: PlayerState = { ...p, board: newBoard, discard: [...p.discard, ...destroyed] }
    const newPlayers: [PlayerState, PlayerState] =
      pIdx === 0 ? [newP, newState.players[1]] : [newState.players[0], newP]
    newState = { ...newState, players: newPlayers }
  }

  return newState
}
