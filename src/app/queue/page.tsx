'use client'

import { useEffect, useMemo, useRef, useState } from 'react'
import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase'

interface QueueRow {
  status: string
  lobby_id: string | null
}

export default function QueuePage() {
  const router = useRouter()
  const supabase = useMemo(() => createClient(), [])

  const [count, setCount] = useState<number | null>(null)
  const [waiting, setWaiting] = useState(false)
  const [cancelling, setCancelling] = useState(false)
  const userId = useRef<string | null>(null)

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
      userId.current = user.id

      const countRes = await fetch('/api/queue/count')
      if (mounted && countRes.ok) {
        const json = await countRes.json()
        setCount(json.count)
      }

      const res = await fetch('/api/queue', { method: 'POST' })
      if (!mounted) return
      if (!res.ok) return

      const data = await res.json()

      if (data.lobby_id) {
        router.push(`/lobby/${data.lobby_id}/select`)
        return
      }

      if (data.waiting) {
        setWaiting(true)
      }
    }

    init()
    return () => {
      mounted = false
    }
  }, [router, supabase])

  useEffect(() => {
    if (!waiting || !userId.current) return

    const uid = userId.current
    const channel = supabase
      .channel(`queue:${uid}`)
      .on(
        'postgres_changes',
        {
          event: 'UPDATE',
          schema: 'public',
          table: 'cards_quick_match_queue',
          filter: `user_id=eq.${uid}`,
        },
        (payload) => {
          const row = payload.new as QueueRow
          if (row.status === 'matched' && row.lobby_id) {
            router.push(`/lobby/${row.lobby_id}/select`)
          }
        },
      )
      .subscribe()

    return () => {
      supabase.removeChannel(channel)
    }
  }, [waiting, router, supabase])

  async function handleCancel() {
    setCancelling(true)
    await fetch('/api/queue', { method: 'DELETE' })
    router.push('/')
  }

  if (count === null) {
    return (
      <main className="flex min-h-screen items-center justify-center">
        <p className="text-sm text-gray-400">Connecting...</p>
      </main>
    )
  }

  return (
    <main className="flex min-h-screen items-center justify-center p-6">
      <div className="w-full max-w-xs space-y-6 text-center">
        <div className="space-y-2">
          <p className="text-lg font-semibold text-gray-900">
            {waiting ? 'Looking for opponent...' : 'Joining queue...'}
          </p>
          <p className="text-sm text-gray-500">
            {count === 1 ? '1 player' : `${count} players`} in queue
          </p>
        </div>

        <div className="flex justify-center">
          <div className="h-8 w-8 animate-spin rounded-full border-2 border-gray-200 border-t-blue-600" />
        </div>

        {waiting && (
          <button
            onClick={handleCancel}
            disabled={cancelling}
            className="w-full rounded-lg border border-gray-300 px-4 py-3 text-sm font-semibold text-gray-700 transition-colors hover:bg-gray-50 disabled:cursor-not-allowed disabled:opacity-50"
          >
            {cancelling ? 'Cancelling...' : 'Cancel'}
          </button>
        )}
      </div>
    </main>
  )
}
