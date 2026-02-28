import { computeBoardScore } from '@/game/stateMachine'
import type { Card, GameState, UnitCard } from '@/types/game'
import type { Move } from './adapter'
import { ismcts } from './ismcts'

// ---- Tuned scoring function ----
// Used by Medium and Hard ISMCTS. Weights are designed to value card economy
// correctly so the AI does not bleed its hand and lose round 3.

const HAND_WEIGHT_BASE = 2
const HAND_WEIGHT_PER_ROUND = 3
const GEM_WEIGHT = 50

export function getScore(state: GameState, playerIndex: 0 | 1): number {
  const opp: 0 | 1 = playerIndex === 0 ? 1 : 0
  const boardAdvantage = computeBoardScore(state, playerIndex) - computeBoardScore(state, opp)
  // Card advantage weight increases each round — in round 3, each card is worth more
  const handWeight = HAND_WEIGHT_BASE + HAND_WEIGHT_PER_ROUND * (state.round - 1)
  const handAdvantage =
    (state.players[playerIndex].hand.length - state.players[opp].hand.length) * handWeight
  // Gem advantage carries the highest weight; losing a gem is catastrophic
  const gemAdvantage = (state.players[playerIndex].gems - state.players[opp].gems) * GEM_WEIGHT
  return boardAdvantage + handAdvantage + gemAdvantage
}

// ---- Easy AI ----

function highestStrengthUnit(hand: Card[]): UnitCard | null {
  const units = hand.filter((c): c is UnitCard => c.type === 'unit')
  if (units.length === 0) return null
  return units.reduce((best, c) => (c.baseStrength > best.baseStrength ? c : best))
}

export function easyMove(state: GameState, playerIndex: 0 | 1): Move {
  const hand = state.players[playerIndex].hand
  if (hand.length === 0) return { type: 'pass' }
  const best = highestStrengthUnit(hand)
  if (best) return { type: 'playCard', cardId: best.id }
  // Only specials or weather in hand: play the first one
  return { type: 'playCard', cardId: hand[0].id }
}

// ---- Difficulty tiers ----

export type Difficulty = 'easy' | 'medium' | 'hard'

const TIME_BUDGETS = { medium: 500, hard: 2000 } as const

export function getAiMove(
  state: GameState,
  playerIndex: 0 | 1,
  difficulty: Difficulty,
  rng = Math.random,
): Move {
  if (difficulty === 'easy') return easyMove(state, playerIndex)
  return ismcts(state, playerIndex, TIME_BUDGETS[difficulty], rng, getScore)
}
