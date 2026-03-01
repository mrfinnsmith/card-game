'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import Link from 'next/link'

export default function LobbyPage() {
  const router = useRouter()
  const [code, setCode] = useState('')
  const [joinError, setJoinError] = useState<string | null>(null)
  const [creating, setCreating] = useState(false)
  const [joining, setJoining] = useState(false)

  async function handleCreate() {
    setCreating(true)
    const res = await fetch('/api/lobby', { method: 'POST' })
    const data = await res.json()
    setCreating(false)
    if (res.ok) {
      router.push(`/lobby/${data.id}`)
    }
  }

  async function handleJoin(e: React.FormEvent) {
    e.preventDefault()
    setJoinError(null)
    setJoining(true)
    const res = await fetch('/api/lobby/join', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ join_code: code }),
    })
    const data = await res.json()
    setJoining(false)
    if (res.ok) {
      router.push(`/lobby/${data.id}`)
    } else {
      setJoinError(data.error ?? 'Unable to join lobby')
    }
  }

  return (
    <main className="flex min-h-screen items-center justify-center p-6">
      <div className="w-full max-w-sm space-y-8">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Multiplayer</h1>
          <p className="mt-1 text-sm text-gray-500">Create a game or join with a code.</p>
        </div>

        <div className="space-y-3">
          <button
            onClick={handleCreate}
            disabled={creating}
            className="w-full rounded-lg bg-blue-600 px-4 py-3 text-sm font-semibold text-white transition-colors hover:bg-blue-700 disabled:opacity-50"
          >
            {creating ? 'Creating...' : 'Create game'}
          </button>

          <div className="relative flex items-center">
            <div className="flex-grow border-t border-gray-200" />
            <span className="mx-3 flex-shrink text-xs text-gray-400">or</span>
            <div className="flex-grow border-t border-gray-200" />
          </div>

          <form onSubmit={handleJoin} className="space-y-2">
            <input
              type="text"
              placeholder="Enter code"
              value={code}
              onChange={(e) => setCode(e.target.value.toUpperCase().slice(0, 6))}
              className="w-full rounded-lg border border-gray-300 px-3 py-2.5 text-center font-mono text-lg font-semibold uppercase tracking-widest placeholder:font-sans placeholder:text-sm placeholder:font-normal placeholder:tracking-normal placeholder:text-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-500"
              maxLength={6}
              autoComplete="off"
              spellCheck={false}
            />
            {joinError && <p className="text-sm text-red-600">{joinError}</p>}
            <button
              type="submit"
              disabled={joining || code.length !== 6}
              className="w-full rounded-lg border border-gray-300 px-4 py-3 text-sm font-semibold text-gray-700 transition-colors hover:bg-gray-50 disabled:cursor-not-allowed disabled:opacity-50"
            >
              {joining ? 'Joining...' : 'Join game'}
            </button>
          </form>
        </div>

        <Link href="/" className="block text-center text-sm text-gray-400 hover:text-gray-600">
          Back to home
        </Link>
      </div>
    </main>
  )
}
