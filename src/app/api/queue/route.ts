import { NextResponse } from 'next/server'
import { createServerSupabaseClient } from '@/lib/supabase-server'

export async function POST() {
  const supabase = createServerSupabaseClient()
  const {
    data: { user },
  } = await supabase.auth.getUser()

  if (!user) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  }

  const displayName = user.user_metadata?.display_name ?? user.user_metadata?.username ?? 'Player'

  const { data, error } = await supabase.rpc('cards_join_queue', {
    p_display_name: displayName,
  })

  if (error) {
    return NextResponse.json({ error: 'Failed to join queue' }, { status: 500 })
  }

  return NextResponse.json(data)
}

export async function DELETE() {
  const supabase = createServerSupabaseClient()
  const {
    data: { user },
  } = await supabase.auth.getUser()

  if (!user) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  }

  await supabase
    .from('cards_quick_match_queue')
    .delete()
    .eq('user_id', user.id)
    .eq('status', 'waiting')

  return NextResponse.json({ ok: true })
}
