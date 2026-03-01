import { NextRequest, NextResponse } from 'next/server'
import { createServerSupabaseClient } from '@/lib/supabase-server'

const ERROR_MESSAGES: Record<string, string> = {
  not_found: 'Lobby not found',
  expired: 'This lobby has expired',
  unavailable: 'This lobby is no longer available',
  full: 'This lobby is full',
  own_lobby: 'You cannot join your own lobby',
}

const ERROR_STATUSES: Record<string, number> = {
  not_found: 404,
  expired: 404,
  unavailable: 400,
  full: 400,
  own_lobby: 400,
}

export async function POST(request: NextRequest) {
  const supabase = createServerSupabaseClient()
  const {
    data: { user },
  } = await supabase.auth.getUser()

  if (!user) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  }

  const body = await request.json()
  const joinCode = typeof body.join_code === 'string' ? body.join_code : ''
  if (!joinCode) {
    return NextResponse.json({ error: 'Join code is required' }, { status: 400 })
  }

  const { data, error } = await supabase.rpc('cards_join_lobby', { p_join_code: joinCode })

  if (error) {
    return NextResponse.json({ error: 'Failed to join lobby' }, { status: 500 })
  }

  const result = data as { lobby_id?: string; error?: string }

  if (result.error) {
    return NextResponse.json(
      { error: ERROR_MESSAGES[result.error] ?? 'Unable to join lobby' },
      { status: ERROR_STATUSES[result.error] ?? 400 },
    )
  }

  return NextResponse.json({ id: result.lobby_id })
}
