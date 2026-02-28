'use client'

import { useCallback, useEffect, useRef, useState } from 'react'
import { Board } from '@/components/game/Board'
import { DiscardPile } from '@/components/game/DiscardPile'
import { PlayerHand, OpponentHand } from '@/components/game/Hand'
import { SelectionOverlay } from '@/components/game/SelectionOverlay'
import { FactionSelect } from '@/components/game/FactionSelect'
import type { FactionSelection } from '@/components/game/FactionSelect'
import { buildDeck, shuffleDeck } from '@/game/decks'
import {
  completeSelection,
  confirmMulligan,
  endRound,
  getMatchResult,
  initMatch,
  isMatchOver,
  isRoundOver,
  pass,
  performMulligan,
  playCard,
} from '@/game/stateMachine'
import { applyMove } from '@/game/ai/adapter'
import type { Move } from '@/game/ai/adapter'
import type { Difficulty } from '@/game/ai/scoring'
import { ROWS } from '@/lib/terminology'
import { GameStoreProvider, useGameStore, useGameStoreApi } from '@/store/gameStore'
import type { GameState, MatchResult, PlayerState, RowType } from '@/types/game'

// ---- helpers ----

function buildPlayerState(
  faction: FactionSelection['playerFaction'] | FactionSelection['aiFaction'],
  leader: FactionSelection['playerLeader'] | FactionSelection['aiLeader'],
  prefix: string,
): PlayerState {
  return {
    faction,
    leader,
    hand: [],
    deck: shuffleDeck(buildDeck(faction, prefix)),
    discard: [],
    board: {
      melee: { type: ROWS.MELEE, cards: [], warCry: false },
      ranged: { type: ROWS.RANGED, cards: [], warCry: false },
      siege: { type: ROWS.SIEGE, cards: [], warCry: false },
    },
    gems: 2,
    passed: false,
    leaderAbilityUsed: false,
  }
}

// Auto-resolve selection modes for the AI (random choices).
function autoResolveAi(state: GameState): GameState {
  let s = state
  while (s.selectionMode !== 'default' && s.selectionMode !== 'mulligan') {
    const prev = s
    const active = s.activePlayer
    switch (s.selectionMode) {
      case 'medic': {
        if (s.pendingOptions.length === 0) return s
        const pick = s.pendingOptions[Math.floor(Math.random() * s.pendingOptions.length)]
        s = completeSelection(s, { mode: 'medic', selectedCardId: pick.id }, active, Math.random)
        break
      }
      case 'decoy': {
        if (s.pendingOptions.length === 0) return s
        const pick = s.pendingOptions[Math.floor(Math.random() * s.pendingOptions.length)]
        s = completeSelection(s, { mode: 'decoy', selectedCardId: pick.id }, active, Math.random)
        break
      }
      case 'agile': {
        const rows: RowType[] = [ROWS.MELEE, ROWS.RANGED]
        const row = rows[Math.floor(Math.random() * rows.length)]
        s = completeSelection(s, { mode: 'agile', row }, active, Math.random)
        break
      }
      case 'warCry': {
        const rows: RowType[] = [ROWS.MELEE, ROWS.RANGED, ROWS.SIEGE]
        const row = rows[Math.floor(Math.random() * rows.length)]
        s = completeSelection(s, { mode: 'warCry', row }, active, Math.random)
        break
      }
      default:
        return s
    }
    if (s === prev) return s
  }
  return s
}

// ---- result screen ----

