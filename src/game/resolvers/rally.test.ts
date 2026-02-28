import { describe, expect, it } from 'vitest'
import { ABILITIES, ROWS } from '@/lib/terminology'
import type { GameState, PlayerState, RowType, UnitCard } from '@/types/game'
import { resolveRally } from './rally'

function unit(id: string, row: RowType = ROWS.MELEE, opts: Partial<UnitCard> = {}): UnitCard {
  return {
    id,
    type: 'unit',
    name: `Card_${id}`,
    faction: 'Faction C',
    row,
    baseStrength: 5,
    ability: ABILITIES.RALLY,
    isHero: false,
    rallyGroup: 'R1',
    ...opts,
  }
}

function emptyPlayer(overrides: Partial<PlayerState> = {}): PlayerState {
  const emptyRow = (type: RowType) => ({ type, cards: [], warCry: false })
  return {
    faction: 'Faction C',
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

describe('resolveRally', () => {
  it('returns state unchanged if cardId is not in hand or on board', () => {
    const state = gameState(emptyPlayer(), emptyPlayer())
    expect(resolveRally(state, 'missing', 0)).toBe(state)
  })

  it('removes the rally card from hand and places it on the board', () => {
    const card = unit('r1')
    const state = gameState(emptyPlayer({ hand: [card] }), emptyPlayer())

    const next = resolveRally(state, 'r1', 0)

    expect(next.players[0].hand).toHaveLength(0)
    expect(next.players[0].board.melee.cards).toHaveLength(1)
    expect(next.players[0].board.melee.cards[0].id).toBe('r1')
  })

  it('pulls all matching rally group cards from deck to board', () => {
    const r1 = unit('r1')
    const r2 = unit('r2')
    const r3 = unit('r3')
    const state = gameState(emptyPlayer({ hand: [r1], deck: [r2, r3] }), emptyPlayer())

    const next = resolveRally(state, 'r1', 0)

    expect(next.players[0].board.melee.cards).toHaveLength(3)
    expect(next.players[0].deck).toHaveLength(0)
  })

  it('does not pull cards from hand with the same rally group', () => {
    const r1 = unit('r1')
    const r2 = unit('r2')
    const r3 = unit('r3')
    const state = gameState(emptyPlayer({ hand: [r1, r2], deck: [r3] }), emptyPlayer())

    const next = resolveRally(state, 'r1', 0)

    // r2 stays in hand; only r3 pulled from deck
    expect(next.players[0].hand).toHaveLength(1)
    expect(next.players[0].hand[0].id).toBe('r2')
    expect(next.players[0].board.melee.cards).toHaveLength(2)
  })

  it('places rallied cards in their correct rows', () => {
    const r1 = unit('r1', ROWS.MELEE)
    const r2 = unit('r2', ROWS.RANGED)
    const r3 = unit('r3', ROWS.SIEGE)
    const state = gameState(emptyPlayer({ hand: [r1], deck: [r2, r3] }), emptyPlayer())

    const next = resolveRally(state, 'r1', 0)

    expect(next.players[0].board.melee.cards.map((c) => c.id)).toContain('r1')
    expect(next.players[0].board.ranged.cards.map((c) => c.id)).toContain('r2')
    expect(next.players[0].board.siege.cards.map((c) => c.id)).toContain('r3')
  })

  it('only pulls cards with a matching rally group, not others', () => {
    const r1 = unit('r1', ROWS.MELEE, { rallyGroup: 'R1' })
    const r2 = unit('r2', ROWS.MELEE, { rallyGroup: 'R1' })
    const other = unit('o1', ROWS.MELEE, { rallyGroup: 'R2' })
    const plain = unit('p1', ROWS.MELEE, { ability: null, rallyGroup: null })
    const state = gameState(emptyPlayer({ hand: [r1], deck: [r2, other, plain] }), emptyPlayer())

    const next = resolveRally(state, 'r1', 0)

    expect(next.players[0].board.melee.cards).toHaveLength(2)
    expect(next.players[0].deck).toHaveLength(2)
  })

  it('rally card with no rallyGroup: places on board, nothing pulled from deck', () => {
    const r1 = unit('r1', ROWS.MELEE, { rallyGroup: null })
    const deckCard = unit('d1', ROWS.MELEE, { rallyGroup: null })
    const state = gameState(emptyPlayer({ hand: [r1], deck: [deckCard] }), emptyPlayer())

    const next = resolveRally(state, 'r1', 0)

    expect(next.players[0].board.melee.cards).toHaveLength(1)
    expect(next.players[0].deck).toHaveLength(1)
  })

  it('when deck has no matching rally cards, only the played card is placed', () => {
    const r1 = unit('r1')
    const state = gameState(emptyPlayer({ hand: [r1] }), emptyPlayer())

    const next = resolveRally(state, 'r1', 0)

    expect(next.players[0].board.melee.cards).toHaveLength(1)
    expect(next.players[0].deck).toHaveLength(0)
  })

  it('medic revive: card already on board still pulls rally mates from deck', () => {
    const r1 = unit('r1')
    const r2 = unit('r2')
    // Simulate state after Medic placed r1 on board
    const p0 = emptyPlayer({
      deck: [r2],
      board: {
        melee: { type: ROWS.MELEE, cards: [r1], warCry: false },
        ranged: { type: ROWS.RANGED, cards: [], warCry: false },
        siege: { type: ROWS.SIEGE, cards: [], warCry: false },
      },
    })
    const state = gameState(p0, emptyPlayer())

    const next = resolveRally(state, 'r1', 0)

    expect(next.players[0].board.melee.cards).toHaveLength(2)
    expect(next.players[0].deck).toHaveLength(0)
  })

  it('works correctly when playerIndex is 1', () => {
    const r1 = unit('r1')
    const r2 = unit('r2')
    const state = gameState(emptyPlayer(), emptyPlayer({ hand: [r1], deck: [r2] }))

    const next = resolveRally(state, 'r1', 1)

    expect(next.players[1].hand).toHaveLength(0)
    expect(next.players[1].board.melee.cards).toHaveLength(2)
    expect(next.players[0]).toBe(state.players[0])
  })
})
