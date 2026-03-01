import type { GameState } from '@/types/game'
import { maskState } from './maskState'

/**
 * Broadcasts masked game state to both players via Supabase Realtime REST API.
 *
 * Sends both player-specific messages in a single HTTP request. Each message
 * is masked so the recipient only receives their own hand and relevant state.
 */
export async function broadcastGameState(gameId: string, state: GameState): Promise<void> {
  const url = `${process.env.NEXT_PUBLIC_SUPABASE_URL}/realtime/v1/api/broadcast`
  const apiKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!

  const res = await fetch(url, {
    method: 'POST',
    headers: {
      apikey: apiKey,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      messages: [
        {
          topic: `game:${gameId}`,
          event: 'state_update',
          payload: { for_player: 0, state: maskState(state, 0) },
          private: false,
        },
        {
          topic: `game:${gameId}`,
          event: 'state_update',
          payload: { for_player: 1, state: maskState(state, 1) },
          private: false,
        },
      ],
    }),
  })

  if (!res.ok) {
    const body = await res.text().catch(() => '')
    console.error(`broadcastGameState failed (${res.status}):`, body)
  }
}
