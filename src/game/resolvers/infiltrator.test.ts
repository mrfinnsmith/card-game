import { describe, expect, it } from 'vitest'
import { ABILITIES, ROWS } from '@/lib/terminology'
import type { GameState, PlayerState, RowType, UnitCard } from '@/types/game'
import { resolveInfiltrator } from './infiltrator'

function unit(id: string, row: RowType = ROWS.MELEE, opts: Partial<UnitCard> = {}): UnitCard {
  return {
    id,
    type: 'unit',
    name: `Card_${id}`,
    faction: 'Faction B',
    row,
    baseStrength: 4,
    ability: ABILITIES.INFILTRATOR,
    isHero: false,
    rallyGroup: null,
    ...opts,
  }
}

function deckCard(id: string): UnitCard {
  return unit(id, ROWS.RANGED, { ability: null })
}

function emptyPlayer(overrides: Partial<PlayerState> = {}): PlayerState {
  const emptyRow = (type: (typeof ROWS)[keyof typeof ROWS]) => ({ type, cards: [], warCry: false })
  return {
    hand: [],
    deck: [],
    discard: [],
    board: {
      melee: emptyRow(ROWS.MELEE),
      ranged: emptyRow(ROWS.RANGED),
      siege: emptyRow(ROWS.SIEGE),
    },
    gems: 2,
    passed: false,
    leaderAbilityUsed: false,
    ...overrides,
  }
}

function gameState(p0: PlayerState, p1: PlayerState): GameState {
  return {
    players: [p0, p1],
    weatherZone: [],
    round: 1,
    activePlayer: 0,
    selectionMode: 'default',
  }
}

describe('resolveInfiltrator', () => {
  it('places the card on the correct opponent row', () => {
    const infiltrator = unit('inf1', ROWS.RANGED)
    const player = emptyPlayer({ hand: [infiltrator] })
    const opponent = emptyPlayer()
    const state = gameState(player, opponent)

    const next = resolveInfiltrator(state, 'inf1', 0)

    expect(next.players[1].board.ranged.cards).toHaveLength(1)
    expect(next.players[1].board.ranged.cards[0].id).toBe('inf1')
    expect(next.players[1].board.melee.cards).toHaveLength(0)
    expect(next.players[1].board.siege.cards).toHaveLength(0)
  })

  it('removes the card from the playing player hand', () => {
    const infiltrator = unit('inf1', ROWS.MELEE)
    const player = emptyPlayer({ hand: [infiltrator] })
    const state = gameState(player, emptyPlayer())

    const next = resolveInfiltrator(state, 'inf1', 0)

    expect(next.players[0].hand.find((c) => c.id === 'inf1')).toBeUndefined()
  })

  it('playing player draws 2 cards from their deck', () => {
    const infiltrator = unit('inf1', ROWS.MELEE)
    const d1 = deckCard('d1')
    const d2 = deckCard('d2')
    const d3 = deckCard('d3')
    const player = emptyPlayer({ hand: [infiltrator], deck: [d1, d2, d3] })
    const state = gameState(player, emptyPlayer())

    const next = resolveInfiltrator(state, 'inf1', 0)

    expect(next.players[0].hand).toHaveLength(2)
    expect(next.players[0].hand.map((c) => c.id)).toEqual(['d1', 'd2'])
    expect(next.players[0].deck).toHaveLength(1)
    expect(next.players[0].deck[0].id).toBe('d3')
  })

  it('draws fewer than 2 cards if deck has less than 2', () => {
    const infiltrator = unit('inf1', ROWS.MELEE)
    const d1 = deckCard('d1')
    const player = emptyPlayer({ hand: [infiltrator], deck: [d1] })
    const state = gameState(player, emptyPlayer())

    const next = resolveInfiltrator(state, 'inf1', 0)

    expect(next.players[0].hand).toHaveLength(1)
    expect(next.players[0].deck).toHaveLength(0)
  })

  it('works correctly when player index is 1', () => {
    const infiltrator = unit('inf1', ROWS.SIEGE)
    const p0 = emptyPlayer()
    const p1 = emptyPlayer({ hand: [infiltrator] })
    const state = gameState(p0, p1)

    const next = resolveInfiltrator(state, 'inf1', 1)

    expect(next.players[0].board.siege.cards).toHaveLength(1)
    expect(next.players[1].hand.find((c) => c.id === 'inf1')).toBeUndefined()
  })

  it('returns state unchanged if cardId is not in hand', () => {
    const player = emptyPlayer({ hand: [] })
    const state = gameState(player, emptyPlayer())

    const next = resolveInfiltrator(state, 'missing', 0)

    expect(next).toBe(state)
  })

  it('does not modify the opponent hand or deck', () => {
    const infiltrator = unit('inf1', ROWS.MELEE)
    const oppCard = deckCard('opp1')
    const player = emptyPlayer({ hand: [infiltrator] })
    const opponent = emptyPlayer({ hand: [oppCard], deck: [deckCard('od1')] })
    const state = gameState(player, opponent)

    const next = resolveInfiltrator(state, 'inf1', 0)

    expect(next.players[1].hand).toHaveLength(1)
    expect(next.players[1].deck).toHaveLength(1)
  })
})
