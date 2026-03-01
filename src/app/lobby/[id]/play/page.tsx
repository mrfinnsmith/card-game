'use client'

import { useCallback, useEffect, useMemo, useRef, useState } from 'react'
import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase'
import { Board } from '@/components/game/Board'
import { DiscardPile } from '@/components/game/DiscardPile'
import { PlayerHand, OpponentHand } from '@/components/game/Hand'
import { SelectionOverlay } from '@/components/game/SelectionOverlay'
import { dismissReveal, getMatchResult, isMatchOver } from '@/game/stateMachine'
import { GameStoreProvider, useGameStore, useGameStoreApi } from '@/store/gameStore'
import { hydrateMaskedState, maskState } from '@/lib/maskState'
import type { MaskedGameState } from '@/lib/maskState'
import type { GameState, MatchResult, RowType } from '@/types/game'
import type { MovePayload } from '@/lib/validateMove'

// ---- multiplayer game screen ----

function MultiplayerGameScreen({
  gameId,
  playerIndex,
  onMatchEnd,
}: {
  gameId: string
  playerIndex: 0 | 1
  onMatchEnd: (result: MatchResult, roundWins: [number, number]) => void
}) {
  const supabase = useMemo(() => createClient(), [])
  const storeApi = useGameStoreApi()
  const state = useGameStore((s) => s)
  const [submitting, setSubmitting] = useState(false)
  const [moveError, setMoveError] = useState<string | null>(null)
  const [bannerRound, setBannerRound] = useState<number | null>(null)
  const prevRoundRef = useRef(state.round)
  const onMatchEndRef = useRef(onMatchEnd)
  onMatchEndRef.current = onMatchEnd

  // Subscribe to the game's Realtime broadcast channel.
  useEffect(() => {
    const channel = supabase
      .channel(`game:${gameId}`)
      .on('broadcast', { event: 'state_update' }, (msg) => {
        const payload = msg.payload as { for_player: number; state: MaskedGameState }
        if (payload.for_player !== playerIndex) return

        const hydrated = hydrateMaskedState(payload.state, playerIndex)
        storeApi.setState(hydrated, true)

        if (isMatchOver(hydrated)) {
          const result = getMatchResult(hydrated)
          if (result) onMatchEndRef.current(result, hydrated.roundWins)
        }
      })
      .subscribe((status, err) => {
        if (status === 'CHANNEL_ERROR') console.error('Realtime channel error:', err)
        else if (status === 'TIMED_OUT') console.error('Realtime channel timed out')
      })

    return () => {
      supabase.removeChannel(channel)
    }
  }, [gameId, playerIndex, supabase, storeApi])

  // Show round banner when a new round starts (not round 1).
  useEffect(() => {
    if (state.round > prevRoundRef.current) {
      if (state.round > 1) setBannerRound(state.round)
      prevRoundRef.current = state.round
    }
  }, [state.round])

  useEffect(() => {
    if (bannerRound === null) return
    const timer = setTimeout(() => setBannerRound(null), 2000)
    return () => clearTimeout(timer)
  }, [bannerRound])

  async function submitMove(payload: MovePayload) {
    setMoveError(null)
    setSubmitting(true)
    const res = await fetch(`/api/game/${gameId}/move`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    })
    const data = await res.json()
    setSubmitting(false)
    if (!res.ok) {
      setMoveError(data.error ?? 'Move failed')
      return
    }
    if (data.state) {
      const hydrated = hydrateMaskedState(data.state, playerIndex)
      storeApi.setState(hydrated, true)
      if (isMatchOver(hydrated)) {
        const result = getMatchResult(hydrated)
        if (result) onMatchEndRef.current(result, hydrated.roundWins)
      }
    }
  }

  const isMyTurn = state.activePlayer === 0 && !state.players[0].passed
  const inDefault = state.selectionMode === 'default'
  const canAct = isMyTurn && !submitting && inDefault && !isMatchOver(state)
  const canPass = canAct
  const canUseLeader = canAct && !state.players[0].leaderAbilityUsed && !!state.players[0].leader

  return (
    <div className="flex flex-col min-h-screen bg-gray-100 p-3 gap-2">
      <div className="text-center py-1">
        <span
          className={[
            'text-xs font-medium px-3 py-1 rounded-full',
            state.activePlayer === 0 ? 'bg-blue-100 text-blue-700' : 'bg-gray-100 text-gray-500',
          ].join(' ')}
        >
          {state.selectionMode === 'mulligan'
            ? 'Mulligan phase'
            : state.activePlayer === 0
              ? 'Your turn'
              : "Opponent's turn"}
        </span>
      </div>

      {moveError && (
        <div className="text-center">
          <span className="text-xs text-red-600 bg-red-50 px-3 py-1 rounded-full">{moveError}</span>
        </div>
      )}

      <div className="flex items-center gap-2">
        <DiscardPile playerIndex={1} />
        <OpponentHand />
      </div>

      <div className="flex-1">
        <Board />
      </div>

      <div className="flex items-end gap-2">
        <DiscardPile playerIndex={0} />
        <div className="flex-1 overflow-x-auto">
          <PlayerHand
            onPlay={
              canAct ? (cardId) => void submitMove({ action: 'playCard', cardId }) : undefined
            }
          />
        </div>
        <button
          onClick={() => void submitMove({ action: 'leaderAbility' })}
          disabled={!canUseLeader}
          className={[
            'shrink-0 px-4 py-2 rounded-lg border text-sm font-semibold transition-colors self-center',
            canUseLeader
              ? 'border-purple-300 bg-white text-purple-600 hover:bg-purple-50'
              : 'border-gray-200 bg-gray-50 text-gray-300 cursor-default',
          ].join(' ')}
        >
          Leader
        </button>
        <button
          onClick={() => void submitMove({ action: 'pass' })}
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
        onMedicSelect={(cardId) => void submitMove({ action: 'medic', cardId })}
        onDecoySelect={(cardId) => void submitMove({ action: 'decoy', cardId })}
        onAgileSelect={(row: RowType) => void submitMove({ action: 'agile', rowChoice: row })}
        onWarCrySelect={(row: RowType) => void submitMove({ action: 'warCry', rowChoice: row })}
        onMulliganSwap={(cardId) => void submitMove({ action: 'mulligan', cardId })}
        onMulliganConfirm={() => void submitMove({ action: 'confirmMulligan' })}
        onLeaderB4Select={(cardId) => void submitMove({ action: 'leaderB4', cardId })}
        onLeaderD2Select={(cardId) => void submitMove({ action: 'leaderD2', cardId })}
        onLeaderD4DiscardSelect={(cardId) => void submitMove({ action: 'leaderD4discard', cardId })}
        onLeaderD4DrawSelect={(cardId) => void submitMove({ action: 'leaderD4draw', cardId })}
        onLeaderD5Select={(cardId) => void submitMove({ action: 'leaderD5', cardId })}
        onDismissReveal={() => storeApi.setState(dismissReveal(storeApi.getState()))}
      />

      {submitting && (
        <div className="fixed bottom-4 right-4 bg-white border border-gray-200 rounded-lg px-4 py-2 shadow-sm text-xs text-gray-500">
          Sending...
        </div>
      )}

      {bannerRound !== null && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-gray-50/80 backdrop-blur-sm">
          <div className="bg-white rounded-xl border border-gray-200 shadow-lg px-10 py-6 text-center">
            <p className="text-xs uppercase tracking-widest text-gray-400 mb-1">Starting</p>
            <p className="text-3xl font-bold text-gray-900">Round {bannerRound}</p>
          </div>
        </div>
      )}
    </div>
  )
}

