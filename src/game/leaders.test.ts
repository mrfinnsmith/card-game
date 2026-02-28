import { describe, expect, it } from 'vitest'
import { ABILITIES, FACTIONS, ROWS, WEATHER } from '@/lib/terminology'
import type { GameState, PlayerFaction, PlayerState, UnitCard, WeatherCard } from '@/types/game'
import { computeStrength } from './computeStrength'
import {
  leaderA1,
  leaderA2,
  leaderA3,
  leaderA4,
  leaderA5,
  leaderB1,
  leaderB2,
  leaderB3,
  leaderB4,
  leaderB5,
  leaderC1,
  leaderC2,
  leaderC3,
  leaderC4,
  leaderC5,
  leaderD1,
  leaderD2,
  leaderD3,
  leaderD4,
  leaderD5,
} from './leaders'

function unit(id: string, opts: Partial<UnitCard> = {}): UnitCard {
  return {
    id,
    type: 'unit',
    name: `Card_${id}`,
    faction: FACTIONS.A,
    row: ROWS.MELEE,
    baseStrength: 5,
    ability: null,
    isHero: false,
    rallyGroup: null,
    ...opts,
  }
}

function weatherCard(id: string, weatherType: (typeof WEATHER)[keyof typeof WEATHER]): WeatherCard {
  return { id, type: 'weather', name: weatherType, weatherType }
}

