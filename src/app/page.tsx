'use client'

import { useEffect, useState } from 'react'
import Link from 'next/link'
import { createClient } from '@/lib/supabase'

export default function Home() {
  const [name, setName] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  // null = loading, false = no session, true = has session
  const [hasSession, setHasSession] = useState<boolean | null>(null)
  const [isRegistered, setIsRegistered] = useState(false)

  useEffect(() => {
    const supabase = createClient()
    supabase.auth.getUser().then(({ data: { user } }) => {
      if (!user) {
        setHasSession(false)
        return
      }
      setHasSession(true)
      setIsRegistered(!(user.is_anonymous ?? false))
    })
  }, [])

  async function handlePlay(e: React.FormEvent) {
    e.preventDefault()
    const trimmed = name.trim()
    if (!trimmed) return
    setError(null)
    setLoading(true)
    const supabase = createClient()
    const { error: signInError } = await supabase.auth.signInAnonymously({
      options: { data: { display_name: trimmed } },
    })
    setLoading(false)
    if (signInError) {
      setError('Something went wrong. Please try again.')
      return
    }
    // Anonymous users are not registered; update state directly without a full refresh.
    setHasSession(true)
    setIsRegistered(false)
  }

  if (hasSession === null) return null

  if (!hasSession) {
    return (
      <main className="flex min-h-screen items-center justify-center p-6">
        <div className="w-full max-w-xs space-y-6">
          <div className="text-center">
            <h1 className="text-2xl font-bold text-gray-900">Card Game</h1>
            <p className="mt-1 text-sm text-gray-500">Enter a name to start playing.</p>
          </div>
          <form onSubmit={handlePlay} className="space-y-3">
            <input
              type="text"
              placeholder="Your name"
              value={name}
              onChange={(e) => setName(e.target.value)}
              maxLength={20}
              className="w-full rounded-lg border border-gray-300 px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
              autoFocus
            />
            {error && <p className="text-sm text-red-600">{error}</p>}
            <button
              type="submit"
              disabled={loading || !name.trim()}
              className="w-full rounded-lg bg-blue-600 px-4 py-3 text-sm font-semibold text-white transition-colors hover:bg-blue-700 disabled:cursor-not-allowed disabled:opacity-50"
            >
              {loading ? 'Starting...' : 'Play'}
            </button>
          </form>
          <div className="relative flex items-center">
            <div className="flex-grow border-t border-gray-200" />
            <span className="mx-3 flex-shrink text-xs text-gray-400">have an account?</span>
            <div className="flex-grow border-t border-gray-200" />
          </div>
          <Link
            href="/login"
            className="block w-full rounded-lg border border-gray-300 px-4 py-3 text-center text-sm font-semibold text-gray-700 transition-colors hover:bg-gray-50"
          >
            Log in
          </Link>
        </div>
      </main>
    )
  }

  return (
    <main className="flex min-h-screen items-center justify-center p-6">
      <div className="w-full max-w-xs space-y-6 text-center">
        <h1 className="text-2xl font-bold text-gray-900">Card Game</h1>
        <div className="space-y-2">
          <Link
            href="/play"
            className="block w-full rounded-lg bg-blue-600 px-4 py-3 text-sm font-semibold text-white transition-colors hover:bg-blue-700"
          >
            Play solo
          </Link>
          <Link
            href="/queue"
            className="block w-full rounded-lg border border-gray-300 px-4 py-3 text-sm font-semibold text-gray-700 transition-colors hover:bg-gray-50"
          >
            Quick match
          </Link>
          {isRegistered && (
            <Link
              href="/lobby"
              className="block w-full rounded-lg border border-gray-300 px-4 py-3 text-sm font-semibold text-gray-700 transition-colors hover:bg-gray-50"
            >
              Play with a friend
            </Link>
          )}
        </div>
        {!isRegistered && (
          <div className="space-y-1 text-xs text-gray-400">
            <p>
              <Link href="/register" className="underline hover:text-gray-600">
                Create an account
              </Link>{' '}
              to invite friends and track stats.
            </p>
            <p>
              Already have one?{' '}
              <Link href="/login" className="underline hover:text-gray-600">
                Log in
              </Link>
            </p>
          </div>
        )}
      </div>
    </main>
  )
}
