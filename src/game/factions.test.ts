import { describe, expect, it } from 'vitest'
import { FACTIONS, ROWS } from '@/lib/terminology'
import type { GameState, PlayerFaction, PlayerState, UnitCard } from '@/types/game'
import {
  applyFactionADraw,
  applyFactionCFirstTurn,
  applyFactionDRetain,
  resolveRoundGems,
} from './factions'

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

function gameState(p0: PlayerState, p1: PlayerState): GameState {
  return {
    players: [p0, p1],
    weatherZone: [],
    round: 1,
    activePlayer: 0,
    selectionMode: 'default',
  }
}

describe('applyFactionADraw', () => {
  it('draws 1 card from deck when player 0 is Faction A', () => {
    const d1 = unit('d1')
    const d2 = unit('d2')
    const p0 = emptyPlayer(FACTIONS.A, { deck: [d1, d2] })
    const state = gameState(p0, emptyPlayer(FACTIONS.B))

    const next = applyFactionADraw(state, 0)

    expect(next.players[0].hand).toHaveLength(1)
    expect(next.players[0].hand[0].id).toBe('d1')
    expect(next.players[0].deck).toHaveLength(1)
    expect(next.players[0].deck[0].id).toBe('d2')
  })

  it('draws 1 card from deck when player 1 is Faction A', () => {
    const d1 = unit('d1')
    const p1 = emptyPlayer(FACTIONS.A, { deck: [d1] })
    const state = gameState(emptyPlayer(FACTIONS.B), p1)

    const next = applyFactionADraw(state, 1)

    expect(next.players[1].hand).toHaveLength(1)
    expect(next.players[1].deck).toHaveLength(0)
  })

  it('returns state unchanged if deck is empty', () => {
    const p0 = emptyPlayer(FACTIONS.A, { deck: [] })
    const state = gameState(p0, emptyPlayer(FACTIONS.B))

    const next = applyFactionADraw(state, 0)

    expect(next).toBe(state)
  })

  it('returns state unchanged if player is not Faction A', () => {
    const d1 = unit('d1')
    const p0 = emptyPlayer(FACTIONS.C, { deck: [d1] })
    const state = gameState(p0, emptyPlayer(FACTIONS.B))

    const next = applyFactionADraw(state, 0)

    expect(next).toBe(state)
  })

  it('does not affect the opponent', () => {
    const d1 = unit('d1')
    const p0 = emptyPlayer(FACTIONS.A, { deck: [d1] })
    const p1 = emptyPlayer(FACTIONS.B, { hand: [unit('h1')], deck: [unit('d2')] })
    const state = gameState(p0, p1)

    const next = applyFactionADraw(state, 0)

    expect(next.players[1].hand).toHaveLength(1)
    expect(next.players[1].deck).toHaveLength(1)
  })
})

describe('resolveRoundGems', () => {
  it('player 0 wins — player 1 loses 1 gem', () => {
    const state = gameState(emptyPlayer(FACTIONS.A), emptyPlayer(FACTIONS.C))
    const next = resolveRoundGems(state, 20, 10)
    expect(next.players[0].gems).toBe(2)
    expect(next.players[1].gems).toBe(1)
  })

  it('player 1 wins — player 0 loses 1 gem', () => {
    const state = gameState(emptyPlayer(FACTIONS.A), emptyPlayer(FACTIONS.C))
    const next = resolveRoundGems(state, 10, 20)
    expect(next.players[0].gems).toBe(1)
    expect(next.players[1].gems).toBe(2)
  })

  it('draw with no Faction B — both lose 1 gem', () => {
    const state = gameState(emptyPlayer(FACTIONS.A), emptyPlayer(FACTIONS.C))
    const next = resolveRoundGems(state, 15, 15)
    expect(next.players[0].gems).toBe(1)
    expect(next.players[1].gems).toBe(1)
  })

  it('draw with player 0 as Faction B — only player 1 loses gem', () => {
    const state = gameState(emptyPlayer(FACTIONS.B), emptyPlayer(FACTIONS.C))
    const next = resolveRoundGems(state, 15, 15)
    expect(next.players[0].gems).toBe(2)
    expect(next.players[1].gems).toBe(1)
  })

  it('draw with player 1 as Faction B — only player 0 loses gem', () => {
    const state = gameState(emptyPlayer(FACTIONS.A), emptyPlayer(FACTIONS.B))
    const next = resolveRoundGems(state, 15, 15)
    expect(next.players[0].gems).toBe(1)
    expect(next.players[1].gems).toBe(2)
  })

  it('Faction B draw applies in round 3', () => {
    const base = gameState(emptyPlayer(FACTIONS.B), emptyPlayer(FACTIONS.C))
    const state = { ...base, round: 3 }
    const next = resolveRoundGems(state, 10, 10)
    expect(next.players[0].gems).toBe(2)
    expect(next.players[1].gems).toBe(1)
  })

  it('non-draw win is not affected by Faction B', () => {
    const state = gameState(emptyPlayer(FACTIONS.B), emptyPlayer(FACTIONS.A))
    const next = resolveRoundGems(state, 5, 20)
    expect(next.players[0].gems).toBe(1)
    expect(next.players[1].gems).toBe(2)
  })
})

