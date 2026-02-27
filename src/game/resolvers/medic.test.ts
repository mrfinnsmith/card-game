import { describe, expect, it, vi } from 'vitest'
import { ABILITIES, ROWS } from '@/lib/terminology'
import type {
  GameState,
  PlayerState,
  RowType,
  SpecialCard,
  UnitCard,
  WeatherCard,
} from '@/types/game'
import { completeMedicSelection, resolveMedic } from './medic'

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

function special(id: string): SpecialCard {
  return { id, type: 'special', name: `Special_${id}`, ability: ABILITIES.SCORCH }
}

function weather(id: string): WeatherCard {
  return { id, type: 'weather', name: `Weather_${id}`, weatherType: 'Blizzard' }
}

function emptyPlayer(overrides: Partial<PlayerState> = {}): PlayerState {
  const emptyRow = (type: RowType) => ({ type, cards: [], warCry: false })
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
    ...opts,
  }
}

const noopDispatch = (state: GameState) => state

describe('resolveMedic', () => {
  it('returns state unchanged if cardId is not in hand', () => {
    const state = gameState(emptyPlayer(), emptyPlayer())
    expect(resolveMedic(state, 'missing', 0, () => 0, noopDispatch)).toBe(state)
  })

  it('removes the medic from hand and places it on the board', () => {
    const medic = unit('m1', ROWS.RANGED, { ability: ABILITIES.MEDIC })
    const state = gameState(emptyPlayer({ hand: [medic] }), emptyPlayer())

    const next = resolveMedic(state, 'm1', 0, () => 0, noopDispatch)

    expect(next.players[0].hand.find((c) => c.id === 'm1')).toBeUndefined()
    expect(next.players[0].board.ranged.cards).toHaveLength(1)
    expect(next.players[0].board.ranged.cards[0].id).toBe('m1')
  })

  it('sets selectionMode to medic when eligible cards exist in discard', () => {
    const medic = unit('m1', ROWS.MELEE, { ability: ABILITIES.MEDIC })
    const discarded = unit('d1')
    const state = gameState(emptyPlayer({ hand: [medic], discard: [discarded] }), emptyPlayer())

    const next = resolveMedic(state, 'm1', 0, () => 0, noopDispatch)

    expect(next.selectionMode).toBe('medic')
  })

  it('sets pendingOptions to eligible discard cards', () => {
    const medic = unit('m1', ROWS.MELEE, { ability: ABILITIES.MEDIC })
    const d1 = unit('d1')
    const d2 = unit('d2', ROWS.RANGED)
    const state = gameState(emptyPlayer({ hand: [medic], discard: [d1, d2] }), emptyPlayer())

    const next = resolveMedic(state, 'm1', 0, () => 0, noopDispatch)

    expect(next.pendingOptions).toHaveLength(2)
    expect(next.pendingOptions.map((c) => c.id)).toContain('d1')
    expect(next.pendingOptions.map((c) => c.id)).toContain('d2')
  })

  it('excludes hero units from pendingOptions', () => {
    const medic = unit('m1', ROWS.MELEE, { ability: ABILITIES.MEDIC })
    const hero = unit('h1', ROWS.MELEE, { isHero: true, ability: ABILITIES.HERO })
    const plain = unit('d1')
    const state = gameState(emptyPlayer({ hand: [medic], discard: [hero, plain] }), emptyPlayer())

    const next = resolveMedic(state, 'm1', 0, () => 0, noopDispatch)

    expect(next.pendingOptions.find((c) => c.id === 'h1')).toBeUndefined()
    expect(next.pendingOptions.find((c) => c.id === 'd1')).toBeDefined()
  })

  it('excludes special cards from pendingOptions', () => {
    const medic = unit('m1', ROWS.MELEE, { ability: ABILITIES.MEDIC })
    const sp = special('s1')
    const plain = unit('d1')
    const state = gameState(emptyPlayer({ hand: [medic], discard: [sp, plain] }), emptyPlayer())

    const next = resolveMedic(state, 'm1', 0, () => 0, noopDispatch)

    expect(next.pendingOptions).toHaveLength(1)
    expect(next.pendingOptions[0].id).toBe('d1')
  })

  it('excludes weather cards from pendingOptions', () => {
    const medic = unit('m1', ROWS.MELEE, { ability: ABILITIES.MEDIC })
    const w = weather('w1')
    const plain = unit('d1')
    const state = gameState(emptyPlayer({ hand: [medic], discard: [w, plain] }), emptyPlayer())

    const next = resolveMedic(state, 'm1', 0, () => 0, noopDispatch)

    expect(next.pendingOptions).toHaveLength(1)
    expect(next.pendingOptions[0].id).toBe('d1')
  })

  it('does not set selectionMode when discard has no eligible cards', () => {
    const medic = unit('m1', ROWS.MELEE, { ability: ABILITIES.MEDIC })
    const hero = unit('h1', ROWS.MELEE, { isHero: true, ability: ABILITIES.HERO })
    const state = gameState(emptyPlayer({ hand: [medic], discard: [hero] }), emptyPlayer())

    const next = resolveMedic(state, 'm1', 0, () => 0, noopDispatch)

    expect(next.selectionMode).toBe('default')
    expect(next.pendingOptions).toHaveLength(0)
  })

  it('does not set selectionMode when discard is empty', () => {
    const medic = unit('m1', ROWS.MELEE, { ability: ABILITIES.MEDIC })
    const state = gameState(emptyPlayer({ hand: [medic], discard: [] }), emptyPlayer())

    const next = resolveMedic(state, 'm1', 0, () => 0, noopDispatch)

    expect(next.selectionMode).toBe('default')
  })

  it('with randomRestoration: picks randomly and skips selection mode', () => {
    const medic = unit('m1', ROWS.MELEE, { ability: ABILITIES.MEDIC })
    const d1 = unit('d1', ROWS.MELEE)
    const d2 = unit('d2', ROWS.RANGED)
    const d3 = unit('d3', ROWS.SIEGE)
    const state = gameState(emptyPlayer({ hand: [medic], discard: [d1, d2, d3] }), emptyPlayer(), {
      randomRestoration: true,
    })

    // rng returning 0.99 → index 2 → d3
    const next = resolveMedic(state, 'm1', 0, () => 0.99, noopDispatch)

    expect(next.selectionMode).toBe('default')
    expect(next.players[0].board.siege.cards[0].id).toBe('d3')
    expect(next.players[0].discard).toHaveLength(2)
  })

  it('works correctly when playerIndex is 1', () => {
    const medic = unit('m1', ROWS.MELEE, { ability: ABILITIES.MEDIC })
    const d1 = unit('d1')
    const p1 = emptyPlayer({ hand: [medic], discard: [d1] })
    const state = gameState(emptyPlayer(), p1)

    const next = resolveMedic(state, 'm1', 1, () => 0, noopDispatch)

    expect(next.players[1].hand.find((c) => c.id === 'm1')).toBeUndefined()
    expect(next.players[1].board.melee.cards[0].id).toBe('m1')
    expect(next.selectionMode).toBe('medic')
    expect(next.players[0]).toBe(state.players[0])
  })
})

