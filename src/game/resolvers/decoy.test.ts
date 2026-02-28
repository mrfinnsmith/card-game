import { describe, expect, it } from 'vitest'
import { ABILITIES, ROWS } from '@/lib/terminology'
import type { GameState, PlayerState, RowState, RowType, SpecialCard, UnitCard } from '@/types/game'
import { computeStrength } from '../computeStrength'
import { completeDecoySelection, resolveDecoy } from './decoy'

function unit(id: string, row: RowType = ROWS.MELEE, opts: Partial<UnitCard> = {}): UnitCard {
  return {
    id,
    type: 'unit',
    name: `Card_${id}`,
    faction: 'Faction A',
    row,
    baseStrength: 5,
    ability: null,
    isHero: false,
    rallyGroup: null,
    ...opts,
  }
}

function decoyCard(id: string): SpecialCard {
  return { id, type: 'special', name: `Decoy_${id}`, ability: ABILITIES.DECOY }
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
    ...opts,
  }
}

describe('resolveDecoy', () => {
  it('returns state unchanged if cardId is not in hand', () => {
    const state = gameState(emptyPlayer(), emptyPlayer())
    expect(resolveDecoy(state, 'missing', 0)).toBe(state)
  })

  it('removes the Decoy card from hand', () => {
    const decoy = decoyCard('d1')
    const state = gameState(emptyPlayer({ hand: [decoy] }), emptyPlayer())

    const next = resolveDecoy(state, 'd1', 0)

    expect(next.players[0].hand.find((c) => c.id === 'd1')).toBeUndefined()
  })

  it('adds the Decoy card to discard', () => {
    const decoy = decoyCard('d1')
    const state = gameState(emptyPlayer({ hand: [decoy] }), emptyPlayer())

    const next = resolveDecoy(state, 'd1', 0)

    expect(next.players[0].discard.find((c) => c.id === 'd1')).toBeDefined()
  })

  it('sets selectionMode to decoy', () => {
    const decoy = decoyCard('d1')
    const state = gameState(emptyPlayer({ hand: [decoy] }), emptyPlayer())

    const next = resolveDecoy(state, 'd1', 0)

    expect(next.selectionMode).toBe('decoy')
  })

  it('pendingOptions includes non-hero units from own board', () => {
    const decoy = decoyCard('d1')
    const boardUnit = unit('u1')
    const p0 = emptyPlayer({
      hand: [decoy],
      board: {
        melee: { type: ROWS.MELEE, cards: [boardUnit], warCry: false },
        ranged: emptyRow(ROWS.RANGED),
        siege: emptyRow(ROWS.SIEGE),
      },
    })
    const state = gameState(p0, emptyPlayer())

    const next = resolveDecoy(state, 'd1', 0)

    expect(next.pendingOptions.find((c) => c.id === 'u1')).toBeDefined()
  })

  it('pendingOptions includes non-hero units from opponent board', () => {
    const decoy = decoyCard('d1')
    const opponentUnit = unit('u2', ROWS.RANGED)
    const p1 = emptyPlayer({
      board: {
        melee: emptyRow(ROWS.MELEE),
        ranged: { type: ROWS.RANGED, cards: [opponentUnit], warCry: false },
        siege: emptyRow(ROWS.SIEGE),
      },
    })
    const state = gameState(emptyPlayer({ hand: [decoy] }), p1)

    const next = resolveDecoy(state, 'd1', 0)

    expect(next.pendingOptions.find((c) => c.id === 'u2')).toBeDefined()
  })

  it('pendingOptions excludes heroes', () => {
    const decoy = decoyCard('d1')
    const hero = unit('h1', ROWS.MELEE, { isHero: true, ability: ABILITIES.HERO })
    const plain = unit('u1')
    const p0 = emptyPlayer({
      hand: [decoy],
      board: {
        melee: { type: ROWS.MELEE, cards: [hero, plain], warCry: false },
        ranged: emptyRow(ROWS.RANGED),
        siege: emptyRow(ROWS.SIEGE),
      },
    })
    const state = gameState(p0, emptyPlayer())

    const next = resolveDecoy(state, 'd1', 0)

    expect(next.pendingOptions.find((c) => c.id === 'h1')).toBeUndefined()
    expect(next.pendingOptions.find((c) => c.id === 'u1')).toBeDefined()
  })

  it('works correctly when playerIndex is 1', () => {
    const decoy = decoyCard('d1')
    const state = gameState(emptyPlayer(), emptyPlayer({ hand: [decoy] }))

    const next = resolveDecoy(state, 'd1', 1)

    expect(next.players[1].hand.find((c) => c.id === 'd1')).toBeUndefined()
    expect(next.players[1].discard.find((c) => c.id === 'd1')).toBeDefined()
    expect(next.selectionMode).toBe('decoy')
    expect(next.players[0]).toBe(state.players[0])
  })
})

