import { NextResponse } from 'next/server'
import { createServerSupabaseClient } from '@/lib/supabase-server'

const JOIN_CODE_CHARS = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'

function generateJoinCode(): string {
  let code = ''
  for (let i = 0; i < 6; i++) {
    code += JOIN_CODE_CHARS[Math.floor(Math.random() * JOIN_CODE_CHARS.length)]
  }
  return code
}

export async function POST() {
  const supabase = createServerSupabaseClient()
  const {
    data: { user },
  } = await supabase.auth.getUser()

  if (!user) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  }

  // Retry up to 5 times on join_code uniqueness collision (astronomically rare).
  for (let attempt = 0; attempt < 5; attempt++) {
    const join_code = generateJoinCode()
    const { data, error } = await supabase
      .from('cards_lobbies')
      .insert({ host_id: user.id, join_code })
      .select('id, join_code')
      .single()

    if (!error) {
      return NextResponse.json({ id: data.id, join_code: data.join_code })
    }

    const isUnique = error.message.includes('unique') || error.message.includes('duplicate')
    if (!isUnique) {
      return NextResponse.json({ error: 'Failed to create lobby' }, { status: 500 })
    }
  }

  return NextResponse.json({ error: 'Failed to generate a unique join code' }, { status: 500 })
}
