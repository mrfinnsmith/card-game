import { describe, expect, it } from 'vitest'
import { ABILITIES, ROWS } from '@/lib/terminology'
import type { GameState, PlayerState, RowState, RowType, UnitCard } from '@/types/game'
import { computeStrength } from '../computeStrength'
import { resolveFormation } from './formation'

function unit(id: string, name: string, row: RowType = ROWS.MELEE, baseStrength = 8): UnitCard {
  return {
    id,
    type: 'unit',
    name,
    faction: 'Faction A',
    row,
    baseStrength,
    ability: ABILITIES.FORMATION,
    isHero: false,
    rallyGroup: null,
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

describe('resolveFormation', () => {
  it('returns state unchanged if cardId is not in hand', () => {
    const state = gameState(emptyPlayer(), emptyPlayer())
    expect(resolveFormation(state, 'missing', 0)).toBe(state)
  })

  it('removes the card from hand and places it on the board', () => {
    const card = unit('f1', 'Alpha')
    const state = gameState(emptyPlayer({ hand: [card] }), emptyPlayer())

    const next = resolveFormation(state, 'f1', 0)

    expect(next.players[0].hand).toHaveLength(0)
    expect(next.players[0].board.melee.cards).toHaveLength(1)
    expect(next.players[0].board.melee.cards[0].id).toBe('f1')
  })

  it('single Formation card shows base strength', () => {
    const card = unit('f1', 'Alpha')
    const state = gameState(emptyPlayer({ hand: [card] }), emptyPlayer())

    const next = resolveFormation(state, 'f1', 0)
    const row = next.players[0].board.melee

    expect(computeStrength('f1', row, next)).toBe(8)
  })

  it('pair of Formation cards each shows base × 2', () => {
    const f1 = unit('f1', 'Alpha')
    const f2 = unit('f2', 'Alpha')
    const p0 = emptyPlayer({
      hand: [f2],
      board: {
        melee: { type: ROWS.MELEE, cards: [f1], warCry: false },
        ranged: emptyRow(ROWS.RANGED),
        siege: emptyRow(ROWS.SIEGE),
      },
    })
    const state = gameState(p0, emptyPlayer())

    const next = resolveFormation(state, 'f2', 0)
    const row = next.players[0].board.melee

    expect(computeStrength('f1', row, next)).toBe(16)
    expect(computeStrength('f2', row, next)).toBe(16)
  })

  it('three Formation cards each shows base × 3', () => {
    const f1 = unit('f1', 'Alpha')
    const f2 = unit('f2', 'Alpha')
    const f3 = unit('f3', 'Alpha')
    const p0 = emptyPlayer({
      hand: [f3],
      board: {
        melee: { type: ROWS.MELEE, cards: [f1, f2], warCry: false },
        ranged: emptyRow(ROWS.RANGED),
        siege: emptyRow(ROWS.SIEGE),
      },
    })
    const state = gameState(p0, emptyPlayer())

    const next = resolveFormation(state, 'f3', 0)
    const row = next.players[0].board.melee

    expect(computeStrength('f1', row, next)).toBe(24)
    expect(computeStrength('f2', row, next)).toBe(24)
    expect(computeStrength('f3', row, next)).toBe(24)
  })

  it('removing a Formation card recalculates the remaining pair', () => {
    const f1 = unit('f1', 'Alpha')
    const f2 = unit('f2', 'Alpha')
    const f3 = unit('f3', 'Alpha')
    const rowWithThree: RowState = { type: ROWS.MELEE, cards: [f1, f2, f3], warCry: false }
    const rowWithTwo: RowState = { type: ROWS.MELEE, cards: [f1, f2], warCry: false }

    const stateAfter = gameState(
      emptyPlayer({
        board: {
          melee: rowWithTwo,
          ranged: emptyRow(ROWS.RANGED),
          siege: emptyRow(ROWS.SIEGE),
        },
      }),
      emptyPlayer(),
    )

    // Before removal: all three at base × 3
    const stateBefore = gameState(
      emptyPlayer({
        board: {
          melee: rowWithThree,
          ranged: emptyRow(ROWS.RANGED),
          siege: emptyRow(ROWS.SIEGE),
        },
      }),
      emptyPlayer(),
    )
    expect(computeStrength('f1', rowWithThree, stateBefore)).toBe(24)

    // After removal: remaining two at base × 2
    expect(computeStrength('f1', rowWithTwo, stateAfter)).toBe(16)
    expect(computeStrength('f2', rowWithTwo, stateAfter)).toBe(16)
  })

  it('formation is row-scoped: same-named cards in different rows do not count', () => {
    const f1 = unit('f1', 'Alpha', ROWS.RANGED)
    const f2 = unit('f2', 'Alpha', ROWS.MELEE)
    const p0 = emptyPlayer({
      hand: [f2],
      board: {
        melee: emptyRow(ROWS.MELEE),
        ranged: { type: ROWS.RANGED, cards: [f1], warCry: false },
        siege: emptyRow(ROWS.SIEGE),
      },
    })
    const state = gameState(p0, emptyPlayer())

    const next = resolveFormation(state, 'f2', 0)

    expect(computeStrength('f1', next.players[0].board.ranged, next)).toBe(8)
    expect(computeStrength('f2', next.players[0].board.melee, next)).toBe(8)
  })

  it('name-matching is exact and case-sensitive', () => {
    const f1 = unit('f1', 'Alpha')
    const f2 = unit('f2', 'alpha')
    const p0 = emptyPlayer({
      hand: [f2],
      board: {
        melee: { type: ROWS.MELEE, cards: [f1], warCry: false },
        ranged: emptyRow(ROWS.RANGED),
        siege: emptyRow(ROWS.SIEGE),
      },
    })
    const state = gameState(p0, emptyPlayer())

    const next = resolveFormation(state, 'f2', 0)
    const row = next.players[0].board.melee

    expect(computeStrength('f1', row, next)).toBe(8)
    expect(computeStrength('f2', row, next)).toBe(8)
  })

  it('works correctly when playerIndex is 1', () => {
    const card = unit('f1', 'Alpha')
    const state = gameState(emptyPlayer(), emptyPlayer({ hand: [card] }))

    const next = resolveFormation(state, 'f1', 1)

    expect(next.players[1].hand).toHaveLength(0)
    expect(next.players[1].board.melee.cards[0].id).toBe('f1')
    expect(next.players[0]).toBe(state.players[0])
  })
})
