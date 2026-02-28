import { describe, expect, it } from 'vitest'
import { ABILITIES, FACTIONS, ROWS, WEATHER } from '@/lib/terminology'
import type {
  GameState,
  PlayerFaction,
  PlayerState,
  RowState,
  RowType,
  SpecialCard,
  UnitCard,
  WeatherCard,
} from '@/types/game'
import { computeStrength } from './computeStrength'
import { resolveRoundGems } from './factions'
import { leaderC2, leaderD1 } from './leaders'
import { completeDecoySelection, resolveDecoy } from './resolvers/decoy'
import { completeMedicSelection } from './resolvers/medic'
import { resolveScorch } from './resolvers/scorch'
import { dispatch } from './stateMachine'

// ---- Helpers ----

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

function wCard(weatherType: (typeof WEATHER)[keyof typeof WEATHER]): WeatherCard {
  return { id: `w-${weatherType}`, type: 'weather', name: weatherType, weatherType }
}

function emptyRow(type: RowType): RowState {
  return { type, cards: [], warCry: false }
}

function emptyPlayer(faction: PlayerFaction, overrides: Partial<PlayerState> = {}): PlayerState {
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
    mulligansUsed: [0, 0],
    mulliganedCardIds: [[], []],
    mulligansConfirmed: [false, false],
    roundWins: [0, 0],
    ...overrides,
  }
}

// ---- Formation with n > 2 cards ----

describe('Formation with n > 2 cards', () => {
  it('3 Formation cards each show base × 3', () => {
    const c1 = unit('f1', { name: 'FA_F1', baseStrength: 8, ability: ABILITIES.FORMATION })
    const c2 = unit('f2', { name: 'FA_F1', baseStrength: 8, ability: ABILITIES.FORMATION })
    const c3 = unit('f3', { name: 'FA_F1', baseStrength: 8, ability: ABILITIES.FORMATION })
    const row: RowState = { type: ROWS.MELEE, cards: [c1, c2, c3], warCry: false }
    const state = gameState(emptyPlayer(FACTIONS.A), emptyPlayer(FACTIONS.B))

    expect(computeStrength('f1', row, state)).toBe(24)
    expect(computeStrength('f2', row, state)).toBe(24)
    expect(computeStrength('f3', row, state)).toBe(24)
  })

  it('adding a third card recalculates all three from base × 2 to base × 3', () => {
    const c1 = unit('f1', { name: 'FA_F1', baseStrength: 8, ability: ABILITIES.FORMATION })
    const c2 = unit('f2', { name: 'FA_F1', baseStrength: 8, ability: ABILITIES.FORMATION })
    const c3 = unit('f3', { name: 'FA_F1', baseStrength: 8, ability: ABILITIES.FORMATION })
    const state = gameState(emptyPlayer(FACTIONS.A), emptyPlayer(FACTIONS.B))

    const pairRow: RowState = { type: ROWS.MELEE, cards: [c1, c2], warCry: false }
    expect(computeStrength('f1', pairRow, state)).toBe(16)

    const tripleRow: RowState = { type: ROWS.MELEE, cards: [c1, c2, c3], warCry: false }
    expect(computeStrength('f1', tripleRow, state)).toBe(24)
    expect(computeStrength('f2', tripleRow, state)).toBe(24)
    expect(computeStrength('f3', tripleRow, state)).toBe(24)
  })

  it('Formation pair under weather shows 1 regardless of Formation multiplier', () => {
    const c1 = unit('f1', { name: 'FA_F1', baseStrength: 8, ability: ABILITIES.FORMATION })
    const c2 = unit('f2', { name: 'FA_F1', baseStrength: 8, ability: ABILITIES.FORMATION })
    const row: RowState = { type: ROWS.MELEE, cards: [c1, c2], warCry: false }
    const state = gameState(emptyPlayer(FACTIONS.A), emptyPlayer(FACTIONS.B), {
      weatherZone: [wCard(WEATHER.BLIZZARD)],
    })

    expect(computeStrength('f1', row, state)).toBe(1)
    expect(computeStrength('f2', row, state)).toBe(1)
  })

  it('Formation pair with War Cry shows base × count × 2', () => {
    const c1 = unit('f1', { name: 'FA_F1', baseStrength: 8, ability: ABILITIES.FORMATION })
    const c2 = unit('f2', { name: 'FA_F1', baseStrength: 8, ability: ABILITIES.FORMATION })
    const row: RowState = { type: ROWS.MELEE, cards: [c1, c2], warCry: true }
    const state = gameState(emptyPlayer(FACTIONS.A), emptyPlayer(FACTIONS.B))

    // 8 × 2 (Formation) × 2 (War Cry) = 32
    expect(computeStrength('f1', row, state)).toBe(32)
    expect(computeStrength('f2', row, state)).toBe(32)
  })

  it('Formation is row-scoped: same name in a different row does not count toward multiplier', () => {
    const c1 = unit('f1', {
      name: 'FA_F1',
      baseStrength: 8,
      ability: ABILITIES.FORMATION,
      row: ROWS.MELEE,
    })
    const meleeRow: RowState = { type: ROWS.MELEE, cards: [c1], warCry: false }
    const state = gameState(emptyPlayer(FACTIONS.A), emptyPlayer(FACTIONS.B))

    // Only one card in melee — no Formation bonus
    expect(computeStrength('f1', meleeRow, state)).toBe(8)
  })
})

