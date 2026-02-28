import { ROWS } from '@/lib/terminology'
import type { GameState, RowType } from '@/types/game'
import { completeSelection, endRound, isRoundOver } from '@/game/stateMachine'
import { applyMove, getAvailableMoves, getScore as defaultGetScore, isTerminal } from './adapter'
import type { Move } from './adapter'

type ScoreFn = (state: GameState, playerIndex: 0 | 1) => number

// ---- Types ----

interface MCTSNode {
  visits: number
  totalScore: number
  children: Map<string, MCTSNode>
}

// ---- Helpers ----

function moveKey(move: Move): string {
  return move.type === 'pass' ? 'pass' : move.cardId
}

function createNode(): MCTSNode {
  return { visits: 0, totalScore: 0, children: new Map() }
}

function shuffle<T>(arr: T[], rng: () => number): T[] {
  const out = [...arr]
  for (let i = out.length - 1; i > 0; i--) {
    const j = Math.floor(rng() * (i + 1))
    ;[out[i], out[j]] = [out[j], out[i]]
  }
  return out
}

// ---- Determinization ----
// From the AI player's perspective, the opponent's hand and deck are both hidden.
// We sample them by shuffling the combined hidden pool and partitioning it.

function determinize(state: GameState, playerIndex: 0 | 1, rng: () => number): GameState {
  const opponentIndex: 0 | 1 = playerIndex === 0 ? 1 : 0
  const opponent = state.players[opponentIndex]
  const hidden = shuffle([...opponent.hand, ...opponent.deck], rng)
  const newOpponent = {
    ...opponent,
    hand: hidden.slice(0, opponent.hand.length),
    deck: hidden.slice(opponent.hand.length),
  }
  const players: [(typeof state.players)[0], (typeof state.players)[1]] =
    opponentIndex === 0 ? [newOpponent, state.players[1]] : [state.players[0], newOpponent]
  return { ...state, players }
}

// ---- Auto-resolution of interactive selection modes ----
// During simulation, interactive modes are resolved by picking randomly.

const AGILE_ROWS: RowType[] = [ROWS.MELEE, ROWS.RANGED]
const ALL_ROWS: RowType[] = [ROWS.MELEE, ROWS.RANGED, ROWS.SIEGE]

function autoResolve(state: GameState, rng: () => number): GameState {
  let s = state
  while (s.selectionMode !== 'default') {
    const prev = s
    const active = s.activePlayer
    switch (s.selectionMode) {
      case 'medic': {
        if (s.pendingOptions.length === 0) return s
        const pick = s.pendingOptions[Math.floor(rng() * s.pendingOptions.length)]
        s = completeSelection(s, { mode: 'medic', selectedCardId: pick.id }, active, rng)
        break
      }
      case 'decoy': {
        if (s.pendingOptions.length === 0) return s
        const pick = s.pendingOptions[Math.floor(rng() * s.pendingOptions.length)]
        s = completeSelection(s, { mode: 'decoy', selectedCardId: pick.id }, active, rng)
        break
      }
      case 'agile': {
        const row = AGILE_ROWS[Math.floor(rng() * AGILE_ROWS.length)]
        s = completeSelection(s, { mode: 'agile', row }, active, rng)
        break
      }
      case 'warCry': {
        const row = ALL_ROWS[Math.floor(rng() * ALL_ROWS.length)]
        s = completeSelection(s, { mode: 'warCry', row }, active, rng)
        break
      }
      default:
        return s
    }
    if (s === prev) return s
  }
  return s
}

// ---- Single step: apply move, resolve selections, advance round if over ----

function step(state: GameState, move: Move, rng: () => number): GameState {
  let s = applyMove(state, move, state.activePlayer)
  s = autoResolve(s, rng)
  if (s.selectionMode === 'default' && isRoundOver(s)) {
    s = endRound(s, rng)
  }
  return s
}

// ---- UCB1 ----

const EXPLORATION = Math.sqrt(2)

function ucb1(parentVisits: number, child: MCTSNode, sign: number): number {
  if (child.visits === 0) return Infinity
  return (
    sign * (child.totalScore / child.visits) +
    EXPLORATION * Math.sqrt(Math.log(parentVisits) / child.visits)
  )
}

// ---- Single MCTS iteration on a determinized state ----

function runIteration(
  root: MCTSNode,
  state: GameState,
  playerIndex: 0 | 1,
  rng: () => number,
  scoreFn: ScoreFn,
): void {
  const path: Array<{ node: MCTSNode; key: string }> = []
  let node = root
  let s = state

  // Selection and Expansion
  while (!isTerminal(s)) {
    const active = s.activePlayer
    const moves = getAvailableMoves(s, active)
    const availableKeys = new Set(moves.map(moveKey))
    const untried = moves.filter((m) => !node.children.has(moveKey(m)))

    if (untried.length > 0) {
      const move = untried[Math.floor(rng() * untried.length)]
      const key = moveKey(move)
      node.children.set(key, createNode())
      path.push({ node, key })
      s = step(s, move, rng)
      node = node.children.get(key)!
      break
    }

    // UCB1: only consider children available in this determinization.
    // At the opponent's turn, negate the value to minimise playerIndex's score.
    const sign: number = active === playerIndex ? 1 : -1
    let bestKey = ''
    let bestUcb = -Infinity
    for (const [key, child] of Array.from(node.children.entries())) {
      if (!availableKeys.has(key)) continue
      const u = ucb1(node.visits, child, sign)
      if (u > bestUcb) {
        bestUcb = u
        bestKey = key
      }
    }

    if (!bestKey) break

    const move = moves.find((m) => moveKey(m) === bestKey)!
    path.push({ node, key: bestKey })
    s = step(s, move, rng)
    node = node.children.get(bestKey)!
  }

  // Random rollout from the expanded leaf
  let rs = s
  let depth = 0
  while (!isTerminal(rs) && depth < 100) {
    const active = rs.activePlayer
    const moves = getAvailableMoves(rs, active)
    rs = step(rs, moves[Math.floor(rng() * moves.length)], rng)
    depth++
  }

  const score = scoreFn(rs, playerIndex)

  // Backpropagation (scores always stored from playerIndex's perspective)
  root.visits++
  root.totalScore += score
  for (const { node: n, key } of path) {
    const child = n.children.get(key)!
    child.visits++
    child.totalScore += score
  }
}

// ---- Public API ----

export function ismcts(
  state: GameState,
  playerIndex: 0 | 1,
  timeBudgetMs: number,
  rng = Math.random,
  scoreFn: ScoreFn = defaultGetScore,
): Move {
  const root = createNode()
  const deadline = Date.now() + timeBudgetMs

  while (Date.now() < deadline) {
    const det = determinize(state, playerIndex, rng)
    runIteration(root, det, playerIndex, rng, scoreFn)
  }

  const moves = getAvailableMoves(state, playerIndex)
  let bestMove: Move = moves[0]
  let bestAvg = -Infinity

  for (const move of moves) {
    const child = root.children.get(moveKey(move))
    if (!child || child.visits === 0) continue
    const avg = child.totalScore / child.visits
    if (avg > bestAvg) {
      bestAvg = avg
      bestMove = move
    }
  }

  return bestMove
}
