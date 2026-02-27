import { describe, expect, it } from 'vitest'
import { ABILITIES, ROWS, WEATHER } from '@/lib/terminology'
import type {
  GameState,
  PlayerState,
  RowState,
  RowType,
  SpecialCard,
  UnitCard,
  WeatherCard,
} from '@/types/game'
import { resolveScorch } from './scorch'

function unit(id: string, baseStrength: number, opts: Partial<UnitCard> = {}): UnitCard {
  return {
    id,
    type: 'unit',
    name: `Card_${id}`,
    faction: 'Faction A',
    row: ROWS.MELEE,
    baseStrength,
    ability: null,
    isHero: false,
    rallyGroup: null,
    ...opts,
  }
}

function scorchCard(id: string): SpecialCard {
  return { id, type: 'special', name: `Scorch_${id}`, ability: ABILITIES.SCORCH }
}

function weatherCard(weatherType: (typeof WEATHER)[keyof typeof WEATHER]): WeatherCard {
  return { id: `w-${weatherType}`, type: 'weather', name: weatherType, weatherType }
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
    ...opts,
  }
}

describe('resolveScorch', () => {
  it('returns state unchanged if cardId is not in hand', () => {
    const state = gameState(emptyPlayer(), emptyPlayer())
    expect(resolveScorch(state, 'missing', 0)).toBe(state)
  })

  it('removes the Scorch card from hand and adds to discard', () => {
    const s = scorchCard('s1')
    const u1 = unit('u1', 5)
    const p0 = emptyPlayer({
      hand: [s],
      board: {
        melee: { type: ROWS.MELEE, cards: [u1], warCry: false },
        ranged: emptyRow(ROWS.RANGED),
        siege: emptyRow(ROWS.SIEGE),
      },
    })
    const state = gameState(p0, emptyPlayer())
    const next = resolveScorch(state, 's1', 0)

    expect(next.players[0].hand.find((c) => c.id === 's1')).toBeUndefined()
    expect(next.players[0].discard.find((c) => c.id === 's1')).toBeDefined()
  })

  it('returns Scorch in discard when the board has no units', () => {
    const s = scorchCard('s1')
    const p0 = emptyPlayer({ hand: [s] })
    const state = gameState(p0, emptyPlayer())
    const next = resolveScorch(state, 's1', 0)

    expect(next.players[0].discard.find((c) => c.id === 's1')).toBeDefined()
    expect(next.players[0].board.melee.cards).toHaveLength(0)
  })

  it('destroys the unit with the highest base strength', () => {
    const s = scorchCard('s1')
    const u1 = unit('u1', 5)
    const u2 = unit('u2', 10)
    const p0 = emptyPlayer({
      hand: [s],
      board: {
        melee: { type: ROWS.MELEE, cards: [u1, u2], warCry: false },
        ranged: emptyRow(ROWS.RANGED),
        siege: emptyRow(ROWS.SIEGE),
      },
    })
    const state = gameState(p0, emptyPlayer())
    const next = resolveScorch(state, 's1', 0)

    expect(next.players[0].board.melee.cards.find((c) => c.id === 'u2')).toBeUndefined()
    expect(next.players[0].board.melee.cards.find((c) => c.id === 'u1')).toBeDefined()
    expect(next.players[0].discard.find((c) => c.id === 'u2')).toBeDefined()
  })

  it('destroys all units tied at max strength', () => {
    const s = scorchCard('s1')
    const u1 = unit('u1', 8)
    const u2 = unit('u2', 8)
    const u3 = unit('u3', 5)
    const p0 = emptyPlayer({
      hand: [s],
      board: {
        melee: { type: ROWS.MELEE, cards: [u1, u2, u3], warCry: false },
        ranged: emptyRow(ROWS.RANGED),
        siege: emptyRow(ROWS.SIEGE),
      },
    })
    const state = gameState(p0, emptyPlayer())
    const next = resolveScorch(state, 's1', 0)

    expect(next.players[0].board.melee.cards.find((c) => c.id === 'u1')).toBeUndefined()
    expect(next.players[0].board.melee.cards.find((c) => c.id === 'u2')).toBeUndefined()
    expect(next.players[0].board.melee.cards.find((c) => c.id === 'u3')).toBeDefined()
  })

  it('heroes survive Scorch', () => {
    const s = scorchCard('s1')
    const hero = unit('h1', 15, { isHero: true, ability: ABILITIES.HERO })
    const plain = unit('u1', 5)
    const p0 = emptyPlayer({
      hand: [s],
      board: {
        melee: { type: ROWS.MELEE, cards: [hero, plain], warCry: false },
        ranged: emptyRow(ROWS.RANGED),
        siege: emptyRow(ROWS.SIEGE),
      },
    })
    const state = gameState(p0, emptyPlayer())
    const next = resolveScorch(state, 's1', 0)

    expect(next.players[0].board.melee.cards.find((c) => c.id === 'h1')).toBeDefined()
    expect(next.players[0].board.melee.cards.find((c) => c.id === 'u1')).toBeUndefined()
  })

  it('uses computed strength — weather-reduced unit is not chosen when a higher unit exists', () => {
    const s = scorchCard('s1')
    const u1 = unit('u1', 10, { row: ROWS.MELEE })
    const u2 = unit('u2', 5, { row: ROWS.RANGED })
    const p0 = emptyPlayer({
      hand: [s],
      board: {
        melee: { type: ROWS.MELEE, cards: [u1], warCry: false },
        ranged: { type: ROWS.RANGED, cards: [u2], warCry: false },
        siege: emptyRow(ROWS.SIEGE),
      },
    })
    // Blizzard reduces melee u1 (base 10) to 1; ranged u2 (base 5) is highest
    const state = gameState(p0, emptyPlayer(), { weatherZone: [weatherCard(WEATHER.BLIZZARD)] })
    const next = resolveScorch(state, 's1', 0)

    expect(next.players[0].board.ranged.cards.find((c) => c.id === 'u2')).toBeUndefined()
    expect(next.players[0].board.melee.cards.find((c) => c.id === 'u1')).toBeDefined()
  })

  it('destroys all units when every unit is weather-reduced to 1', () => {
    const s = scorchCard('s1')
    const u1 = unit('u1', 8, { row: ROWS.MELEE })
    const u2 = unit('u2', 6, { row: ROWS.MELEE })
    const u3 = unit('u3', 7, { row: ROWS.RANGED })
    const p0 = emptyPlayer({
      hand: [s],
      board: {
        melee: { type: ROWS.MELEE, cards: [u1, u2], warCry: false },
        ranged: { type: ROWS.RANGED, cards: [u3], warCry: false },
        siege: emptyRow(ROWS.SIEGE),
      },
    })
    // Blizzard + Shroud = all units at 1
    const state = gameState(p0, emptyPlayer(), {
      weatherZone: [weatherCard(WEATHER.BLIZZARD), weatherCard(WEATHER.SHROUD)],
    })
    const next = resolveScorch(state, 's1', 0)

    expect(next.players[0].board.melee.cards).toHaveLength(0)
    expect(next.players[0].board.ranged.cards).toHaveLength(0)
  })

  it('affects units on both sides of the board', () => {
    const s = scorchCard('s1')
    const own = unit('own1', 5)
    const opp = unit('opp1', 10)
    const p0 = emptyPlayer({
      hand: [s],
      board: {
        melee: { type: ROWS.MELEE, cards: [own], warCry: false },
        ranged: emptyRow(ROWS.RANGED),
        siege: emptyRow(ROWS.SIEGE),
      },
    })
    const p1 = emptyPlayer({
      board: {
        melee: { type: ROWS.MELEE, cards: [opp], warCry: false },
        ranged: emptyRow(ROWS.RANGED),
        siege: emptyRow(ROWS.SIEGE),
      },
    })
    const state = gameState(p0, p1)
    const next = resolveScorch(state, 's1', 0)

    expect(next.players[1].board.melee.cards.find((c) => c.id === 'opp1')).toBeUndefined()
    expect(next.players[0].board.melee.cards.find((c) => c.id === 'own1')).toBeDefined()
    expect(next.players[1].discard.find((c) => c.id === 'opp1')).toBeDefined()
  })

  it('destroyed units go to their respective owner discard', () => {
    const s = scorchCard('s1')
    const own = unit('own1', 10)
    const opp = unit('opp1', 10)
    const p0 = emptyPlayer({
      hand: [s],
      board: {
        melee: { type: ROWS.MELEE, cards: [own], warCry: false },
        ranged: emptyRow(ROWS.RANGED),
        siege: emptyRow(ROWS.SIEGE),
      },
    })
    const p1 = emptyPlayer({
      board: {
        melee: { type: ROWS.MELEE, cards: [opp], warCry: false },
        ranged: emptyRow(ROWS.RANGED),
        siege: emptyRow(ROWS.SIEGE),
      },
    })
    const state = gameState(p0, p1)
    const next = resolveScorch(state, 's1', 0)

    expect(next.players[0].discard.find((c) => c.id === 'own1')).toBeDefined()
    expect(next.players[1].discard.find((c) => c.id === 'opp1')).toBeDefined()
  })

  it('works correctly when playerIndex is 1', () => {
    const s = scorchCard('s1')
    const u1 = unit('u1', 8)
    const p1 = emptyPlayer({
      hand: [s],
      board: {
        melee: { type: ROWS.MELEE, cards: [u1], warCry: false },
        ranged: emptyRow(ROWS.RANGED),
        siege: emptyRow(ROWS.SIEGE),
      },
    })
    const state = gameState(emptyPlayer(), p1)
    const next = resolveScorch(state, 's1', 1)

    expect(next.players[1].hand.find((c) => c.id === 's1')).toBeUndefined()
    expect(next.players[1].discard.find((c) => c.id === 's1')).toBeDefined()
    expect(next.players[1].board.melee.cards.find((c) => c.id === 'u1')).toBeUndefined()
    expect(next.players[0]).toBe(state.players[0])
  })
})
