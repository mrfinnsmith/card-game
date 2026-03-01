'use client'

import { useEffect, useMemo, useRef, useState } from 'react'
import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase'
import { FACTION_DATA } from '@/game/factionData'
import { FactionStep, LeaderStep } from '@/components/game/FactionSelect'
import type { LeaderId, PlayerFaction } from '@/types/game'
import type { Lobby } from '@/types/lobby'

const TIMEOUT_SECONDS = 60

function pickRandom<T>(items: T[]): T {
  return items[Math.floor(Math.random() * items.length)]
}

export default function LobbySelectPage({ params }: { params: { id: string } }) {
  const lobbyId = params.id
  const router = useRouter()
  const supabase = useMemo(() => createClient(), [])

  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [confirmed, setConfirmed] = useState(false)
  const [pending, setPending] = useState(false)
  const [secondsLeft, setSecondsLeft] = useState(TIMEOUT_SECONDS)
  const [selectedFaction, setSelectedFaction] = useState<PlayerFaction | null>(null)
  const [selectedLeader, setSelectedLeader] = useState<LeaderId | null>(null)

  const confirmedRef = useRef(false)
  const selectedFactionRef = useRef<PlayerFaction | null>(null)
  const selectedLeaderRef = useRef<LeaderId | null>(null)
  selectedFactionRef.current = selectedFaction
  selectedLeaderRef.current = selectedLeader

  async function submitSelection(faction: PlayerFaction, leader: LeaderId) {
    if (confirmedRef.current) return
    confirmedRef.current = true
    setPending(true)

    const res = await fetch(`/api/lobby/${lobbyId}/select`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ faction, leader }),
    })

    if (!res.ok) {
      confirmedRef.current = false
      setPending(false)
      const data = await res.json()
      setError(data.error ?? 'Failed to confirm selection')
      return
    }

    const data = await res.json()
    setConfirmed(true)
    setPending(false)

    if (data.game_id) {
      router.push(`/lobby/${lobbyId}/play`)
    }
  }

  const submitRef = useRef(submitSelection)
  submitRef.current = submitSelection

  // Verify lobby on mount; redirect if already past selection phase.
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

      const { data: lobby, error: lobbyError } = await supabase
        .from('cards_lobbies')
        .select('*')
        .eq('id', lobbyId)
        .single()

      if (!mounted) return
      if (lobbyError || !lobby) {
        setError('Lobby not found')
        setLoading(false)
        return
      }

      if (lobby.host_id !== user.id && lobby.guest_id !== user.id) {
        setError('You are not in this lobby')
        setLoading(false)
        return
      }

      if (lobby.status === 'in_progress') {
        router.push(`/lobby/${lobbyId}/play`)
        return
      }

      if (lobby.status !== 'selecting') {
        setError('This lobby is not in the selection phase')
        setLoading(false)
        return
      }

      setLoading(false)
    }

    init()
    return () => {
      mounted = false
    }
  }, [lobbyId, router, supabase])

  // Subscribe to lobby updates; redirect when both have confirmed.
  useEffect(() => {
    if (loading) return

    const channel = supabase
      .channel(`lobby:${lobbyId}`)
      .on(
        'postgres_changes',
        {
          event: 'UPDATE',
          schema: 'public',
          table: 'cards_lobbies',
          filter: `id=eq.${lobbyId}`,
        },
        (payload) => {
          const updated = payload.new as Lobby
          if (updated.status === 'in_progress') {
            router.push(`/lobby/${lobbyId}/play`)
          }
        },
      )
      .subscribe()

    return () => {
      supabase.removeChannel(channel)
    }
  }, [loading, lobbyId, router, supabase])

  // Countdown; auto-submit with a random selection on expiry.
  useEffect(() => {
    if (loading || confirmed) return

    const start = Date.now()
    const interval = setInterval(() => {
      const elapsed = Math.floor((Date.now() - start) / 1000)
      const remaining = Math.max(0, TIMEOUT_SECONDS - elapsed)
      setSecondsLeft(remaining)

      if (remaining === 0) {
        clearInterval(interval)
        if (!confirmedRef.current) {
          const faction = selectedFactionRef.current ?? pickRandom(FACTION_DATA).id
          const fd = FACTION_DATA.find((f) => f.id === faction)!
          const leader = selectedLeaderRef.current ?? pickRandom(fd.leaders).id
          void submitRef.current(faction, leader)
        }
      }
    }, 500)

    return () => clearInterval(interval)
  }, [loading, confirmed])

  function handleFactionClick(id: PlayerFaction) {
    setSelectedFaction(id)
    setSelectedLeader(null)
  }

  const factionData = FACTION_DATA.find((f) => f.id === selectedFaction) ?? null

  if (loading) {
    return (
      <main className="flex min-h-screen items-center justify-center">
        <p className="text-sm text-gray-400">Loading...</p>
      </main>
    )
  }

  if (error) {
    return (
      <main className="flex min-h-screen items-center justify-center p-6">
        <div className="space-y-3 text-center">
          <p className="text-sm text-red-600">{error}</p>
          <a href="/" className="text-sm text-blue-600 underline">
            Back to home
          </a>
        </div>
      </main>
    )
  }

  if (confirmed) {
    return (
      <main className="flex min-h-screen items-center justify-center">
        <div className="space-y-3 text-center">
          <div className="flex justify-center">
            <div className="h-8 w-8 animate-spin rounded-full border-2 border-gray-200 border-t-blue-600" />
          </div>
          <p className="text-sm text-gray-600">Waiting for opponent...</p>
        </div>
      </main>
    )
  }

  return (
    <div className="flex flex-col items-center justify-start min-h-screen bg-gray-50 p-6">
      <div className="w-full max-w-2xl space-y-8">
        <div className="flex items-center justify-between">
          <h1 className="text-xl font-bold text-gray-900">Choose your faction and leader</h1>
          <span
            className={[
              'text-sm font-medium tabular-nums',
              secondsLeft <= 10 ? 'text-red-500' : 'text-gray-400',
            ].join(' ')}
          >
            {secondsLeft}s
          </span>
        </div>

        <FactionStep selected={selectedFaction} onSelect={handleFactionClick} />

        {factionData && (
          <LeaderStep
            factionData={factionData}
            selected={selectedLeader}
            onSelect={setSelectedLeader}
          />
        )}

        {selectedFaction && selectedLeader && (
          <div className="flex justify-end">
            <button
              onClick={() => void submitSelection(selectedFaction, selectedLeader)}
              disabled={pending}
              className="px-6 py-2.5 rounded-lg bg-green-600 text-white text-sm font-semibold hover:bg-green-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {pending ? 'Confirming...' : 'Confirm'}
            </button>
          </div>
        )}
      </div>
    </div>
  )
}
