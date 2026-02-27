import { describe, expect, it } from 'vitest'
import { ABILITIES, ROWS } from '@/lib/terminology'
import type { UnitCard } from '@/types/game'
import { canBeTargeted } from './hero'

function unit(opts: Partial<UnitCard> = {}): UnitCard {
  return {
    id: 'u1',
    type: 'unit',
    name: 'Test',
    faction: 'Neutral',
    row: ROWS.MELEE,
    baseStrength: 5,
    ability: null,
    isHero: false,
    rallyGroup: null,
    ...opts,
  }
}

describe('canBeTargeted', () => {
  it('returns true for a non-hero unit', () => {
    expect(canBeTargeted(unit())).toBe(true)
  })

  it('returns false for a hero', () => {
    expect(canBeTargeted(unit({ isHero: true, ability: ABILITIES.HERO }))).toBe(false)
  })
})