function ResultScreen({
  result,
  roundWins,
  onPlayAgain,
}: {
  result: MatchResult
  roundWins: [number, number]
  onPlayAgain: () => void
}) {
  const heading =
    result.winner === 0 ? 'You win!' : result.winner === 1 ? 'Opponent wins' : "It's a draw"

  return (
    <div className="flex flex-col items-center justify-center min-h-screen bg-gray-50 p-6">
      <div className="bg-white rounded-xl border border-gray-200 shadow-sm p-8 w-full max-w-sm text-center space-y-4">
        <h1 className="text-2xl font-bold text-gray-900">{heading}</h1>
        <div className="text-sm text-gray-500 space-y-1">
          <p>
            You won {roundWins[0]} round{roundWins[0] !== 1 ? 's' : ''}
          </p>
          <p>
            Opponent won {roundWins[1]} round{roundWins[1] !== 1 ? 's' : ''}
          </p>
        </div>
        <button
          onClick={onPlayAgain}
          className="w-full px-4 py-2.5 rounded-lg bg-blue-600 text-white text-sm font-semibold hover:bg-blue-700 transition-colors"
        >
          Play again
        </button>
      </div>
    </div>
  )
}

// ---- game screen ----

const DIFFICULTY: Difficulty = 'medium'

function GameScreen({
  onMatchEnd,
}: {
  onMatchEnd: (result: MatchResult, roundWins: [number, number]) => void
}) {
  const storeApi = useGameStoreApi()
  const state = useGameStore((s) => s)

  // Always-current refs so async callbacks (worker) see fresh state.
  const stateRef = useRef(state)
  stateRef.current = state

  const onMatchEndRef = useRef(onMatchEnd)
  onMatchEndRef.current = onMatchEnd

  const workerRef = useRef<Worker | null>(null)
  const aiThinkingRef = useRef(false)

  // Initialize the AI web worker once.
  useEffect(() => {
    const worker = new Worker(new URL('@/game/ai/worker.ts', import.meta.url))
    workerRef.current = worker

    worker.onmessage = (e: MessageEvent<Move>) => {
      aiThinkingRef.current = false
      const move = e.data
      let next = applyMove(stateRef.current, move, 1)
      next = autoResolveAi(next)
      if (isRoundOver(next)) {
        next = endRound(next, Math.random)
        if (isMatchOver(next)) {
          storeApi.setState(next)
          onMatchEndRef.current(getMatchResult(next)!, next.roundWins)
          return
        }
      }
      storeApi.setState(next)
    }

    return () => {
      worker.terminate()
      workerRef.current = null
    }
  }, [storeApi])

  // Auto-confirm the AI's mulligan immediately (no swaps).
  const aiMulliganConfirmed = state.mulligansConfirmed[1]
  useEffect(() => {
    if (state.selectionMode === 'mulligan' && !aiMulliganConfirmed) {
      storeApi.setState(confirmMulligan(stateRef.current, 1))
    }
  }, [state.selectionMode, aiMulliganConfirmed, storeApi])

  // Trigger AI turn whenever it becomes AI's move.
  useEffect(() => {
    if (
      state.activePlayer === 1 &&
      state.selectionMode === 'default' &&
      !state.players[1].passed &&
      !isRoundOver(state) &&
      !isMatchOver(state) &&
      !aiThinkingRef.current &&
      workerRef.current
    ) {
      aiThinkingRef.current = true
      workerRef.current.postMessage({ state, playerIndex: 1, difficulty: DIFFICULTY })
    }
  }, [state])

  // Apply a state change, then check for round/match end.
  function applyAndAdvance(next: GameState) {
    if (isRoundOver(next)) {
      next = endRound(next, Math.random)
      if (isMatchOver(next)) {
        storeApi.setState(next)
        onMatchEndRef.current(getMatchResult(next)!, next.roundWins)
        return
      }
    }
    storeApi.setState(next)
  }

  // Player action handlers.
  function handlePlayCard(cardId: string) {
    applyAndAdvance(playCard(stateRef.current, cardId, 0, Math.random))
  }

  function handlePass() {
    applyAndAdvance(pass(stateRef.current, 0))
  }

  function handleMedicSelect(cardId: string) {
    applyAndAdvance(
      completeSelection(
        stateRef.current,
        { mode: 'medic', selectedCardId: cardId },
        0,
        Math.random,
      ),
    )
  }

  function handleDecoySelect(cardId: string) {
    applyAndAdvance(
      completeSelection(
        stateRef.current,
        { mode: 'decoy', selectedCardId: cardId },
        0,
        Math.random,
      ),
    )
  }

  function handleAgileSelect(row: RowType) {
    applyAndAdvance(completeSelection(stateRef.current, { mode: 'agile', row }, 0, Math.random))
  }

  function handleWarCrySelect(row: RowType) {
    applyAndAdvance(completeSelection(stateRef.current, { mode: 'warCry', row }, 0, Math.random))
  }

  function handleMulliganSwap(cardId: string) {
    storeApi.setState(performMulligan(stateRef.current, cardId, 0))
  }

  function handleMulliganConfirm() {
    storeApi.setState(confirmMulligan(stateRef.current, 0))
  }

  const canPass =
    state.activePlayer === 0 &&
    state.selectionMode === 'default' &&
    !state.players[0].passed &&
    !isMatchOver(state)

  return (
    <div className="flex flex-col min-h-screen bg-gray-100 p-3 gap-2">
      {/* Opponent area */}
      <div className="flex items-center gap-2">
        <DiscardPile playerIndex={1} />
        <OpponentHand />
      </div>

      {/* Board */}
      <div className="flex-1">
        <Board />
      </div>

      {/* Player area */}
      <div className="flex items-end gap-2">
        <DiscardPile playerIndex={0} />
        <div className="flex-1 overflow-x-auto">
          <PlayerHand onPlay={handlePlayCard} />
        </div>
        <button
          onClick={handlePass}
          disabled={!canPass}
          className={[
            'shrink-0 px-4 py-2 rounded-lg border text-sm font-semibold transition-colors self-center',
            canPass
              ? 'border-red-300 bg-white text-red-600 hover:bg-red-50'
              : 'border-gray-200 bg-gray-50 text-gray-300 cursor-default',
          ].join(' ')}
        >
          Pass
        </button>
      </div>

      <SelectionOverlay
        onMedicSelect={handleMedicSelect}
        onDecoySelect={handleDecoySelect}
        onAgileSelect={handleAgileSelect}
        onWarCrySelect={handleWarCrySelect}
        onMulliganSwap={handleMulliganSwap}
        onMulliganConfirm={handleMulliganConfirm}
      />
    </div>
  )
}

