import { NextRequest, NextResponse } from 'next/server'
import { createServerSupabaseClient } from '@/lib/supabase-server'
import { FACTION_DATA } from '@/game/factionData'
import { buildDeck, shuffleDeck } from '@/game/decks'
import { initMatch } from '@/game/stateMachine'
import { ROWS } from '@/lib/terminology'
import type { LeaderId, PlayerFaction, PlayerState } from '@/types/game'

function buildPlayerState(faction: PlayerFaction, leader: LeaderId, prefix: string): PlayerState {
  return {
    faction,
    leader,
    hand: [],
    deck: shuffleDeck(buildDeck(faction, prefix)),
    discard: [],
    board: {
      melee: { type: ROWS.MELEE, cards: [], warCry: false },
      ranged: { type: ROWS.RANGED, cards: [], warCry: false },
      siege: { type: ROWS.SIEGE, cards: [], warCry: false },
    },
    gems: 2,
    passed: false,
    leaderAbilityUsed: false,
  }
}

export async function POST(request: NextRequest, { params }: { params: { id: string } }) {
  const supabase = createServerSupabaseClient()
  const {
    data: { user },
  } = await supabase.auth.getUser()

  if (!user) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  }

  const body = await request.json()
  const { faction, leader } = body as { faction: string; leader: string }

  const factionData = FACTION_DATA.find((f) => f.id === faction)
  if (!factionData) {
    return NextResponse.json({ error: 'Invalid faction' }, { status: 400 })
  }

  if (!factionData.leaders.find((l) => l.id === leader)) {
    return NextResponse.json({ error: 'Invalid leader for faction' }, { status: 400 })
  }

  const { data: result, error: rpcError } = await supabase.rpc('cards_confirm_selection', {
    p_lobby_id: params.id,
    p_faction: faction,
    p_leader: leader,
  })

  if (rpcError) {
    return NextResponse.json({ error: 'Failed to save selection' }, { status: 500 })
  }

  if (result?.error) {
    const statusMap: Record<string, number> = {
      not_found: 404,
      unauthorized: 403,
      invalid_status: 400,
    }
    return NextResponse.json({ error: result.error }, { status: statusMap[result.error] ?? 400 })
  }

  if (!result?.both_confirmed) {
    return NextResponse.json({ waiting: true })
  }

  const hostState = buildPlayerState(
    result.host_faction as PlayerFaction,
    result.host_leader as LeaderId,
    'p0',
  )
  const guestState = buildPlayerState(
    result.guest_faction as PlayerFaction,
    result.guest_leader as LeaderId,
    'p1',
  )
  const gameState = initMatch(hostState, guestState, Math.random)
  const currentPlayerId = gameState.activePlayer === 0 ? result.host_id : result.guest_id

  const { data: gameResult, error: gameError } = await supabase.rpc('cards_create_game', {
    p_lobby_id: params.id,
    p_state: gameState,
    p_current_player_id: currentPlayerId,
  })

  if (gameError || gameResult?.error) {
    return NextResponse.json({ error: 'Failed to create game' }, { status: 500 })
  }

  return NextResponse.json({ game_id: gameResult.game_id })
}