describe('completeMedicSelection', () => {
  it('returns state unchanged if selectedCardId is not in discard', () => {
    const state = gameState(emptyPlayer(), emptyPlayer(), { selectionMode: 'medic' })
    expect(completeMedicSelection(state, 'missing', 0, noopDispatch, () => 0)).toBe(state)
  })

  it('removes the revived card from discard', () => {
    const card = unit('d1', ROWS.MELEE)
    const state = gameState(emptyPlayer({ discard: [card] }), emptyPlayer(), {
      selectionMode: 'medic',
    })

    const next = completeMedicSelection(state, 'd1', 0, noopDispatch, () => 0)

    expect(next.players[0].discard.find((c) => c.id === 'd1')).toBeUndefined()
  })

  it('places the revived card on the correct board row', () => {
    const card = unit('d1', ROWS.SIEGE)
    const state = gameState(emptyPlayer({ discard: [card] }), emptyPlayer(), {
      selectionMode: 'medic',
    })

    const next = completeMedicSelection(state, 'd1', 0, noopDispatch, () => 0)

    expect(next.players[0].board.siege.cards).toHaveLength(1)
    expect(next.players[0].board.siege.cards[0].id).toBe('d1')
  })

  it('resets selectionMode to default and clears pendingOptions', () => {
    const card = unit('d1')
    const pending = unit('p1')
    const state = gameState(emptyPlayer({ discard: [card] }), emptyPlayer(), {
      selectionMode: 'medic',
      pendingOptions: [pending],
    })

    const next = completeMedicSelection(state, 'd1', 0, noopDispatch, () => 0)

    expect(next.selectionMode).toBe('default')
    expect(next.pendingOptions).toHaveLength(0)
  })

  it('calls dispatch for a revived card with a non-Medic ability', () => {
    const card = unit('d1', ROWS.MELEE, { ability: ABILITIES.RALLY })
    const state = gameState(emptyPlayer({ discard: [card] }), emptyPlayer(), {
      selectionMode: 'medic',
    })
    const dispatch = vi.fn((s: GameState) => s)

    completeMedicSelection(state, 'd1', 0, dispatch, () => 0)

    expect(dispatch).toHaveBeenCalledOnce()
    expect(dispatch).toHaveBeenCalledWith(
      expect.objectContaining({ selectionMode: 'default' }),
      'd1',
      0,
      expect.any(Function),
    )
  })

  it('does not call dispatch for a revived Medic (no chain)', () => {
    const card = unit('m2', ROWS.MELEE, { ability: ABILITIES.MEDIC })
    const state = gameState(emptyPlayer({ discard: [card] }), emptyPlayer(), {
      selectionMode: 'medic',
    })
    const dispatch = vi.fn((s: GameState) => s)

    completeMedicSelection(state, 'm2', 0, dispatch, () => 0)

    expect(dispatch).not.toHaveBeenCalled()
  })

  it('does not call dispatch for a revived card with no ability', () => {
    const card = unit('d1', ROWS.MELEE, { ability: null })
    const state = gameState(emptyPlayer({ discard: [card] }), emptyPlayer(), {
      selectionMode: 'medic',
    })
    const dispatch = vi.fn((s: GameState) => s)

    completeMedicSelection(state, 'd1', 0, dispatch, () => 0)

    expect(dispatch).not.toHaveBeenCalled()
  })

  it('works correctly when playerIndex is 1', () => {
    const card = unit('d1', ROWS.RANGED)
    const p1 = emptyPlayer({ discard: [card] })
    const state = gameState(emptyPlayer(), p1, { selectionMode: 'medic' })

    const next = completeMedicSelection(state, 'd1', 1, noopDispatch, () => 0)

    expect(next.players[1].board.ranged.cards[0].id).toBe('d1')
    expect(next.players[1].discard).toHaveLength(0)
    expect(next.players[0]).toBe(state.players[0])
  })
})
