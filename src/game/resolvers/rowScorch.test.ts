import { describe, expect, it } from 'vitest'
import { ABILITIES, ROWS, WEATHER } from '@/lib/terminology'
import type { GameState, PlayerState, RowState, RowType, UnitCard, WeatherCard } from '@/types/game'
import { resolveRowScorch } from './rowScorch'

function rowScorchUnit(id: string, opts: Partial<UnitCard> = {}): UnitCard {
  return {
    id,
    type: 'unit',
    name: `RS_${id}`,
    faction: 'Faction A',
    row: ROWS.MELEE,
    baseStrength: 4,
    ability: ABILITIES.ROW_SCORCH,
    isHero: false,
    rallyGroup: null,
    ...opts,
  }
}

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
    leaderD1Active: false,
    ...opts,
  }
}

describe('resolveRowScorch', () => {
  it('returns state unchanged if cardId is not in hand', () => {
    const state = gameState(emptyPlayer(), emptyPlayer())
    expect(resolveRowScorch(state, 'missing', 0)).toBe(state)
  })

  it('places the Row Scorch unit on the player board', () => {
    const rs = rowScorchUnit('rs1')
    const p0 = emptyPlayer({ hand: [rs] })
    const state = gameState(p0, emptyPlayer())
    const next = resolveRowScorch(state, 'rs1', 0)

    expect(next.players[0].hand.find((c) => c.id === 'rs1')).toBeUndefined()
    expect(next.players[0].board.melee.cards.find((c) => c.id === 'rs1')).toBeDefined()
  })

  it('does not trigger if opponent row total is below 10', () => {
    const rs = rowScorchUnit('rs1')
    const opp = unit('opp1', 5)
    const p0 = emptyPlayer({ hand: [rs] })
    const p1 = emptyPlayer({
      board: {
        melee: { type: ROWS.MELEE, cards: [opp], warCry: false },
        ranged: emptyRow(ROWS.RANGED),
        siege: emptyRow(ROWS.SIEGE),
      },
    })
    const state = gameState(p0, p1)
    const next = resolveRowScorch(state, 'rs1', 0)

    expect(next.players[1].board.melee.cards.find((c) => c.id === 'opp1')).toBeDefined()
  })

  it('triggers and destroys the highest-strength unit when opponent row total >= 10', () => {
    const rs = rowScorchUnit('rs1')
    const opp1 = unit('opp1', 8)
    const opp2 = unit('opp2', 5)
    const p0 = emptyPlayer({ hand: [rs] })
    const p1 = emptyPlayer({
      board: {
        melee: { type: ROWS.MELEE, cards: [opp1, opp2], warCry: false },
        ranged: emptyRow(ROWS.RANGED),
        siege: emptyRow(ROWS.SIEGE),
      },
    })
    const state = gameState(p0, p1)
    const next = resolveRowScorch(state, 'rs1', 0)

    expect(next.players[1].board.melee.cards.find((c) => c.id === 'opp1')).toBeUndefined()
    expect(next.players[1].board.melee.cards.find((c) => c.id === 'opp2')).toBeDefined()
    expect(next.players[1].discard.find((c) => c.id === 'opp1')).toBeDefined()
  })

  it('destroys all units tied at max strength when triggered', () => {
    const rs = rowScorchUnit('rs1')
    const opp1 = unit('opp1', 8)
    const opp2 = unit('opp2', 8)
    const opp3 = unit('opp3', 5)
    const p0 = emptyPlayer({ hand: [rs] })
    const p1 = emptyPlayer({
      board: {
        melee: { type: ROWS.MELEE, cards: [opp1, opp2, opp3], warCry: false },
        ranged: emptyRow(ROWS.RANGED),
        siege: emptyRow(ROWS.SIEGE),
      },
    })
    const state = gameState(p0, p1)
    const next = resolveRowScorch(state, 'rs1', 0)

    expect(next.players[1].board.melee.cards.find((c) => c.id === 'opp1')).toBeUndefined()
    expect(next.players[1].board.melee.cards.find((c) => c.id === 'opp2')).toBeUndefined()
    expect(next.players[1].board.melee.cards.find((c) => c.id === 'opp3')).toBeDefined()
  })

  it('heroes survive Row Scorch', () => {
    const rs = rowScorchUnit('rs1')
    const hero = unit('h1', 15, { isHero: true, ability: ABILITIES.HERO })
    const plain = unit('u1', 5)
    const p0 = emptyPlayer({ hand: [rs] })
    const p1 = emptyPlayer({
      board: {
        melee: { type: ROWS.MELEE, cards: [hero, plain], warCry: false },
        ranged: emptyRow(ROWS.RANGED),
        siege: emptyRow(ROWS.SIEGE),
      },
    })
    const state = gameState(p0, p1)
    const next = resolveRowScorch(state, 'rs1', 0)

    expect(next.players[1].board.melee.cards.find((c) => c.id === 'h1')).toBeDefined()
    expect(next.players[1].board.melee.cards.find((c) => c.id === 'u1')).toBeUndefined()
  })

  it('only affects the opponent row — own board is untouched', () => {
    const rs = rowScorchUnit('rs1')
    const ownUnit = unit('own1', 10)
    const opp1 = unit('opp1', 6)
    const opp2 = unit('opp2', 5)
    const p0 = emptyPlayer({
      hand: [rs],
      board: {
        melee: { type: ROWS.MELEE, cards: [ownUnit], warCry: false },
        ranged: emptyRow(ROWS.RANGED),
        siege: emptyRow(ROWS.SIEGE),
      },
    })
    const p1 = emptyPlayer({
      board: {
        melee: { type: ROWS.MELEE, cards: [opp1, opp2], warCry: false },
        ranged: emptyRow(ROWS.RANGED),
        siege: emptyRow(ROWS.SIEGE),
      },
    })
    const state = gameState(p0, p1)
    const next = resolveRowScorch(state, 'rs1', 0)

    expect(next.players[0].board.melee.cards.find((c) => c.id === 'own1')).toBeDefined()
  })

  it('uses computed strength for threshold check — weather-reduced row does not trigger', () => {
    const rs = rowScorchUnit('rs1')
    // 3 melee units at base 5 each = 15 without weather; Blizzard reduces all to 1, total = 3 < 10
    const opp1 = unit('opp1', 5)
    const opp2 = unit('opp2', 5)
    const opp3 = unit('opp3', 5)
    const p0 = emptyPlayer({ hand: [rs] })
    const p1 = emptyPlayer({
      board: {
        melee: { type: ROWS.MELEE, cards: [opp1, opp2, opp3], warCry: false },
        ranged: emptyRow(ROWS.RANGED),
        siege: emptyRow(ROWS.SIEGE),
      },
    })
    const state = gameState(p0, p1, { weatherZone: [weatherCard(WEATHER.BLIZZARD)] })
    const next = resolveRowScorch(state, 'rs1', 0)

    expect(next.players[1].board.melee.cards).toHaveLength(3)
  })

  it('is row-scoped — targets only the same row type as the unit', () => {
    const rs = rowScorchUnit('rs1', { row: ROWS.RANGED })
    const meleeOpp = unit('m1', 10)
    const rangedOpp1 = unit('r1', 8, { row: ROWS.RANGED })
    const rangedOpp2 = unit('r2', 5, { row: ROWS.RANGED })
    const p0 = emptyPlayer({ hand: [rs] })
    const p1 = emptyPlayer({
      board: {
        melee: { type: ROWS.MELEE, cards: [meleeOpp], warCry: false },
        ranged: { type: ROWS.RANGED, cards: [rangedOpp1, rangedOpp2], warCry: false },
        siege: emptyRow(ROWS.SIEGE),
      },
    })
    const state = gameState(p0, p1)
    const next = resolveRowScorch(state, 'rs1', 0)

    // Ranged row total = 13 >= 10, triggers, destroys highest (r1, 8)
    expect(next.players[1].board.ranged.cards.find((c) => c.id === 'r1')).toBeUndefined()
    expect(next.players[1].board.ranged.cards.find((c) => c.id === 'r2')).toBeDefined()
    // Melee row is not touched
    expect(next.players[1].board.melee.cards.find((c) => c.id === 'm1')).toBeDefined()
  })

  it('works correctly when playerIndex is 1', () => {
    const rs = rowScorchUnit('rs1')
    const opp1 = unit('opp1', 8)
    const opp2 = unit('opp2', 5)
    const p1 = emptyPlayer({ hand: [rs] })
    const p0 = emptyPlayer({
      board: {
        melee: { type: ROWS.MELEE, cards: [opp1, opp2], warCry: false },
        ranged: emptyRow(ROWS.RANGED),
        siege: emptyRow(ROWS.SIEGE),
      },
    })
    const state = gameState(p0, p1)
    const next = resolveRowScorch(state, 'rs1', 1)

    expect(next.players[1].board.melee.cards.find((c) => c.id === 'rs1')).toBeDefined()
    expect(next.players[0].board.melee.cards.find((c) => c.id === 'opp1')).toBeUndefined()
    expect(next.players[0].discard.find((c) => c.id === 'opp1')).toBeDefined()
  })
})
