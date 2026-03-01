import { NextRequest, NextResponse } from 'next/server'
import { createServerSupabaseClient } from '@/lib/supabase-server'

export async function PATCH(request: NextRequest, { params }: { params: { id: string } }) {
  const supabase = createServerSupabaseClient()
  const {
    data: { user },
  } = await supabase.auth.getUser()

  if (!user) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  }

  const { data: lobby, error: fetchError } = await supabase
    .from('cards_lobbies')
    .select('id, host_id, guest_id, host_ready, guest_ready, status')
    .eq('id', params.id)
    .single()

  if (fetchError || !lobby) {
    return NextResponse.json({ error: 'Lobby not found' }, { status: 404 })
  }

  if (lobby.status !== 'waiting') {
    return NextResponse.json({ error: 'Lobby is not in waiting state' }, { status: 400 })
  }

  let update: { host_ready: boolean } | { guest_ready: boolean }
  if (lobby.host_id === user.id) {
    update = { host_ready: !lobby.host_ready }
  } else if (lobby.guest_id === user.id) {
    update = { guest_ready: !lobby.guest_ready }
  } else {
    return NextResponse.json({ error: 'You are not in this lobby' }, { status: 403 })
  }

  const { data: updated, error: updateError } = await supabase
    .from('cards_lobbies')
    .update(update)
    .eq('id', params.id)
    .select('id, host_ready, guest_ready')
    .single()

  if (updateError || !updated) {
    return NextResponse.json({ error: 'Failed to update ready state' }, { status: 500 })
  }

  return NextResponse.json(updated)
}
