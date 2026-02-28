import { describe, expect, it } from 'vitest'
import { WEATHER } from '@/lib/terminology'
import type { GameState, PlayerState, RowState, RowType, WeatherCard } from '@/types/game'
import { resolveWeather } from './weather'

function weatherCard(
  weatherType: (typeof WEATHER)[keyof typeof WEATHER],
  id?: string,
): WeatherCard {
  return {
    id: id ?? `w-${weatherType}`,
    type: 'weather',
    name: weatherType,
    weatherType,
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
      melee: emptyRow('Melee'),
      ranged: emptyRow('Ranged'),
      siege: emptyRow('Siege'),
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

describe('resolveWeather', () => {
  it('returns state unchanged if cardId is not in hand', () => {
    const state = gameState(emptyPlayer(), emptyPlayer())
    expect(resolveWeather(state, 'missing', 0)).toBe(state)
  })

  it('removes the weather card from hand', () => {
    const card = weatherCard(WEATHER.BLIZZARD)
    const state = gameState(emptyPlayer({ hand: [card] }), emptyPlayer())
    const next = resolveWeather(state, card.id, 0)
    expect(next.players[0].hand.find((c) => c.id === card.id)).toBeUndefined()
  })

  it('adds the weather card to the weather zone', () => {
    const card = weatherCard(WEATHER.BLIZZARD)
    const state = gameState(emptyPlayer({ hand: [card] }), emptyPlayer())
    const next = resolveWeather(state, card.id, 0)
    expect(next.weatherZone.find((c) => c.id === card.id)).toBeDefined()
  })

  it('does not add weather card to player discard', () => {
    const card = weatherCard(WEATHER.SHROUD)
    const state = gameState(emptyPlayer({ hand: [card] }), emptyPlayer())
    const next = resolveWeather(state, card.id, 0)
    expect(next.players[0].discard).toHaveLength(0)
  })

  it('multiple weather types stack in the weather zone', () => {
    const blizzard = weatherCard(WEATHER.BLIZZARD)
    const shroud = weatherCard(WEATHER.SHROUD)
    const p0 = emptyPlayer({ hand: [blizzard, shroud] })
    const state = gameState(p0, emptyPlayer())
    const after1 = resolveWeather(state, blizzard.id, 0)
    const after2 = resolveWeather(after1, shroud.id, 0)
    expect(after2.weatherZone).toHaveLength(2)
    expect(after2.weatherZone.find((c) => c.weatherType === WEATHER.BLIZZARD)).toBeDefined()
    expect(after2.weatherZone.find((c) => c.weatherType === WEATHER.SHROUD)).toBeDefined()
  })

  it('Dispel clears all weather from the zone', () => {
    const dispel = weatherCard(WEATHER.DISPEL)
    const p0 = emptyPlayer({ hand: [dispel] })
    const state = gameState(p0, emptyPlayer(), {
      weatherZone: [weatherCard(WEATHER.BLIZZARD), weatherCard(WEATHER.SHROUD)],
    })
    const next = resolveWeather(state, dispel.id, 0)
    expect(next.weatherZone).toHaveLength(0)
  })

  it('Dispel card goes to player discard', () => {
    const dispel = weatherCard(WEATHER.DISPEL)
    const state = gameState(emptyPlayer({ hand: [dispel] }), emptyPlayer())
    const next = resolveWeather(state, dispel.id, 0)
    expect(next.players[0].discard.find((c) => c.id === dispel.id)).toBeDefined()
  })

  it('Dispel removes Dispel card from hand', () => {
    const dispel = weatherCard(WEATHER.DISPEL)
    const state = gameState(emptyPlayer({ hand: [dispel] }), emptyPlayer())
    const next = resolveWeather(state, dispel.id, 0)
    expect(next.players[0].hand.find((c) => c.id === dispel.id)).toBeUndefined()
  })

  it('Dispel on empty weather zone just clears and goes to discard', () => {
    const dispel = weatherCard(WEATHER.DISPEL)
    const state = gameState(emptyPlayer({ hand: [dispel] }), emptyPlayer())
    const next = resolveWeather(state, dispel.id, 0)
    expect(next.weatherZone).toHaveLength(0)
    expect(next.players[0].discard.find((c) => c.id === dispel.id)).toBeDefined()
  })

  it('does not modify the opponent', () => {
    const card = weatherCard(WEATHER.DELUGE)
    const state = gameState(emptyPlayer({ hand: [card] }), emptyPlayer())
    const next = resolveWeather(state, card.id, 0)
    expect(next.players[1]).toBe(state.players[1])
  })

  it('works correctly when playerIndex is 1', () => {
    const card = weatherCard(WEATHER.SHROUD)
    const state = gameState(emptyPlayer(), emptyPlayer({ hand: [card] }))
    const next = resolveWeather(state, card.id, 1)
    expect(next.players[1].hand.find((c) => c.id === card.id)).toBeUndefined()
    expect(next.weatherZone.find((c) => c.id === card.id)).toBeDefined()
    expect(next.players[0]).toBe(state.players[0])
  })

  it('works correctly when playerIndex is 1 with Dispel', () => {
    const dispel = weatherCard(WEATHER.DISPEL)
    const state = gameState(emptyPlayer(), emptyPlayer({ hand: [dispel] }), {
      weatherZone: [weatherCard(WEATHER.BLIZZARD)],
    })
    const next = resolveWeather(state, dispel.id, 1)
    expect(next.weatherZone).toHaveLength(0)
    expect(next.players[1].discard.find((c) => c.id === dispel.id)).toBeDefined()
    expect(next.players[0]).toBe(state.players[0])
  })
})
