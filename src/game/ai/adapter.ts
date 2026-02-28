import type { GameState } from '@/types/game'
import { computeBoardScore, isMatchOver, pass, playCard } from '@/game/stateMachine'

export type Move = { type: 'playCard'; cardId: string } | { type: 'pass' }

export function getAvailableMoves(state: GameState, playerIndex: 0 | 1): Move[] {
  const moves: Move[] = state.players[playerIndex].hand.map((card) => ({
    type: 'playCard',
    cardId: card.id,
  }))
  moves.push({ type: 'pass' })
  return moves
}

export function applyMove(state: GameState, move: Move, playerIndex: 0 | 1): GameState {
  if (move.type === 'pass') {
    return pass(state, playerIndex)
  }
  return playCard(state, move.cardId, playerIndex, Math.random)
}

export function isTerminal(state: GameState): boolean {
  return isMatchOver(state)
}

export function getScore(state: GameState, playerIndex: 0 | 1): number {
  return computeBoardScore(state, playerIndex)
}
