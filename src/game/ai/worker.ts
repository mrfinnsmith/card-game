import type { GameState } from '@/types/game'
import { getAiMove, type Difficulty } from './scoring'
import type { Move } from './adapter'

interface WorkerRequest {
  state: GameState
  playerIndex: 0 | 1
  difficulty: Difficulty
}

// Cast self to Worker to satisfy TypeScript under the dom lib
const ctx = self as unknown as Worker

ctx.onmessage = (e: MessageEvent<WorkerRequest>) => {
  const { state, playerIndex, difficulty } = e.data
  const move: Move = getAiMove(state, playerIndex, difficulty)
  ctx.postMessage(move)
}