// ---- play page ----

type Phase = 'faction-select' | 'playing' | 'match-result'

export default function PlayPage() {
  const [phase, setPhase] = useState<Phase>('faction-select')
  const [matchResult, setMatchResult] = useState<MatchResult | null>(null)
  const [roundWins, setRoundWins] = useState<[number, number]>([0, 0])
  const [initialGameState, setInitialGameState] = useState<GameState | null>(null)

  function handleFactionConfirm(selection: FactionSelection) {
    const p0 = buildPlayerState(selection.playerFaction, selection.playerLeader, 'p0')
    const p1 = buildPlayerState(selection.aiFaction, selection.aiLeader, 'p1')
    setInitialGameState(initMatch(p0, p1, Math.random))
    setPhase('playing')
  }

  const handleMatchEnd = useCallback((result: MatchResult, wins: [number, number]) => {
    setMatchResult(result)
    setRoundWins(wins)
    setPhase('match-result')
  }, [])

  function handlePlayAgain() {
    setInitialGameState(null)
    setMatchResult(null)
    setRoundWins([0, 0])
    setPhase('faction-select')
  }

  if (phase === 'faction-select') {
    return <FactionSelect onConfirm={handleFactionConfirm} />
  }

  if (phase === 'match-result' && matchResult) {
    return <ResultScreen result={matchResult} roundWins={roundWins} onPlayAgain={handlePlayAgain} />
  }

  if (!initialGameState) return null

  return (
    <GameStoreProvider initialState={initialGameState}>
      <GameScreen onMatchEnd={handleMatchEnd} />
    </GameStoreProvider>
  )
}