// ---- Medic → Rally chain ----

describe('Medic → Rally chain', () => {
  it('Medic reviving a Rally card triggers Rally from deck only', () => {
    const rallyRevived = unit('r1', { ability: ABILITIES.RALLY, rallyGroup: 'g1', row: ROWS.MELEE })
    const rallyInDeck1 = unit('r2', { ability: ABILITIES.RALLY, rallyGroup: 'g1', row: ROWS.MELEE })
    const rallyInDeck2 = unit('r3', { ability: ABILITIES.RALLY, rallyGroup: 'g1', row: ROWS.MELEE })
    const rallyInHand = unit('r4', { ability: ABILITIES.RALLY, rallyGroup: 'g1', row: ROWS.MELEE })
    const other = unit('o1', { row: ROWS.SIEGE })

    const p0 = emptyPlayer(FACTIONS.A, {
      hand: [rallyInHand],
      deck: [rallyInDeck1, rallyInDeck2, other],
      discard: [rallyRevived],
    })
    const state = gameState(p0, emptyPlayer(FACTIONS.B), { selectionMode: 'medic' })

    const next = completeMedicSelection(state, 'r1', 0, dispatch, () => 0)

    const board = next.players[0].board
    // Revived card is on board
    expect(board.melee.cards.find((c) => c.id === 'r1')).toBeDefined()
    // Rally pulled deck copies to board
    expect(board.melee.cards.find((c) => c.id === 'r2')).toBeDefined()
    expect(board.melee.cards.find((c) => c.id === 'r3')).toBeDefined()
    // Hand copy is NOT auto-played
    expect(next.players[0].hand.find((c) => c.id === 'r4')).toBeDefined()
    expect(board.melee.cards.find((c) => c.id === 'r4')).toBeUndefined()
    // Other deck card remains
    expect(next.players[0].deck.find((c) => c.id === 'o1')).toBeDefined()
    // Rally group cards are gone from deck
    expect(next.players[0].deck.find((c) => c.id === 'r2')).toBeUndefined()
    expect(next.players[0].deck.find((c) => c.id === 'r3')).toBeUndefined()
  })

  it('Rallied cards placed by the chain do not trigger Rally further', () => {
    const rallyRevived = unit('r1', { ability: ABILITIES.RALLY, rallyGroup: 'g1', row: ROWS.MELEE })
    const rallyInDeck = unit('r2', { ability: ABILITIES.RALLY, rallyGroup: 'g1', row: ROWS.MELEE })

    const p0 = emptyPlayer(FACTIONS.A, {
      hand: [],
      deck: [rallyInDeck],
      discard: [rallyRevived],
    })
    const state = gameState(p0, emptyPlayer(FACTIONS.B), { selectionMode: 'medic' })

    const next = completeMedicSelection(state, 'r1', 0, dispatch, () => 0)

    const board = next.players[0].board
    expect(board.melee.cards).toHaveLength(2)
    expect(board.melee.cards.find((c) => c.id === 'r1')).toBeDefined()
    expect(board.melee.cards.find((c) => c.id === 'r2')).toBeDefined()
    // Deck is exhausted — no infinite chain occurred
    expect(next.players[0].deck).toHaveLength(0)
  })
})

// ---- Scorch with weather-affected cards ----