// ---- result screen ----

function ResultScreen({ result, roundWins }: { result: MatchResult; roundWins: [number, number] }) {
  const router = useRouter()
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
          onClick={() => router.push('/')}
          className="w-full px-4 py-2.5 rounded-lg bg-blue-600 text-white text-sm font-semibold hover:bg-blue-700 transition-colors"
        >
          Back to home
        </button>
      </div>
    </div>
  )
}

// ---- page ----

type Phase = 'loading' | 'playing' | 'match-result'

export default function LobbyPlayPage({ params }: { params: { id: string } }) {
  const lobbyId = params.id
  const router = useRouter()
  const supabase = useMemo(() => createClient(), [])

  const [phase, setPhase] = useState<Phase>('loading')
  const [pageError, setPageError] = useState<string | null>(null)
  const [gameId, setGameId] = useState<string | null>(null)
  const [playerIndex, setPlayerIndex] = useState<0 | 1 | null>(null)
  const [initialState, setInitialState] = useState<GameState | null>(null)
  const [matchResult, setMatchResult] = useState<MatchResult | null>(null)
  const [roundWins, setRoundWins] = useState<[number, number]>([0, 0])

  useEffect(() => {
    let mounted = true

    async function init() {
      const {
        data: { user },
      } = await supabase.auth.getUser()
      if (!mounted) return
      if (!user) {
        router.push('/')
        return
      }

      const { data: lobby, error: lobbyErr } = await supabase
        .from('cards_lobbies')
        .select('host_id, guest_id')
        .eq('id', lobbyId)
        .single()

      if (!mounted) return
      if (lobbyErr || !lobby) {
        setPageError('Lobby not found')
        return
      }

      const index: 0 | 1 | null =
        user.id === lobby.host_id ? 0 : user.id === lobby.guest_id ? 1 : null
      if (index === null) {
        setPageError('You are not in this lobby')
        return
      }

      const { data: game, error: gameErr } = await supabase
        .from('cards_games')
        .select('id, status, state')
        .eq('lobby_id', lobbyId)
        .in('status', ['active', 'completed'])
        .order('created_at', { ascending: false })
        .limit(1)
        .single()

      if (!mounted) return
      if (gameErr || !game) {
        setPageError('Game not found')
        return
      }

      const raw = game.state as GameState
      const hydrated = hydrateMaskedState(maskState(raw, index), index)

      setGameId(game.id as string)
      setPlayerIndex(index)
      setInitialState(hydrated)

      if (game.status === 'completed' || isMatchOver(hydrated)) {
        const result = getMatchResult(hydrated)
        if (result) {
          setMatchResult(result)
          setRoundWins(hydrated.roundWins)
          setPhase('match-result')
          return
        }
      }

      setPhase('playing')
    }

    init()
    return () => {
      mounted = false
    }
  }, [lobbyId, router, supabase])

  const handleMatchEnd = useCallback((result: MatchResult, wins: [number, number]) => {
    setMatchResult(result)
    setRoundWins(wins)
    setPhase('match-result')
  }, [])

  if (phase === 'loading' && !pageError) {
    return (
      <main className="flex min-h-screen items-center justify-center">
        <p className="text-sm text-gray-400">Loading game...</p>
      </main>
    )
  }

  if (pageError) {
    return (
      <main className="flex min-h-screen items-center justify-center p-6">
        <div className="space-y-3 text-center">
          <p className="text-sm text-red-600">{pageError}</p>
          <a href="/" className="text-sm text-blue-600 underline">
            Back to home
          </a>
        </div>
      </main>
    )
  }

  if (phase === 'match-result' && matchResult) {
    return <ResultScreen result={matchResult} roundWins={roundWins} />
  }

  if (!initialState || gameId === null || playerIndex === null) return null

  return (
    <GameStoreProvider initialState={initialState}>
      <MultiplayerGameScreen
        gameId={gameId}
        playerIndex={playerIndex}
        onMatchEnd={handleMatchEnd}
      />
    </GameStoreProvider>
  )
}