describe('applyFactionCFirstTurn', () => {
  it('sets activePlayer to chosen first player when Faction C is present', () => {
    const state = gameState(emptyPlayer(FACTIONS.C), emptyPlayer(FACTIONS.A))
    const next = applyFactionCFirstTurn(state, 1)
    expect(next.activePlayer).toBe(1)
  })

  it('Faction C player can choose themselves to go first', () => {
    const state = gameState(emptyPlayer(FACTIONS.B), emptyPlayer(FACTIONS.C))
    const next = applyFactionCFirstTurn(state, 1)
    expect(next.activePlayer).toBe(1)
  })

  it('returns state unchanged if neither player is Faction C', () => {
    const state = gameState(emptyPlayer(FACTIONS.A), emptyPlayer(FACTIONS.B))
    const next = applyFactionCFirstTurn(state, 1)
    expect(next).toBe(state)
  })
})

describe('applyFactionDRetain', () => {
  it('moves one random unit from discard to board', () => {
    const u = unit('u1', { row: ROWS.MELEE })
    const p0 = emptyPlayer(FACTIONS.D, { discard: [u] })
    const state = gameState(p0, emptyPlayer(FACTIONS.A))

    const next = applyFactionDRetain(state, 0, () => 0)

    expect(next.players[0].board.melee.cards).toHaveLength(1)
    expect(next.players[0].board.melee.cards[0].id).toBe('u1')
    expect(next.players[0].discard).toHaveLength(0)
  })

  it('places the retained unit in the correct row', () => {
    const u = unit('u1', { row: ROWS.SIEGE })
    const p0 = emptyPlayer(FACTIONS.D, { discard: [u] })
    const state = gameState(p0, emptyPlayer(FACTIONS.A))

    const next = applyFactionDRetain(state, 0, () => 0)

    expect(next.players[0].board.siege.cards).toHaveLength(1)
    expect(next.players[0].board.melee.cards).toHaveLength(0)
  })

  it('uses rng to select among multiple units', () => {
    const u1 = unit('u1', { row: ROWS.MELEE })
    const u2 = unit('u2', { row: ROWS.RANGED })
    const u3 = unit('u3', { row: ROWS.SIEGE })
    const p0 = emptyPlayer(FACTIONS.D, { discard: [u1, u2, u3] })
    const state = gameState(p0, emptyPlayer(FACTIONS.A))

    // rng returning 0.99 → Math.floor(0.99 * 3) = 2 → u3
    const next = applyFactionDRetain(state, 0, () => 0.99)

    expect(next.players[0].board.siege.cards[0].id).toBe('u3')
    expect(next.players[0].discard).toHaveLength(2)
  })

  it('ignores special and weather cards in discard when selecting', () => {
    const special = {
      id: 's1',
      type: 'special' as const,
      name: 'Scorch',
      ability: 'Scorch' as const,
    }
    const u = unit('u1', { row: ROWS.MELEE })
    const p0 = emptyPlayer(FACTIONS.D, { discard: [special, u] })
    const state = gameState(p0, emptyPlayer(FACTIONS.A))

    const next = applyFactionDRetain(state, 0, () => 0)

    expect(next.players[0].board.melee.cards[0].id).toBe('u1')
    // special card remains in discard
    expect(next.players[0].discard.some((c) => c.id === 's1')).toBe(true)
  })

  it('returns state unchanged if discard has no units', () => {
    const p0 = emptyPlayer(FACTIONS.D, { discard: [] })
    const state = gameState(p0, emptyPlayer(FACTIONS.A))

    const next = applyFactionDRetain(state, 0, () => 0)

    expect(next).toBe(state)
  })

  it('returns state unchanged if player is not Faction D', () => {
    const u = unit('u1')
    const p0 = emptyPlayer(FACTIONS.A, { discard: [u] })
    const state = gameState(p0, emptyPlayer(FACTIONS.B))

    const next = applyFactionDRetain(state, 0, () => 0)

    expect(next).toBe(state)
  })

  it('works correctly when player index is 1', () => {
    const u = unit('u1', { row: ROWS.RANGED })
    const p1 = emptyPlayer(FACTIONS.D, { discard: [u] })
    const state = gameState(emptyPlayer(FACTIONS.A), p1)

    const next = applyFactionDRetain(state, 1, () => 0)

    expect(next.players[1].board.ranged.cards).toHaveLength(1)
    expect(next.players[0]).toBe(state.players[0])
  })

  it('does not affect the opponent', () => {
    const u = unit('u1')
    const p0 = emptyPlayer(FACTIONS.D, { discard: [u] })
    const p1 = emptyPlayer(FACTIONS.A, { discard: [unit('opp1')] })
    const state = gameState(p0, p1)

    const next = applyFactionDRetain(state, 0, () => 0)

    expect(next.players[1].discard).toHaveLength(1)
    expect(next.players[1].board.melee.cards).toHaveLength(0)
  })
})
