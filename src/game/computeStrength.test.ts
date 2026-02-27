import { describe, expect, it } from 'vitest'
import { ABILITIES, ROWS, WEATHER } from '@/lib/terminology'
import type { GameState, RowState, UnitCard, WeatherCard } from '@/types/game'
import { computeStrength } from './computeStrength'

function card(
  id: string,
  name: string,
  baseStrength: number,
  opts: Partial<UnitCard> = {},
): UnitCard {
  return {
    id,
    type: 'unit',
    name,
    faction: 'Neutral',
    row: ROWS.MELEE,
    baseStrength,
    ability: null,
    isHero: false,
    rallyGroup: null,
    ...opts,
  }
}

function rowState(
  type: (typeof ROWS)[keyof typeof ROWS],
  cards: UnitCard[],
  warCry = false,
): RowState {
  return { type, cards, warCry }
}

function gameState(weatherCards: WeatherCard[] = []): GameState {
  const emptyRow = (type: (typeof ROWS)[keyof typeof ROWS]): RowState => ({
    type,
    cards: [],
    warCry: false,
  })
  const emptyPlayer = {
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
  }
  return {
    players: [emptyPlayer, emptyPlayer],
    weatherZone: weatherCards,
    round: 1,
    activePlayer: 0,
    selectionMode: 'default',
  }
}

function weatherCard(weatherType: (typeof WEATHER)[keyof typeof WEATHER]): WeatherCard {
  return { id: `w-${weatherType}`, type: 'weather', name: weatherType, weatherType }
}

