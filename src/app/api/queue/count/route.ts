import { NextResponse } from 'next/server'
import { createServerSupabaseClient } from '@/lib/supabase-server'

export async function GET() {
  const supabase = createServerSupabaseClient()
  const { data, error } = await supabase.rpc('cards_queue_count')

  if (error) {
    return NextResponse.json({ count: 0 })
  }

  return NextResponse.json({ count: Number(data) })
}
