import Link from 'next/link'

export default function Home() {
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
            href="/lobby"
            className="block w-full rounded-lg border border-gray-300 px-4 py-3 text-sm font-semibold text-gray-700 transition-colors hover:bg-gray-50"
          >
            Multiplayer
          </Link>
        </div>
      </div>
    </main>
  )
}
