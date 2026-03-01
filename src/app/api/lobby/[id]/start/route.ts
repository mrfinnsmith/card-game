import { NextRequest, NextResponse } from 'next/server'
import { createServerSupabaseClient } from '@/lib/supabase-server'

export async function POST(request: NextRequest, { params }: { params: { id: string } }) {
  const supabase = createServerSupabaseClient()
  const {
    data: { user },
  } = await supabase.auth.getUser()

  if (!user) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  }

  if (user.is_anonymous) {
    return NextResponse.json(
      { error: 'Invite lobbies require a registered account' },
      { status: 403 },
    )
  }

  const { data: lobby, error: fetchError } = await supabase
    .from('cards_lobbies')
    .select('id, host_id, guest_id, host_ready, guest_ready, status')
    .eq('id', params.id)
    .single()

  if (fetchError || !lobby) {
    return NextResponse.json({ error: 'Lobby not found' }, { status: 404 })
  }

  if (lobby.host_id !== user.id) {
    return NextResponse.json({ error: 'Only the host can start the match' }, { status: 403 })
  }

  if (!lobby.guest_id) {
    return NextResponse.json({ error: 'Waiting for a second player' }, { status: 400 })
  }

  if (!lobby.host_ready || !lobby.guest_ready) {
    return NextResponse.json({ error: 'Both players must be ready' }, { status: 400 })
  }

  if (lobby.status !== 'waiting') {
    return NextResponse.json({ error: 'Match has already started' }, { status: 400 })
  }

  const { error: updateError } = await supabase
    .from('cards_lobbies')
    .update({ status: 'selecting' })
    .eq('id', params.id)

  if (updateError) {
    return NextResponse.json({ error: 'Failed to start match' }, { status: 500 })
  }

  return NextResponse.json({ id: params.id })
}