describe('completeDecoySelection', () => {
  it('returns state unchanged if unit is not found on either board', () => {
    const state = gameState(emptyPlayer(), emptyPlayer(), { selectionMode: 'decoy' })
    expect(completeDecoySelection(state, 'missing', 0)).toBe(state)
  })

  it('removes selected unit from own board', () => {
    const boardUnit = unit('u1')
    const p0 = emptyPlayer({
      board: {
        melee: { type: ROWS.MELEE, cards: [boardUnit], warCry: false },
        ranged: emptyRow(ROWS.RANGED),
        siege: emptyRow(ROWS.SIEGE),
      },
    })
    const state = gameState(p0, emptyPlayer(), { selectionMode: 'decoy' })

    const next = completeDecoySelection(state, 'u1', 0)

    expect(next.players[0].board.melee.cards.find((c) => c.id === 'u1')).toBeUndefined()
  })

  it('adds selected unit from own board to own hand', () => {
    const boardUnit = unit('u1')
    const p0 = emptyPlayer({
      board: {
        melee: { type: ROWS.MELEE, cards: [boardUnit], warCry: false },
        ranged: emptyRow(ROWS.RANGED),
        siege: emptyRow(ROWS.SIEGE),
      },
    })
    const state = gameState(p0, emptyPlayer(), { selectionMode: 'decoy' })

    const next = completeDecoySelection(state, 'u1', 0)

    expect(next.players[0].hand.find((c) => c.id === 'u1')).toBeDefined()
  })

  it('removes selected unit from opponent board and adds to own hand', () => {
    const infiltrator = unit('inf1', ROWS.MELEE, { ability: ABILITIES.INFILTRATOR })
    const p1 = emptyPlayer({
      board: {
        melee: { type: ROWS.MELEE, cards: [infiltrator], warCry: false },
        ranged: emptyRow(ROWS.RANGED),
        siege: emptyRow(ROWS.SIEGE),
      },
    })
    const state = gameState(emptyPlayer(), p1, { selectionMode: 'decoy' })

    const next = completeDecoySelection(state, 'inf1', 0)

    expect(next.players[1].board.melee.cards.find((c) => c.id === 'inf1')).toBeUndefined()
    expect(next.players[0].hand.find((c) => c.id === 'inf1')).toBeDefined()
  })

  it('resets selectionMode to default', () => {
    const boardUnit = unit('u1')
    const p0 = emptyPlayer({
      board: {
        melee: { type: ROWS.MELEE, cards: [boardUnit], warCry: false },
        ranged: emptyRow(ROWS.RANGED),
        siege: emptyRow(ROWS.SIEGE),
      },
    })
    const state = gameState(p0, emptyPlayer(), { selectionMode: 'decoy' })

    const next = completeDecoySelection(state, 'u1', 0)

    expect(next.selectionMode).toBe('default')
  })

  it('clears pendingOptions', () => {
    const boardUnit = unit('u1')
    const p0 = emptyPlayer({
      board: {
        melee: { type: ROWS.MELEE, cards: [boardUnit], warCry: false },
        ranged: emptyRow(ROWS.RANGED),
        siege: emptyRow(ROWS.SIEGE),
      },
    })
    const state = gameState(p0, emptyPlayer(), {
      selectionMode: 'decoy',
      pendingOptions: [boardUnit],
    })

    const next = completeDecoySelection(state, 'u1', 0)

    expect(next.pendingOptions).toHaveLength(0)
  })

  it('Formation recalculates after Decoy removes one of two same-named cards', () => {
    const f1 = unit('f1', ROWS.MELEE, {
      name: 'Alpha',
      ability: ABILITIES.FORMATION,
      baseStrength: 8,
    })
    const f2 = unit('f2', ROWS.MELEE, {
      name: 'Alpha',
      ability: ABILITIES.FORMATION,
      baseStrength: 8,
    })
    const p0 = emptyPlayer({
      board: {
        melee: { type: ROWS.MELEE, cards: [f1, f2], warCry: false },
        ranged: emptyRow(ROWS.RANGED),
        siege: emptyRow(ROWS.SIEGE),
      },
    })
    const state = gameState(p0, emptyPlayer(), { selectionMode: 'decoy' })

    const next = completeDecoySelection(state, 'f2', 0)
    const row = next.players[0].board.melee

    expect(next.players[0].hand.find((c) => c.id === 'f2')).toBeDefined()
    expect(computeStrength('f1', row, next)).toBe(8)
  })

  it('works correctly when playerIndex is 1', () => {
    const boardUnit = unit('u1', ROWS.SIEGE)
    const p1 = emptyPlayer({
      board: {
        melee: emptyRow(ROWS.MELEE),
        ranged: emptyRow(ROWS.RANGED),
        siege: { type: ROWS.SIEGE, cards: [boardUnit], warCry: false },
      },
    })
    const state = gameState(emptyPlayer(), p1, { selectionMode: 'decoy' })

    const next = completeDecoySelection(state, 'u1', 1)

    expect(next.players[1].board.siege.cards.find((c) => c.id === 'u1')).toBeUndefined()
    expect(next.players[1].hand.find((c) => c.id === 'u1')).toBeDefined()
    expect(next.players[0]).toBe(state.players[0])
  })
})
