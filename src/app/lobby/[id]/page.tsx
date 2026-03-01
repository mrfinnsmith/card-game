'use client'

import { useEffect, useMemo, useState } from 'react'
import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase'
import type { Lobby } from '@/types/lobby'

interface Profile {
  user_id: string
  username: string
}

function ReadyBadge({ ready }: { ready: boolean }) {
  return (
    <span
      className={[
        'rounded-full px-2 py-0.5 text-xs font-medium',
        ready ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-400',
      ].join(' ')}
    >
      {ready ? 'Ready' : 'Not ready'}
    </span>
  )
}

function PlayerRow({
  label,
  username,
  ready,
}: {
  label: string
  username: string | null
  ready: boolean
}) {
  return (
    <div className="flex items-center justify-between px-4 py-3">
      <div>
        <p className="text-xs text-gray-400">{label}</p>
        {username !== null ? (
          <p className="text-sm font-semibold text-gray-900">{username}</p>
        ) : (
          <p className="text-sm text-gray-400">Waiting for player...</p>
        )}
      </div>
      {username !== null && <ReadyBadge ready={ready} />}
    </div>
  )
}

export default function WaitingRoomPage({ params }: { params: { id: string } }) {
  const lobbyId = params.id
  const router = useRouter()
  const supabase = useMemo(() => createClient(), [])

  const [lobby, setLobby] = useState<Lobby | null>(null)
  const [profiles, setProfiles] = useState<Record<string, string>>({})
  const [currentUserId, setCurrentUserId] = useState<string | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [actionPending, setActionPending] = useState(false)

  useEffect(() => {
    let mounted = true

    async function init() {
      const {
        data: { user },
      } = await supabase.auth.getUser()
      if (!mounted) return
      if (!user) {
        router.push('/login')
        return
      }
      setCurrentUserId(user.id)

      const { data: lobbyData, error: lobbyError } = await supabase
        .from('cards_lobbies')
        .select('*')
        .eq('id', lobbyId)
        .single()

      if (!mounted) return
      if (lobbyError || !lobbyData) {
        setError('Lobby not found')
        setLoading(false)
        return
      }

      if (lobbyData.host_id !== user.id && lobbyData.guest_id !== user.id) {
        setError('You are not in this lobby')
        setLoading(false)
        return
      }

      setLobby(lobbyData as Lobby)
      setLoading(false)

      const ids = [lobbyData.host_id, lobbyData.guest_id].filter(Boolean) as string[]
      const { data: profileData } = await supabase
        .from('cards_profiles')
        .select('user_id, username')
        .in('user_id', ids)

      if (mounted && profileData) {
        const map: Record<string, string> = {}
        profileData.forEach((p: Profile) => {
          map[p.user_id] = p.username
        })
        setProfiles(map)
      }
    }

    init()
    return () => {
      mounted = false
    }
  }, [lobbyId, router, supabase])

  useEffect(() => {
    const channel = supabase
      .channel(`lobby:${lobbyId}`)
      .on(
        'postgres_changes',
        {
          event: '*',
          schema: 'public',
          table: 'cards_lobbies',
          filter: `id=eq.${lobbyId}`,
        },
        async (payload) => {
          const updated = payload.new as Lobby
          setLobby(updated)

          const ids = [updated.host_id, updated.guest_id].filter(Boolean) as string[]
          const { data: profileData } = await supabase
            .from('cards_profiles')
            .select('user_id, username')
            .in('user_id', ids)
          if (profileData) {
            setProfiles((prev) => {
              const next = { ...prev }
              profileData.forEach((p: Profile) => {
                next[p.user_id] = p.username
              })
              return next
            })
          }

          if (updated.status === 'selecting') {
            router.push(`/lobby/${lobbyId}/select`)
          }
        },
      )
      .subscribe()

    return () => {
      supabase.removeChannel(channel)
    }
  }, [lobbyId, router, supabase])

  async function handleToggleReady() {
    setActionPending(true)
    await fetch(`/api/lobby/${lobbyId}/ready`, { method: 'PATCH' })
    setActionPending(false)
  }

  async function handleStart() {
    setActionPending(true)
    const res = await fetch(`/api/lobby/${lobbyId}/start`, { method: 'POST' })
    if (!res.ok) {
      const data = await res.json()
      setError(data.error ?? 'Failed to start game')
    }
    setActionPending(false)
  }

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
          <a href="/lobby" className="text-sm text-blue-600 underline">
            Back to lobby
          </a>
        </div>
      </main>
    )
  }

  if (!lobby || !currentUserId) return null

  if (lobby.status === 'selecting') {
    return (
      <main className="flex min-h-screen items-center justify-center">
        <p className="text-sm text-gray-500">Match starting...</p>
      </main>
    )
  }

  const isHost = currentUserId === lobby.host_id
  const myReady = isHost ? lobby.host_ready : lobby.guest_ready
  const bothReady = lobby.host_ready && lobby.guest_ready && !!lobby.guest_id

  return (
    <main className="flex min-h-screen items-center justify-center p-6">
      <div className="w-full max-w-sm space-y-6">
        {isHost && (
          <div className="text-center">
            <p className="mb-1 text-xs uppercase tracking-widest text-gray-400">Join code</p>
            <p className="font-mono text-4xl font-bold tracking-widest text-gray-900">
              {lobby.join_code}
            </p>
            <p className="mt-1 text-xs text-gray-400">Share this code with your opponent</p>
          </div>
        )}

        <div className="divide-y divide-gray-100 rounded-xl border border-gray-200 bg-white">
          <PlayerRow
            label="Host"
            username={profiles[lobby.host_id] ?? '...'}
            ready={lobby.host_ready}
          />
          <PlayerRow
            label="Guest"
            username={lobby.guest_id ? (profiles[lobby.guest_id] ?? '...') : null}
            ready={lobby.guest_ready}
          />
        </div>

        <div className="space-y-2">
          <button
            onClick={handleToggleReady}
            disabled={actionPending}
            className={[
              'w-full rounded-lg px-4 py-3 text-sm font-semibold transition-colors',
              myReady
                ? 'border border-green-300 bg-green-50 text-green-700 hover:bg-green-100'
                : 'bg-blue-600 text-white hover:bg-blue-700',
              'disabled:cursor-not-allowed disabled:opacity-50',
            ].join(' ')}
          >
            {myReady ? 'Cancel ready' : "I'm ready"}
          </button>

          {isHost && (
            <button
              onClick={handleStart}
              disabled={!bothReady || actionPending}
              className="w-full rounded-lg bg-gray-900 px-4 py-3 text-sm font-semibold text-white transition-colors hover:bg-gray-800 disabled:cursor-not-allowed disabled:opacity-50"
            >
              Start game
            </button>
          )}
        </div>
      </div>
    </main>
  )
}
