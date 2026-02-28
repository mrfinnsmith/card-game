import { describe, expect, it } from 'vitest'
import { FACTIONS, ROWS } from '@/lib/terminology'
import type {
  GameState,
  PlayerFaction,
  PlayerState,
  RowState,
  RowType,
  UnitCard,
} from '@/types/game'
import { getAvailableMoves } from './adapter'

function unit(id: string): UnitCard {
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
  }
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

function baseState(overrides: Partial<GameState> = {}): GameState {
  return {
    players: [emptyPlayer(FACTIONS.A), emptyPlayer(FACTIONS.B)],
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

describe('getAvailableMoves', () => {
  it('returns only pass when hand is empty', () => {
    const state = baseState()
    const moves = getAvailableMoves(state, 0)
    expect(moves).toEqual([{ type: 'pass' }])
  })

  it('returns one playCard move plus pass when hand has 1 card', () => {
    const card = unit('c1')
    const state = baseState({
      players: [emptyPlayer(FACTIONS.A, { hand: [card] }), emptyPlayer(FACTIONS.B)],
    })
    const moves = getAvailableMoves(state, 0)
    expect(moves).toHaveLength(2)
    expect(moves).toContainEqual({ type: 'playCard', cardId: 'c1' })
    expect(moves).toContainEqual({ type: 'pass' })
  })

  it('returns N playCard moves plus pass when hand has N cards', () => {
    const cards = ['c1', 'c2', 'c3', 'c4'].map(unit)
    const state = baseState({
      players: [emptyPlayer(FACTIONS.A, { hand: cards }), emptyPlayer(FACTIONS.B)],
    })
    const moves = getAvailableMoves(state, 0)
    expect(moves).toHaveLength(5)
    for (const card of cards) {
      expect(moves).toContainEqual({ type: 'playCard', cardId: card.id })
    }
    expect(moves).toContainEqual({ type: 'pass' })
  })
})