describe('Scorch with weather-affected cards', () => {
  it('destroys all units when every unit is weather-reduced to 1', () => {
    const scorch: SpecialCard = {
      id: 'sc1',
      type: 'special',
      name: 'Scorch',
      ability: ABILITIES.SCORCH,
    }
    const u1 = unit('u1', { baseStrength: 8, row: ROWS.MELEE })
    const u2 = unit('u2', { baseStrength: 6, row: ROWS.MELEE })
    const u3 = unit('u3', { baseStrength: 9, row: ROWS.RANGED })

    const p0 = emptyPlayer(FACTIONS.A, {
      hand: [scorch],
      board: {
        melee: { type: ROWS.MELEE, cards: [u1, u2], warCry: false },
        ranged: { type: ROWS.RANGED, cards: [u3], warCry: false },
        siege: emptyRow(ROWS.SIEGE),
      },
    })
    // Blizzard + Shroud: all units capped at 1
    const state = gameState(p0, emptyPlayer(FACTIONS.B), {
      weatherZone: [wCard(WEATHER.BLIZZARD), wCard(WEATHER.SHROUD)],
    })

    const next = resolveScorch(state, 'sc1', 0)

    expect(next.players[0].board.melee.cards).toHaveLength(0)
    expect(next.players[0].board.ranged.cards).toHaveLength(0)
  })

  it('uses computed (weather-modified) strength, not base strength, when selecting targets', () => {
    const scorch: SpecialCard = {
      id: 'sc1',
      type: 'special',
      name: 'Scorch',
      ability: ABILITIES.SCORCH,
    }
    // High base in Melee — Blizzard reduces it to 1
    const meleeUnit = unit('u1', { baseStrength: 10, row: ROWS.MELEE })
    // Lower base in Ranged — unaffected by Blizzard, so computed strength is 5
    const rangedUnit = unit('u2', { baseStrength: 5, row: ROWS.RANGED })

    const p0 = emptyPlayer(FACTIONS.A, {
      hand: [scorch],
      board: {
        melee: { type: ROWS.MELEE, cards: [meleeUnit], warCry: false },
        ranged: { type: ROWS.RANGED, cards: [rangedUnit], warCry: false },
        siege: emptyRow(ROWS.SIEGE),
      },
    })
    const state = gameState(p0, emptyPlayer(FACTIONS.B), {
      weatherZone: [wCard(WEATHER.BLIZZARD)],
    })

    const next = resolveScorch(state, 'sc1', 0)

    // Ranged unit (computed 5) is highest — destroyed
    expect(next.players[0].board.ranged.cards.find((c) => c.id === 'u2')).toBeUndefined()
    // Melee unit (computed 1) survives
    expect(next.players[0].board.melee.cards.find((c) => c.id === 'u1')).toBeDefined()
  })
})

// ---- Decoy resets card state ----

describe('Decoy resets card state', () => {
  it('returning a Formation unit recalculates remaining cards to base strength', () => {
    const decoyCard: SpecialCard = {
      id: 'dec1',
      type: 'special',
      name: 'Decoy',
      ability: ABILITIES.DECOY,
    }
    const f1 = unit('f1', { name: 'FA_F1', baseStrength: 8, ability: ABILITIES.FORMATION })
    const f2 = unit('f2', { name: 'FA_F1', baseStrength: 8, ability: ABILITIES.FORMATION })

    const p0 = emptyPlayer(FACTIONS.A, {
      hand: [decoyCard],
      board: {
        melee: { type: ROWS.MELEE, cards: [f1, f2], warCry: false },
        ranged: emptyRow(ROWS.RANGED),
        siege: emptyRow(ROWS.SIEGE),
      },
    })
    const state = gameState(p0, emptyPlayer(FACTIONS.B))

    // With two Formation cards on board, each shows 16
    expect(computeStrength('f1', p0.board.melee, state)).toBe(16)

    const afterDecoy = resolveDecoy(state, 'dec1', 0)
    expect(afterDecoy.selectionMode).toBe('decoy')

    const next = completeDecoySelection(afterDecoy, 'f1', 0)

    // f1 returned to hand
    expect(next.players[0].hand.find((c) => c.id === 'f1')).toBeDefined()
    // f2 alone on board — reverts to base
    const remainingRow = next.players[0].board.melee
    expect(remainingRow.cards).toHaveLength(1)
    expect(computeStrength('f2', remainingRow, next)).toBe(8)
  })

  it('Decoy excludes heroes from the selectable targets', () => {
    const decoyCard: SpecialCard = {
      id: 'dec1',
      type: 'special',
      name: 'Decoy',
      ability: ABILITIES.DECOY,
    }
    const hero = unit('h1', { isHero: true, ability: ABILITIES.HERO, baseStrength: 15 })
    const plain = unit('u1', { baseStrength: 5 })

    const p0 = emptyPlayer(FACTIONS.A, {
      hand: [decoyCard],
      board: {
        melee: { type: ROWS.MELEE, cards: [hero, plain], warCry: false },
        ranged: emptyRow(ROWS.RANGED),
        siege: emptyRow(ROWS.SIEGE),
      },
    })
    const state = gameState(p0, emptyPlayer(FACTIONS.B))
    const next = resolveDecoy(state, 'dec1', 0)

    expect(next.pendingOptions.find((c) => c.id === 'h1')).toBeUndefined()
    expect(next.pendingOptions.find((c) => c.id === 'u1')).toBeDefined()
  })
})

// ---- Leader C2 — Agile repositioning ----