function emptyPlayer(faction: PlayerFaction, overrides: Partial<PlayerState> = {}): PlayerState {
  const emptyRow = (type: (typeof ROWS)[keyof typeof ROWS]) => ({ type, cards: [], warCry: false })
  return {
    faction,
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

function gameState(
  p0: PlayerState,
  p1: PlayerState,
  overrides: Partial<GameState> = {},
): GameState {
  return {
    players: [p0, p1],
    weatherZone: [],
    round: 1,
    activePlayer: 0,
    selectionMode: 'default',
    pendingOptions: [],
    randomRestoration: false,
    leaderD1Active: false,
    ...overrides,
  }
}

function stateWithOpponentRow(
  playerIndex: 0 | 1,
  rowKey: 'melee' | 'ranged' | 'siege',
  cards: UnitCard[],
): GameState {
  const opponentIndex: 0 | 1 = playerIndex === 0 ? 1 : 0
  const opponentBoard = {
    melee: { type: ROWS.MELEE, cards: rowKey === 'melee' ? cards : [], warCry: false },
    ranged: { type: ROWS.RANGED, cards: rowKey === 'ranged' ? cards : [], warCry: false },
    siege: { type: ROWS.SIEGE, cards: rowKey === 'siege' ? cards : [], warCry: false },
  }
  const opponent = emptyPlayer(FACTIONS.B, { board: opponentBoard })
  const player = emptyPlayer(FACTIONS.A)
  return opponentIndex === 1 ? gameState(player, opponent) : gameState(opponent, player)
}

// ---- Faction A ----

describe('leaderA1', () => {
  it('plays Shroud from deck to weatherZone', () => {
    const shroud = weatherCard('w1', WEATHER.SHROUD)
    const p0 = emptyPlayer(FACTIONS.A, { deck: [shroud] })
    const state = gameState(p0, emptyPlayer(FACTIONS.B))

    const next = leaderA1(state, 0)

    expect(next.weatherZone).toHaveLength(1)
    expect(next.weatherZone[0].weatherType).toBe(WEATHER.SHROUD)
    expect(next.players[0].deck).toHaveLength(0)
    expect(next.players[0].leaderAbilityUsed).toBe(true)
  })

  it('does nothing if Shroud is not in deck', () => {
    const state = gameState(emptyPlayer(FACTIONS.A), emptyPlayer(FACTIONS.B))
    const next = leaderA1(state, 0)
    expect(next.weatherZone).toHaveLength(0)
  })
})

describe('leaderA2', () => {
  it('clears all weather from weatherZone', () => {
    const state = gameState(emptyPlayer(FACTIONS.A), emptyPlayer(FACTIONS.B), {
      weatherZone: [weatherCard('w1', WEATHER.BLIZZARD), weatherCard('w2', WEATHER.SHROUD)],
    })
    const next = leaderA2(state, 0)
    expect(next.weatherZone).toHaveLength(0)
    expect(next.players[0].leaderAbilityUsed).toBe(true)
  })
})

describe('leaderA3', () => {
  it('destroys opponent strongest Ranged unit when row total ≥ 10', () => {
    const u1 = unit('u1', { row: ROWS.RANGED, baseStrength: 6 })
    const u2 = unit('u2', { row: ROWS.RANGED, baseStrength: 5 })
    const state = stateWithOpponentRow(0, 'ranged', [u1, u2])

    const next = leaderA3(state, 0)

    expect(next.players[1].board.ranged.cards.map((c) => c.id)).not.toContain('u1')
    expect(next.players[1].board.ranged.cards.map((c) => c.id)).toContain('u2')
    expect(next.players[0].leaderAbilityUsed).toBe(true)
  })

  it('does nothing when opponent Ranged row total < 10', () => {
    const u1 = unit('u1', { row: ROWS.RANGED, baseStrength: 4 })
    const u2 = unit('u2', { row: ROWS.RANGED, baseStrength: 4 })
    const state = stateWithOpponentRow(0, 'ranged', [u1, u2])

    const next = leaderA3(state, 0)

    expect(next.players[1].board.ranged.cards).toHaveLength(2)
  })

  it('heroes survive — strongest non-hero is destroyed', () => {
    const hero = unit('h1', {
      row: ROWS.RANGED,
      baseStrength: 10,
      isHero: true,
      ability: ABILITIES.HERO,
    })
    const u1 = unit('u1', { row: ROWS.RANGED, baseStrength: 5 })
    const state = stateWithOpponentRow(0, 'ranged', [hero, u1])

    const next = leaderA3(state, 0)

    expect(next.players[1].board.ranged.cards.map((c) => c.id)).toContain('h1')
    expect(next.players[1].board.ranged.cards.map((c) => c.id)).not.toContain('u1')
  })
})

describe('leaderA4', () => {
  it('sets warCry on player Siege row', () => {
    const state = gameState(emptyPlayer(FACTIONS.A), emptyPlayer(FACTIONS.B))
    const next = leaderA4(state, 0)
    expect(next.players[0].board.siege.warCry).toBe(true)
    expect(next.players[0].leaderAbilityUsed).toBe(true)
  })

  it('does not set warCry again if already set', () => {
    const p0 = emptyPlayer(FACTIONS.A, {
      board: {
        melee: { type: ROWS.MELEE, cards: [], warCry: false },
        ranged: { type: ROWS.RANGED, cards: [], warCry: false },
        siege: { type: ROWS.SIEGE, cards: [], warCry: true },
      },
    })
    const state = gameState(p0, emptyPlayer(FACTIONS.B))
    const next = leaderA4(state, 0)
    expect(next.players[0].board.siege.warCry).toBe(true)
    expect(next.players[0].leaderAbilityUsed).toBe(true)
  })
})

describe('leaderA5', () => {
  it('destroys opponent strongest Siege unit when row total ≥ 10', () => {
    const u1 = unit('u1', { row: ROWS.SIEGE, baseStrength: 8 })
    const u2 = unit('u2', { row: ROWS.SIEGE, baseStrength: 5 })
    const state = stateWithOpponentRow(0, 'siege', [u1, u2])

    const next = leaderA5(state, 0)

    expect(next.players[1].board.siege.cards.map((c) => c.id)).not.toContain('u1')
    expect(next.players[1].board.siege.cards.map((c) => c.id)).toContain('u2')
    expect(next.players[0].leaderAbilityUsed).toBe(true)
  })
})

// ---- Faction B ----

describe('leaderB1', () => {
  it('reveals 3 random cards from opponent hand', () => {
    const cards = [unit('c1'), unit('c2'), unit('c3'), unit('c4'), unit('c5')]
    const p1 = emptyPlayer(FACTIONS.B, { hand: cards })
    const state = gameState(emptyPlayer(FACTIONS.A), p1)

    const { state: next, revealed } = leaderB1(state, 0, () => 0)

    expect(revealed).toHaveLength(3)
    expect(next.players[0].leaderAbilityUsed).toBe(true)
  })

  it('reveals all cards if opponent hand has fewer than 3', () => {
    const p1 = emptyPlayer(FACTIONS.B, { hand: [unit('c1'), unit('c2')] })
    const state = gameState(emptyPlayer(FACTIONS.A), p1)

    const { revealed } = leaderB1(state, 0, () => 0)

    expect(revealed).toHaveLength(2)
  })

  it('does not modify opponent hand', () => {
    const cards = [unit('c1'), unit('c2'), unit('c3')]
    const p1 = emptyPlayer(FACTIONS.B, { hand: cards })
    const state = gameState(emptyPlayer(FACTIONS.A), p1)

    const { state: next } = leaderB1(state, 0, () => 0)

    expect(next.players[1].hand).toHaveLength(3)
  })
})

describe('leaderB2', () => {
  it('plays Deluge from deck to weatherZone', () => {
    const deluge = weatherCard('w1', WEATHER.DELUGE)
    const p0 = emptyPlayer(FACTIONS.B, { deck: [deluge] })
    const state = gameState(p0, emptyPlayer(FACTIONS.A))

    const next = leaderB2(state, 0)

    expect(next.weatherZone).toHaveLength(1)
    expect(next.weatherZone[0].weatherType).toBe(WEATHER.DELUGE)
    expect(next.players[0].deck).toHaveLength(0)
    expect(next.players[0].leaderAbilityUsed).toBe(true)
  })
})

describe('leaderB3', () => {
  it('sets randomRestoration to true', () => {
    const state = gameState(emptyPlayer(FACTIONS.B), emptyPlayer(FACTIONS.A))
    const next = leaderB3(state, 0)
    expect(next.randomRestoration).toBe(true)
    expect(next.players[0].leaderAbilityUsed).toBe(true)
  })
})

describe('leaderB4', () => {
  it('moves chosen card from opponent discard to player hand', () => {
    const card = unit('c1')
    const p1 = emptyPlayer(FACTIONS.A, { discard: [card] })
    const state = gameState(emptyPlayer(FACTIONS.B), p1)

    const next = leaderB4(state, 0, 'c1')

    expect(next.players[0].hand.map((c) => c.id)).toContain('c1')
    expect(next.players[1].discard).toHaveLength(0)
    expect(next.players[0].leaderAbilityUsed).toBe(true)
  })

  it('marks used even if card not found in opponent discard', () => {
    const state = gameState(emptyPlayer(FACTIONS.B), emptyPlayer(FACTIONS.A))
    const next = leaderB4(state, 0, 'nonexistent')
    expect(next.players[0].hand).toHaveLength(0)
    expect(next.players[0].leaderAbilityUsed).toBe(true)
  })
})

describe('leaderB5', () => {
  it('marks opponent leaderAbilityUsed when they have not used it', () => {
    const state = gameState(emptyPlayer(FACTIONS.B), emptyPlayer(FACTIONS.A))
    const next = leaderB5(state, 0)
    expect(next.players[1].leaderAbilityUsed).toBe(true)
    expect(next.players[0].leaderAbilityUsed).toBe(true)
  })

  it('still marks own leaderAbilityUsed even if opponent already used theirs', () => {
    const p1 = emptyPlayer(FACTIONS.A, { leaderAbilityUsed: true })
    const state = gameState(emptyPlayer(FACTIONS.B), p1)
    const next = leaderB5(state, 0)
    expect(next.players[0].leaderAbilityUsed).toBe(true)
    expect(next.players[1].leaderAbilityUsed).toBe(true)
  })

  it('works when player 1 uses B5 on player 0', () => {
    const state = gameState(emptyPlayer(FACTIONS.A), emptyPlayer(FACTIONS.B))
    const next = leaderB5(state, 1)
    expect(next.players[0].leaderAbilityUsed).toBe(true)
    expect(next.players[1].leaderAbilityUsed).toBe(true)
  })
})

// ---- Faction C ----

describe('leaderC1', () => {
  it('draws 1 card from deck', () => {
    const card = unit('c1')
    const p0 = emptyPlayer(FACTIONS.C, { deck: [card] })
    const state = gameState(p0, emptyPlayer(FACTIONS.A))

    const next = leaderC1(state, 0)

    expect(next.players[0].hand).toHaveLength(1)
    expect(next.players[0].hand[0].id).toBe('c1')
    expect(next.players[0].deck).toHaveLength(0)
    expect(next.players[0].leaderAbilityUsed).toBe(true)
  })

  it('marks used even if deck is empty', () => {
    const state = gameState(emptyPlayer(FACTIONS.C), emptyPlayer(FACTIONS.A))
    const next = leaderC1(state, 0)
    expect(next.players[0].leaderAbilityUsed).toBe(true)
  })
})

describe('leaderC2', () => {
  it('moves Agile card from Ranged to Melee when Melee gives higher strength', () => {
    const agile = unit('ag1', { row: ROWS.RANGED, baseStrength: 5, ability: ABILITIES.AGILE })
    const meleeBoost1 = unit('mb1', {
      row: ROWS.MELEE,
      baseStrength: 2,
      ability: ABILITIES.MORALE_BOOST,
    })
    const meleeBoost2 = unit('mb2', {
      row: ROWS.MELEE,
      baseStrength: 2,
      ability: ABILITIES.MORALE_BOOST,
    })
    const rangedBoost = unit('rb1', {
      row: ROWS.RANGED,
      baseStrength: 2,
      ability: ABILITIES.MORALE_BOOST,
    })
    const p0 = emptyPlayer(FACTIONS.C, {
      board: {
        melee: { type: ROWS.MELEE, cards: [meleeBoost1, meleeBoost2], warCry: false },
        ranged: { type: ROWS.RANGED, cards: [agile, rangedBoost], warCry: false },
        siege: { type: ROWS.SIEGE, cards: [], warCry: false },
      },
    })
    const state = gameState(p0, emptyPlayer(FACTIONS.A))

    const next = leaderC2(state, 0)

    // In Ranged: agile gets +1 from rangedBoost = 6
    // In Melee: agile gets +2 from two meleeBoosts = 7 — move to Melee
    expect(next.players[0].board.melee.cards.map((c) => c.id)).toContain('ag1')
    expect(next.players[0].board.ranged.cards.map((c) => c.id)).not.toContain('ag1')
    expect(next.players[0].leaderAbilityUsed).toBe(true)
  })

  it('keeps Agile card in Melee when strengths are equal (tie defaults to Melee)', () => {
    const agile = unit('ag1', { row: ROWS.MELEE, baseStrength: 5, ability: ABILITIES.AGILE })
    const p0 = emptyPlayer(FACTIONS.C, {
      board: {
        melee: { type: ROWS.MELEE, cards: [agile], warCry: false },
        ranged: { type: ROWS.RANGED, cards: [], warCry: false },
        siege: { type: ROWS.SIEGE, cards: [], warCry: false },
      },
    })
    const state = gameState(p0, emptyPlayer(FACTIONS.A))

    const next = leaderC2(state, 0)

    expect(next.players[0].board.melee.cards.map((c) => c.id)).toContain('ag1')
    expect(next.players[0].board.ranged.cards.map((c) => c.id)).not.toContain('ag1')
  })

  it('moves Agile card from Ranged to Melee when strengths are equal (tie defaults to Melee)', () => {
    const agile = unit('ag1', { row: ROWS.RANGED, baseStrength: 5, ability: ABILITIES.AGILE })
    const p0 = emptyPlayer(FACTIONS.C, {
      board: {
        melee: { type: ROWS.MELEE, cards: [], warCry: false },
        ranged: { type: ROWS.RANGED, cards: [agile], warCry: false },
        siege: { type: ROWS.SIEGE, cards: [], warCry: false },
      },
    })
    const state = gameState(p0, emptyPlayer(FACTIONS.A))

    const next = leaderC2(state, 0)

    expect(next.players[0].board.melee.cards.map((c) => c.id)).toContain('ag1')
    expect(next.players[0].board.ranged.cards.map((c) => c.id)).not.toContain('ag1')
  })

  it('processes cards independently — moving one affects next card evaluation', () => {
    const ag1 = unit('ag1', { row: ROWS.RANGED, baseStrength: 5, ability: ABILITIES.AGILE })
    const ag2 = unit('ag2', { row: ROWS.RANGED, baseStrength: 5, ability: ABILITIES.AGILE })
    const meleeBoost = unit('mb1', {
      row: ROWS.MELEE,
      baseStrength: 2,
      ability: ABILITIES.MORALE_BOOST,
    })
    const p0 = emptyPlayer(FACTIONS.C, {
      board: {
        melee: { type: ROWS.MELEE, cards: [meleeBoost], warCry: false },
        ranged: { type: ROWS.RANGED, cards: [ag1, ag2], warCry: false },
        siege: { type: ROWS.SIEGE, cards: [], warCry: false },
      },
    })
    const state = gameState(p0, emptyPlayer(FACTIONS.A))

    const next = leaderC2(state, 0)

    // ag1 moves to Melee (stronger there: 5+1=6 vs 5 in Ranged)
    // ag2 then evaluates: Melee has [meleeBoost, ag1] → ag2 gets +1 from meleeBoost = 6 > Ranged (5)
    // ag2 also moves to Melee
    const meleeIds = next.players[0].board.melee.cards.map((c) => c.id)
    expect(meleeIds).toContain('ag1')
    expect(meleeIds).toContain('ag2')
  })
})

describe('leaderC3', () => {
  it('plays Blizzard from deck to weatherZone', () => {
    const blizzard = weatherCard('w1', WEATHER.BLIZZARD)
    const p0 = emptyPlayer(FACTIONS.C, { deck: [blizzard] })
    const state = gameState(p0, emptyPlayer(FACTIONS.A))

    const next = leaderC3(state, 0)

    expect(next.weatherZone).toHaveLength(1)
    expect(next.weatherZone[0].weatherType).toBe(WEATHER.BLIZZARD)
    expect(next.players[0].leaderAbilityUsed).toBe(true)
  })
})

describe('leaderC4', () => {
  it('destroys opponent strongest Melee unit when row total ≥ 10', () => {
    const u1 = unit('u1', { row: ROWS.MELEE, baseStrength: 8 })
    const u2 = unit('u2', { row: ROWS.MELEE, baseStrength: 5 })
    const state = stateWithOpponentRow(0, 'melee', [u1, u2])

    const next = leaderC4(state, 0)

    expect(next.players[1].board.melee.cards.map((c) => c.id)).not.toContain('u1')
    expect(next.players[1].board.melee.cards.map((c) => c.id)).toContain('u2')
    expect(next.players[0].leaderAbilityUsed).toBe(true)
  })
})

describe('leaderC5', () => {
  it('sets warCry on player Ranged row', () => {
    const state = gameState(emptyPlayer(FACTIONS.C), emptyPlayer(FACTIONS.A))
    const next = leaderC5(state, 0)
    expect(next.players[0].board.ranged.warCry).toBe(true)
    expect(next.players[0].leaderAbilityUsed).toBe(true)
  })
})

// ---- Faction D ----

describe('leaderD1', () => {
  it('sets leaderD1Active to true', () => {
    const state = gameState(emptyPlayer(FACTIONS.D), emptyPlayer(FACTIONS.A))
    const next = leaderD1(state, 0)
    expect(next.leaderD1Active).toBe(true)
    expect(next.players[0].leaderAbilityUsed).toBe(true)
  })

  it('Infiltrator shows doubled strength when D1 is active and no War Cry on row', () => {
    const infiltrator = unit('inf1', {
      row: ROWS.MELEE,
      baseStrength: 5,
      ability: ABILITIES.INFILTRATOR,
    })
    const p1 = emptyPlayer(FACTIONS.A, {
      board: {
        melee: { type: ROWS.MELEE, cards: [infiltrator], warCry: false },
        ranged: { type: ROWS.RANGED, cards: [], warCry: false },
        siege: { type: ROWS.SIEGE, cards: [], warCry: false },
      },
    })
    const state = gameState(emptyPlayer(FACTIONS.D), p1, { leaderD1Active: true })

    const strength = computeStrength('inf1', state.players[1].board.melee, state)

    expect(strength).toBe(10)
  })

  it('Infiltrator does not get extra doubling when War Cry already active on row', () => {
    const infiltrator = unit('inf1', {
      row: ROWS.MELEE,
      baseStrength: 5,
      ability: ABILITIES.INFILTRATOR,
    })
    const p1 = emptyPlayer(FACTIONS.A, {
      board: {
        melee: { type: ROWS.MELEE, cards: [infiltrator], warCry: true },
        ranged: { type: ROWS.RANGED, cards: [], warCry: false },
        siege: { type: ROWS.SIEGE, cards: [], warCry: false },
      },
    })
    const state = gameState(emptyPlayer(FACTIONS.D), p1, { leaderD1Active: true })

    const strength = computeStrength('inf1', state.players[1].board.melee, state)

    expect(strength).toBe(10) // one doubling only: 5 × 2 = 10
  })

  it('non-Infiltrator cards are not doubled by D1', () => {
    const plain = unit('p1', { row: ROWS.MELEE, baseStrength: 5 })
    const p1 = emptyPlayer(FACTIONS.A, {
      board: {
        melee: { type: ROWS.MELEE, cards: [plain], warCry: false },
        ranged: { type: ROWS.RANGED, cards: [], warCry: false },
        siege: { type: ROWS.SIEGE, cards: [], warCry: false },
      },
    })
    const state = gameState(emptyPlayer(FACTIONS.D), p1, { leaderD1Active: true })

    const strength = computeStrength('p1', state.players[1].board.melee, state)

    expect(strength).toBe(5)
  })
})

describe('leaderD2', () => {
  it('restores chosen card from discard to hand', () => {
    const card = unit('c1')
    const p0 = emptyPlayer(FACTIONS.D, { discard: [card] })
    const state = gameState(p0, emptyPlayer(FACTIONS.A))

    const next = leaderD2(state, 0, 'c1', () => 0)

    expect(next.players[0].hand.map((c) => c.id)).toContain('c1')
    expect(next.players[0].discard).toHaveLength(0)
    expect(next.players[0].leaderAbilityUsed).toBe(true)
  })

  it('picks randomly when randomRestoration is active', () => {
    const c1 = unit('c1')
    const c2 = unit('c2')
    const p0 = emptyPlayer(FACTIONS.D, { discard: [c1, c2] })
    const state = gameState(p0, emptyPlayer(FACTIONS.A), { randomRestoration: true })

    // rng returning 0.99 → Math.floor(0.99 * 2) = 1 → c2
    const next = leaderD2(state, 0, 'c1', () => 0.99)

    expect(next.players[0].hand.map((c) => c.id)).toContain('c2')
    expect(next.players[0].hand.map((c) => c.id)).not.toContain('c1')
  })

  it('does not restore heroes', () => {
    const hero = unit('h1', { isHero: true, ability: ABILITIES.HERO })
    const p0 = emptyPlayer(FACTIONS.D, { discard: [hero] })
    const state = gameState(p0, emptyPlayer(FACTIONS.A))

    const next = leaderD2(state, 0, 'h1', () => 0)

    expect(next.players[0].hand).toHaveLength(0)
    expect(next.players[0].leaderAbilityUsed).toBe(true)
  })
})

describe('leaderD3', () => {
  it('sets warCry on player Melee row', () => {
    const state = gameState(emptyPlayer(FACTIONS.D), emptyPlayer(FACTIONS.A))
    const next = leaderD3(state, 0)
    expect(next.players[0].board.melee.warCry).toBe(true)
    expect(next.players[0].leaderAbilityUsed).toBe(true)
  })

  it('does not double warCry if already present', () => {
    const p0 = emptyPlayer(FACTIONS.D, {
      board: {
        melee: { type: ROWS.MELEE, cards: [], warCry: true },
        ranged: { type: ROWS.RANGED, cards: [], warCry: false },
        siege: { type: ROWS.SIEGE, cards: [], warCry: false },
      },
    })
    const state = gameState(p0, emptyPlayer(FACTIONS.A))
    const next = leaderD3(state, 0)
    expect(next.players[0].board.melee.warCry).toBe(true)
    expect(next.players[0].leaderAbilityUsed).toBe(true)
  })
})

describe('leaderD4', () => {
  it('discards 2 cards from hand and draws 1 chosen from deck', () => {
    const c1 = unit('c1')
    const c2 = unit('c2')
    const c3 = unit('c3')
    const d1 = unit('d1')
    const p0 = emptyPlayer(FACTIONS.D, { hand: [c1, c2, c3], deck: [d1] })
    const state = gameState(p0, emptyPlayer(FACTIONS.A))

    const next = leaderD4(state, 0, ['c1', 'c2'], 'd1')

    expect(next.players[0].hand.map((c) => c.id)).toEqual(['c3', 'd1'])
    expect(next.players[0].discard.map((c) => c.id)).toContain('c1')
    expect(next.players[0].discard.map((c) => c.id)).toContain('c2')
    expect(next.players[0].deck).toHaveLength(0)
    expect(next.players[0].leaderAbilityUsed).toBe(true)
  })
})

describe('leaderD5', () => {
  it('plays chosen weather card from deck to weatherZone', () => {
    const blizzard = weatherCard('w1', WEATHER.BLIZZARD)
    const p0 = emptyPlayer(FACTIONS.D, { deck: [blizzard] })
    const state = gameState(p0, emptyPlayer(FACTIONS.A))

    const next = leaderD5(state, 0, 'w1')

    expect(next.weatherZone).toHaveLength(1)
    expect(next.weatherZone[0].weatherType).toBe(WEATHER.BLIZZARD)
    expect(next.players[0].deck).toHaveLength(0)
    expect(next.players[0].leaderAbilityUsed).toBe(true)
  })

  it('Dispel clears all existing weather', () => {
    const dispel = weatherCard('w1', WEATHER.DISPEL)
    const p0 = emptyPlayer(FACTIONS.D, { deck: [dispel] })
    const state = gameState(p0, emptyPlayer(FACTIONS.A), {
      weatherZone: [weatherCard('w2', WEATHER.BLIZZARD)],
    })

    const next = leaderD5(state, 0, 'w1')

    expect(next.weatherZone).toHaveLength(0)
    expect(next.players[0].leaderAbilityUsed).toBe(true)
  })
})
