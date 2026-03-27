import { NextRequest, NextResponse } from 'next/server'
import { createServerSupabaseClient } from '@/lib/supabase-server'

export async function POST(_request: NextRequest, { params }: { params: { id: string } }) {
  const supabase = createServerSupabaseClient()
  const {
    data: { user },
  } = await supabase.auth.getUser()

  if (!user) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })

  const { data: game, error: gameError } = await supabase
    .from('cards_games')
    .select('id, lobby_id, status')
    .eq('id', params.id)
    .single()

  if (gameError || !game) return NextResponse.json({ error: 'Game not found' }, { status: 404 })
  if (game.status !== 'active')
    return NextResponse.json({ error: 'Game is not active' }, { status: 400 })

  const { data: lobby, error: lobbyError } = await supabase
    .from('cards_lobbies')
    .select('host_id, guest_id')
    .eq('id', game.lobby_id)
    .single()

  if (lobbyError || !lobby) return NextResponse.json({ error: 'Lobby not found' }, { status: 404 })

  const playerIndex: 0 | 1 | null =
    user.id === lobby.host_id ? 0 : user.id === lobby.guest_id ? 1 : null

  if (playerIndex === null) return NextResponse.json({ error: 'Forbidden' }, { status: 403 })

  // Only update if still active — guards against a race where the game ended naturally
  // at the same time the disconnect timer fired.
  const { error: updateError } = await supabase
    .from('cards_games')
    .update({
      status: 'forfeited',
      result: { type: 'forfeit', winner_id: user.id },
    })
    .eq('id', params.id)
    .eq('status', 'active')

  if (updateError) return NextResponse.json({ error: 'Failed to record forfeit' }, { status: 500 })

  const broadcastUrl = `${process.env.NEXT_PUBLIC_SUPABASE_URL}/realtime/v1/api/broadcast`
  await fetch(broadcastUrl, {
    method: 'POST',
    headers: {
      apikey: process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY!,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      messages: [
        {
          topic: `game:${params.id}`,
          event: 'forfeit',
          payload: { winner_player_index: playerIndex },
          private: false,
        },
      ],
    }),
  }).catch(console.error)

  return NextResponse.json({ ok: true })
}
