import { describe, expect, it } from 'vitest'
import { ABILITIES, ROWS } from '@/lib/terminology'
import type { GameState, PlayerState, RowState, RowType, UnitCard } from '@/types/game'
import { completeAgileSelection, resolveAgile } from './agile'

function unit(id: string, opts: Partial<UnitCard> = {}): UnitCard {
  return {
    id,
    type: 'unit',
    name: `Card_${id}`,
    faction: 'Faction A',
    row: ROWS.MELEE,
    baseStrength: 5,
    ability: ABILITIES.AGILE,
    isHero: false,
    rallyGroup: null,
    ...opts,
  }
}

function emptyRow(type: RowType): RowState {
  return { type, cards: [], warCry: false }
}

function emptyPlayer(overrides: Partial<PlayerState> = {}): PlayerState {
  return {
    faction: 'Faction A',
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

function gameState(p0: PlayerState, p1: PlayerState, opts: Partial<GameState> = {}): GameState {
  return {
    players: [p0, p1],
    weatherZone: [],
    round: 1,
    activePlayer: 0,
    selectionMode: 'default',
    pendingOptions: [],
    randomRestoration: false,
    leaderD1Active: false,
    mulligansUsed: [0, 0],
    mulliganedCardIds: [[], []],
    mulligansConfirmed: [false, false],
    roundWins: [0, 0],
    ...opts,
  }
}

describe('resolveAgile', () => {
  it('returns state unchanged if cardId is not in hand', () => {
    const state = gameState(emptyPlayer(), emptyPlayer())
    expect(resolveAgile(state, 'missing', 0)).toBe(state)
  })

  it('removes the card from hand', () => {
    const card = unit('a1')
    const state = gameState(emptyPlayer({ hand: [card] }), emptyPlayer())

    const next = resolveAgile(state, 'a1', 0)

    expect(next.players[0].hand).toHaveLength(0)
  })

  it('sets selectionMode to agile', () => {
    const card = unit('a1')
    const state = gameState(emptyPlayer({ hand: [card] }), emptyPlayer())

    const next = resolveAgile(state, 'a1', 0)

    expect(next.selectionMode).toBe('agile')
  })

  it('sets pendingOptions to the agile card', () => {
    const card = unit('a1')
    const state = gameState(emptyPlayer({ hand: [card] }), emptyPlayer())

    const next = resolveAgile(state, 'a1', 0)

    expect(next.pendingOptions).toHaveLength(1)
    expect(next.pendingOptions[0].id).toBe('a1')
  })

  it('does not modify the opponent', () => {
    const card = unit('a1')
    const state = gameState(emptyPlayer({ hand: [card] }), emptyPlayer())

    const next = resolveAgile(state, 'a1', 0)

    expect(next.players[1]).toBe(state.players[1])
  })

  it('works correctly when playerIndex is 1', () => {
    const card = unit('a1')
    const state = gameState(emptyPlayer(), emptyPlayer({ hand: [card] }))

    const next = resolveAgile(state, 'a1', 1)

    expect(next.players[1].hand).toHaveLength(0)
    expect(next.selectionMode).toBe('agile')
    expect(next.pendingOptions[0].id).toBe('a1')
    expect(next.players[0]).toBe(state.players[0])
  })
})

describe('completeAgileSelection', () => {
  it('returns state unchanged if pendingOptions is empty', () => {
    const state = gameState(emptyPlayer(), emptyPlayer(), { selectionMode: 'agile' })
    expect(completeAgileSelection(state, ROWS.MELEE, 0)).toBe(state)
  })

  it('places the card on the chosen Melee row', () => {
    const card = unit('a1')
    const state = gameState(emptyPlayer(), emptyPlayer(), {
      selectionMode: 'agile',
      pendingOptions: [card],
    })

    const next = completeAgileSelection(state, ROWS.MELEE, 0)

    expect(next.players[0].board.melee.cards).toHaveLength(1)
    expect(next.players[0].board.melee.cards[0].id).toBe('a1')
  })

  it('places the card on the chosen Ranged row', () => {
    const card = unit('a1')
    const state = gameState(emptyPlayer(), emptyPlayer(), {
      selectionMode: 'agile',
      pendingOptions: [card],
    })

    const next = completeAgileSelection(state, ROWS.RANGED, 0)

    expect(next.players[0].board.ranged.cards).toHaveLength(1)
    expect(next.players[0].board.ranged.cards[0].id).toBe('a1')
  })

  it('updates the card row field to match the chosen row', () => {
    const card = unit('a1', { row: ROWS.MELEE })
    const state = gameState(emptyPlayer(), emptyPlayer(), {
      selectionMode: 'agile',
      pendingOptions: [card],
    })

    const next = completeAgileSelection(state, ROWS.RANGED, 0)

    expect(next.players[0].board.ranged.cards[0].row).toBe(ROWS.RANGED)
  })

  it('resets selectionMode to default', () => {
    const card = unit('a1')
    const state = gameState(emptyPlayer(), emptyPlayer(), {
      selectionMode: 'agile',
      pendingOptions: [card],
    })

    const next = completeAgileSelection(state, ROWS.MELEE, 0)

    expect(next.selectionMode).toBe('default')
  })

  it('clears pendingOptions', () => {
    const card = unit('a1')
    const state = gameState(emptyPlayer(), emptyPlayer(), {
      selectionMode: 'agile',
      pendingOptions: [card],
    })

    const next = completeAgileSelection(state, ROWS.MELEE, 0)

    expect(next.pendingOptions).toHaveLength(0)
  })

  it('does not modify the opponent', () => {
    const card = unit('a1')
    const state = gameState(emptyPlayer(), emptyPlayer(), {
      selectionMode: 'agile',
      pendingOptions: [card],
    })

    const next = completeAgileSelection(state, ROWS.MELEE, 0)

    expect(next.players[1]).toBe(state.players[1])
  })

  it('works correctly when playerIndex is 1', () => {
    const card = unit('a1')
    const state = gameState(emptyPlayer(), emptyPlayer(), {
      selectionMode: 'agile',
      pendingOptions: [card],
    })

    const next = completeAgileSelection(state, ROWS.RANGED, 1)

    expect(next.players[1].board.ranged.cards[0].id).toBe('a1')
    expect(next.players[0]).toBe(state.players[0])
  })
})
