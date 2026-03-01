import { NextRequest, NextResponse } from 'next/server'
import { createServerSupabaseClient } from '@/lib/supabase-server'
import { endRound, isMatchOver, isRoundOver } from '@/game/stateMachine'
import type { GameState } from '@/types/game'
import { validateAndApply } from '@/lib/validateMove'

export async function POST(request: NextRequest, { params }: { params: { id: string } }) {
  const supabase = createServerSupabaseClient()
  const {
    data: { user },
  } = await supabase.auth.getUser()

  if (!user) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })

  const { data: game, error: gameError } = await supabase
    .from('cards_games')
    .select('id, lobby_id, state, status')
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

  const body = await request.json()
  const { action, cardId, rowChoice } = body as {
    action: string
    cardId?: string
    rowChoice?: string
  }

  const gameState = game.state as GameState
  const result = validateAndApply(gameState, playerIndex, { action, cardId, rowChoice })

  if (!result.valid) return NextResponse.json({ error: result.error }, { status: 400 })

  let nextState = result.nextState

  while (isRoundOver(nextState) && !isMatchOver(nextState)) {
    nextState = endRound(nextState, Math.random)
  }

  const matchOver = isMatchOver(nextState)
  const nextPlayerId = nextState.activePlayer === 0 ? lobby.host_id : lobby.guest_id

  const { error: updateError } = await supabase
    .from('cards_games')
    .update({
      state: nextState,
      current_player_id: nextPlayerId,
      ...(matchOver ? { status: 'completed' } : {}),
    })
    .eq('id', params.id)

  if (updateError) return NextResponse.json({ error: 'Failed to persist state' }, { status: 500 })

  return NextResponse.json({ state: nextState })
}