describe('computeStrength', () => {
  it('returns 0 for a card not in the row', () => {
    const row = rowState(ROWS.MELEE, [card('a', 'A', 5)])
    expect(computeStrength('missing', row, gameState())).toBe(0)
  })

  it('returns base strength for a plain unit with no modifiers', () => {
    const c = card('a', 'A', 7)
    const row = rowState(ROWS.MELEE, [c])
    expect(computeStrength('a', row, gameState())).toBe(7)
  })

  describe('heroes', () => {
    it('always returns base strength regardless of weather', () => {
      const hero = card('h', 'Hero', 15, { isHero: true, ability: ABILITIES.HERO })
      const row = rowState(ROWS.MELEE, [hero])
      expect(computeStrength('h', row, gameState([weatherCard(WEATHER.BLIZZARD)]))).toBe(15)
    })

    it('is unaffected by Morale Boost in the same row', () => {
      const hero = card('h', 'Hero', 10, { isHero: true, ability: ABILITIES.HERO })
      const boost = card('b', 'Boost', 3, { ability: ABILITIES.MORALE_BOOST })
      const row = rowState(ROWS.MELEE, [hero, boost])
      expect(computeStrength('h', row, gameState())).toBe(10)
    })

    it('is unaffected by War Cry', () => {
      const hero = card('h', 'Hero', 12, { isHero: true, ability: ABILITIES.HERO })
      const row = rowState(ROWS.MELEE, [hero], true)
      expect(computeStrength('h', row, gameState())).toBe(12)
    })
  })

  describe('weather', () => {
    it('Blizzard caps Melee units at 1', () => {
      const c = card('a', 'A', 9)
      const row = rowState(ROWS.MELEE, [c])
      expect(computeStrength('a', row, gameState([weatherCard(WEATHER.BLIZZARD)]))).toBe(1)
    })

    it('Shroud caps Ranged units at 1', () => {
      const c = card('a', 'A', 8, { row: ROWS.RANGED })
      const row = rowState(ROWS.RANGED, [c])
      expect(computeStrength('a', row, gameState([weatherCard(WEATHER.SHROUD)]))).toBe(1)
    })

    it('Deluge caps Siege units at 1', () => {
      const c = card('a', 'A', 6, { row: ROWS.SIEGE })
      const row = rowState(ROWS.SIEGE, [c])
      expect(computeStrength('a', row, gameState([weatherCard(WEATHER.DELUGE)]))).toBe(1)
    })

    it('Blizzard does not affect Ranged units', () => {
      const c = card('a', 'A', 6, { row: ROWS.RANGED })
      const row = rowState(ROWS.RANGED, [c])
      expect(computeStrength('a', row, gameState([weatherCard(WEATHER.BLIZZARD)]))).toBe(6)
    })
  })

  describe('Formation', () => {
    it('2 Formation cards each show base × 2', () => {
      const c1 = card('a', 'FA_F1', 8, { ability: ABILITIES.FORMATION })
      const c2 = card('b', 'FA_F1', 8, { ability: ABILITIES.FORMATION })
      const row = rowState(ROWS.MELEE, [c1, c2])
      expect(computeStrength('a', row, gameState())).toBe(16)
      expect(computeStrength('b', row, gameState())).toBe(16)
    })

    it('3 Formation cards each show base × 3', () => {
      const c1 = card('a', 'FA_F1', 8, { ability: ABILITIES.FORMATION })
      const c2 = card('b', 'FA_F1', 8, { ability: ABILITIES.FORMATION })
      const c3 = card('c', 'FA_F1', 8, { ability: ABILITIES.FORMATION })
      const row = rowState(ROWS.MELEE, [c1, c2, c3])
      expect(computeStrength('a', row, gameState())).toBe(24)
      expect(computeStrength('b', row, gameState())).toBe(24)
      expect(computeStrength('c', row, gameState())).toBe(24)
    })

    it('Formation pair under weather shows 1', () => {
      const c1 = card('a', 'FA_F1', 8, { ability: ABILITIES.FORMATION })
      const c2 = card('b', 'FA_F1', 8, { ability: ABILITIES.FORMATION })
      const row = rowState(ROWS.MELEE, [c1, c2])
      expect(computeStrength('a', row, gameState([weatherCard(WEATHER.BLIZZARD)]))).toBe(1)
      expect(computeStrength('b', row, gameState([weatherCard(WEATHER.BLIZZARD)]))).toBe(1)
    })

    it('Formation pair with War Cry shows base × 2 × 2', () => {
      const c1 = card('a', 'FA_F1', 8, { ability: ABILITIES.FORMATION })
      const c2 = card('b', 'FA_F1', 8, { ability: ABILITIES.FORMATION })
      const row = rowState(ROWS.MELEE, [c1, c2], true)
      expect(computeStrength('a', row, gameState())).toBe(32)
      expect(computeStrength('b', row, gameState())).toBe(32)
    })

    it('Formation is name-scoped — different names do not multiply', () => {
      const c1 = card('a', 'FA_F1', 8, { ability: ABILITIES.FORMATION })
      const c2 = card('b', 'FA_F2', 8, { ability: ABILITIES.FORMATION })
      const row = rowState(ROWS.MELEE, [c1, c2])
      expect(computeStrength('a', row, gameState())).toBe(8)
      expect(computeStrength('b', row, gameState())).toBe(8)
    })
  })

  describe('Morale Boost', () => {
    it('adds 1 per Morale Boost unit in the row', () => {
      const c = card('a', 'A', 5)
      const boost = card('b', 'Boost', 3, { ability: ABILITIES.MORALE_BOOST })
      const row = rowState(ROWS.MELEE, [c, boost])
      expect(computeStrength('a', row, gameState())).toBe(6)
    })

    it('multiple Morale Boost cards stack', () => {
      const c = card('a', 'A', 5)
      const b1 = card('b', 'Boost', 3, { ability: ABILITIES.MORALE_BOOST })
      const b2 = card('c', 'Boost2', 2, { ability: ABILITIES.MORALE_BOOST })
      const row = rowState(ROWS.MELEE, [c, b1, b2])
      expect(computeStrength('a', row, gameState())).toBe(7)
    })

    it('Morale Boost does not boost itself', () => {
      const boost = card('b', 'Boost', 3, { ability: ABILITIES.MORALE_BOOST })
      const row = rowState(ROWS.MELEE, [boost])
      expect(computeStrength('b', row, gameState())).toBe(3)
    })

    it('Morale Boost applies after weather — no effect when weather caps at 1', () => {
      const c = card('a', 'A', 5)
      const boost = card('b', 'Boost', 3, { ability: ABILITIES.MORALE_BOOST })
      const row = rowState(ROWS.MELEE, [c, boost])
      expect(computeStrength('a', row, gameState([weatherCard(WEATHER.BLIZZARD)]))).toBe(1)
    })
  })

  describe('War Cry', () => {
    it('doubles strength when War Cry is active on the row', () => {
      const c = card('a', 'A', 7)
      const row = rowState(ROWS.MELEE, [c], true)
      expect(computeStrength('a', row, gameState())).toBe(14)
    })

    it('War Cry applies after Morale Boost', () => {
      const c = card('a', 'A', 5)
      const boost = card('b', 'Boost', 3, { ability: ABILITIES.MORALE_BOOST })
      const row = rowState(ROWS.MELEE, [c, boost], true)
      // (5 + 1) × 2 = 12
      expect(computeStrength('a', row, gameState())).toBe(12)
    })

    it('weather-reduced card with War Cry shows 1 (weather applied first)', () => {
      const c = card('a', 'A', 5)
      const row = rowState(ROWS.MELEE, [c], true)
      expect(computeStrength('a', row, gameState([weatherCard(WEATHER.BLIZZARD)]))).toBe(1)
    })
  })
})