describe('Leader C2 — Agile repositioning', () => {
  it('moves Agile card from weather-affected row to clear row', () => {
    const agile = unit('a1', { ability: ABILITIES.AGILE, baseStrength: 6, row: ROWS.MELEE })

    const p0 = emptyPlayer(FACTIONS.C, {
      board: {
        melee: { type: ROWS.MELEE, cards: [agile], warCry: false },
        ranged: emptyRow(ROWS.RANGED),
        siege: emptyRow(ROWS.SIEGE),
      },
    })
    // Blizzard: Melee computed = 1; Ranged computed = 6 (no weather)
    const state = gameState(p0, emptyPlayer(FACTIONS.B), {
      weatherZone: [wCard(WEATHER.BLIZZARD)],
    })

    const next = leaderC2(state, 0)

    expect(next.players[0].board.ranged.cards.find((c) => c.id === 'a1')).toBeDefined()
    expect(next.players[0].board.melee.cards.find((c) => c.id === 'a1')).toBeUndefined()
  })

  it('moves Agile card to Melee when both rows have equal strength (Melee preference)', () => {
    const agile = unit('a1', { ability: ABILITIES.AGILE, baseStrength: 6, row: ROWS.RANGED })

    const p0 = emptyPlayer(FACTIONS.C, {
      board: {
        melee: emptyRow(ROWS.MELEE),
        ranged: { type: ROWS.RANGED, cards: [agile], warCry: false },
        siege: emptyRow(ROWS.SIEGE),
      },
    })
    // No weather: both rows show base (6)
    const state = gameState(p0, emptyPlayer(FACTIONS.B))

    const next = leaderC2(state, 0)

    expect(next.players[0].board.melee.cards.find((c) => c.id === 'a1')).toBeDefined()
    expect(next.players[0].board.ranged.cards.find((c) => c.id === 'a1')).toBeUndefined()
  })
})

// ---- Leader D1 — no stack with War Cry ----

describe('Leader D1 — no stack with existing War Cry', () => {
  it('Infiltrator on a War Cry row is doubled once (not twice) when Leader D1 is active', () => {
    const inf = unit('inf1', { ability: ABILITIES.INFILTRATOR, baseStrength: 5 })
    const row: RowState = { type: ROWS.MELEE, cards: [inf], warCry: true }
    const state = gameState(emptyPlayer(FACTIONS.D), emptyPlayer(FACTIONS.A), {
      leaderD1Active: true,
    })

    // warCry doubles (×2); leaderD1 does NOT additionally double
    expect(computeStrength('inf1', row, state)).toBe(10)
  })

  it('Infiltrator on a non-War Cry row is doubled by Leader D1', () => {
    const inf = unit('inf1', { ability: ABILITIES.INFILTRATOR, baseStrength: 5 })
    const row: RowState = { type: ROWS.MELEE, cards: [inf], warCry: false }
    const state = gameState(emptyPlayer(FACTIONS.D), emptyPlayer(FACTIONS.A), {
      leaderD1Active: true,
    })

    expect(computeStrength('inf1', row, state)).toBe(10)
  })

  it('Leader D1 does not double non-Infiltrator units', () => {
    const plain = unit('u1', { baseStrength: 5 })
    const row: RowState = { type: ROWS.MELEE, cards: [plain], warCry: false }
    const state = gameState(emptyPlayer(FACTIONS.D), emptyPlayer(FACTIONS.A), {
      leaderD1Active: true,
    })

    expect(computeStrength('u1', row, state)).toBe(5)
  })

  it('leaderD1 function sets leaderD1Active flag and marks leader used', () => {
    const p0 = emptyPlayer(FACTIONS.D)
    const state = gameState(p0, emptyPlayer(FACTIONS.A))

    const next = leaderD1(state, 0)

    expect(next.leaderD1Active).toBe(true)
    expect(next.players[0].leaderAbilityUsed).toBe(true)
  })
})

// ---- Round 3 draw ----

describe('Round 3 draw', () => {
  it('Faction B wins a round 3 draw — only the opponent loses a gem', () => {
    const p0 = emptyPlayer(FACTIONS.B)
    const p1 = emptyPlayer(FACTIONS.C)
    const state = gameState(p0, p1, { round: 3 })

    const next = resolveRoundGems(state, 15, 15)

    expect(next.players[0].gems).toBe(2) // Faction B keeps gem
    expect(next.players[1].gems).toBe(1) // Opponent loses gem
  })

  it('round 3 draw without Faction B — both players lose their final gem', () => {
    const p0 = emptyPlayer(FACTIONS.A, { gems: 1 })
    const p1 = emptyPlayer(FACTIONS.C, { gems: 1 })
    const state = gameState(p0, p1, { round: 3 })

    const next = resolveRoundGems(state, 10, 10)

    expect(next.players[0].gems).toBe(0)
    expect(next.players[1].gems).toBe(0)
  })
})
