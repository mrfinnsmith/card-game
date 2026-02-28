import { describe, expect, it } from 'vitest'
import { ABILITIES, ROWS } from '@/lib/terminology'
import type { GameState, PlayerState, RowState, RowType, SpecialCard, UnitCard } from '@/types/game'
import { completeWarCrySelection, resolveWarCrySpecial, resolveWarCryUnit } from './warCry'

function warCrySpecialCard(id: string): SpecialCard {
  return { id, type: 'special', name: `WarCry_${id}`, ability: ABILITIES.WAR_CRY }
}

function warCryUnit(id: string, opts: Partial<UnitCard> = {}): UnitCard {
  return {
    id,
    type: 'unit',
    name: `WCU_${id}`,
    faction: 'Faction A',
    row: ROWS.MELEE,
    baseStrength: 5,
    ability: ABILITIES.WAR_CRY,
    isHero: false,
    rallyGroup: null,
    ...opts,
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
    mulligansUsed: [0, 0],
    mulliganedCardIds: [[], []],
    mulligansConfirmed: [false, false],
    roundWins: [0, 0],
    ...opts,
  }
}

describe('resolveWarCrySpecial', () => {
  it('returns state unchanged if cardId is not in hand', () => {
    const state = gameState(emptyPlayer(), emptyPlayer())
    expect(resolveWarCrySpecial(state, 'missing', 0)).toBe(state)
  })

  it('removes the card from hand', () => {
    const card = warCrySpecialCard('wc1')
    const state = gameState(emptyPlayer({ hand: [card] }), emptyPlayer())
    const next = resolveWarCrySpecial(state, 'wc1', 0)
    expect(next.players[0].hand.find((c) => c.id === 'wc1')).toBeUndefined()
  })

  it('adds the card to player discard', () => {
    const card = warCrySpecialCard('wc1')
    const state = gameState(emptyPlayer({ hand: [card] }), emptyPlayer())
    const next = resolveWarCrySpecial(state, 'wc1', 0)
    expect(next.players[0].discard.find((c) => c.id === 'wc1')).toBeDefined()
  })

  it('sets selectionMode to warCry', () => {
    const card = warCrySpecialCard('wc1')
    const state = gameState(emptyPlayer({ hand: [card] }), emptyPlayer())
    const next = resolveWarCrySpecial(state, 'wc1', 0)
    expect(next.selectionMode).toBe('warCry')
  })

  it('does not modify the opponent', () => {
    const card = warCrySpecialCard('wc1')
    const state = gameState(emptyPlayer({ hand: [card] }), emptyPlayer())
    const next = resolveWarCrySpecial(state, 'wc1', 0)
    expect(next.players[1]).toBe(state.players[1])
  })

  it('works correctly when playerIndex is 1', () => {
    const card = warCrySpecialCard('wc1')
    const state = gameState(emptyPlayer(), emptyPlayer({ hand: [card] }))
    const next = resolveWarCrySpecial(state, 'wc1', 1)
    expect(next.players[1].hand.find((c) => c.id === 'wc1')).toBeUndefined()
    expect(next.players[1].discard.find((c) => c.id === 'wc1')).toBeDefined()
    expect(next.selectionMode).toBe('warCry')
    expect(next.players[0]).toBe(state.players[0])
  })
})

describe('completeWarCrySelection', () => {
  it('sets warCry on the chosen row', () => {
    const state = gameState(emptyPlayer(), emptyPlayer(), { selectionMode: 'warCry' })
    const next = completeWarCrySelection(state, ROWS.MELEE, 0)
    expect(next.players[0].board.melee.warCry).toBe(true)
  })

  it('sets warCry on Ranged row', () => {
    const state = gameState(emptyPlayer(), emptyPlayer(), { selectionMode: 'warCry' })
    const next = completeWarCrySelection(state, ROWS.RANGED, 0)
    expect(next.players[0].board.ranged.warCry).toBe(true)
    expect(next.players[0].board.melee.warCry).toBe(false)
  })

  it('second War Cry on same row has no effect on the row state', () => {
    const state = gameState(
      emptyPlayer({
        board: {
          melee: { type: ROWS.MELEE, cards: [], warCry: true },
          ranged: emptyRow(ROWS.RANGED),
          siege: emptyRow(ROWS.SIEGE),
        },
      }),
      emptyPlayer(),
      { selectionMode: 'warCry' },
    )
    const next = completeWarCrySelection(state, ROWS.MELEE, 0)
    expect(next.players[0].board.melee.warCry).toBe(true)
    expect(next.selectionMode).toBe('default')
  })

  it('resets selectionMode to default', () => {
    const state = gameState(emptyPlayer(), emptyPlayer(), { selectionMode: 'warCry' })
    const next = completeWarCrySelection(state, ROWS.MELEE, 0)
    expect(next.selectionMode).toBe('default')
  })

  it('does not modify the opponent', () => {
    const state = gameState(emptyPlayer(), emptyPlayer(), { selectionMode: 'warCry' })
    const next = completeWarCrySelection(state, ROWS.MELEE, 0)
    expect(next.players[1]).toBe(state.players[1])
  })

  it('works correctly when playerIndex is 1', () => {
    const state = gameState(emptyPlayer(), emptyPlayer(), { selectionMode: 'warCry' })
    const next = completeWarCrySelection(state, ROWS.SIEGE, 1)
    expect(next.players[1].board.siege.warCry).toBe(true)
    expect(next.players[0]).toBe(state.players[0])
    expect(next.selectionMode).toBe('default')
  })
})

describe('resolveWarCryUnit', () => {
  it('returns state unchanged if cardId is not in hand', () => {
    const state = gameState(emptyPlayer(), emptyPlayer())
    expect(resolveWarCryUnit(state, 'missing', 0)).toBe(state)
  })

  it('removes the card from hand', () => {
    const card = warCryUnit('wu1')
    const state = gameState(emptyPlayer({ hand: [card] }), emptyPlayer())
    const next = resolveWarCryUnit(state, 'wu1', 0)
    expect(next.players[0].hand.find((c) => c.id === 'wu1')).toBeUndefined()
  })

  it('places the card on its designated row', () => {
    const card = warCryUnit('wu1', { row: ROWS.RANGED })
    const state = gameState(emptyPlayer({ hand: [card] }), emptyPlayer())
    const next = resolveWarCryUnit(state, 'wu1', 0)
    expect(next.players[0].board.ranged.cards.find((c) => c.id === 'wu1')).toBeDefined()
    expect(next.players[0].board.melee.cards).toHaveLength(0)
  })

  it('sets warCry on the row the unit is placed on', () => {
    const card = warCryUnit('wu1', { row: ROWS.MELEE })
    const state = gameState(emptyPlayer({ hand: [card] }), emptyPlayer())
    const next = resolveWarCryUnit(state, 'wu1', 0)
    expect(next.players[0].board.melee.warCry).toBe(true)
  })

  it('placing a second War Cry unit leaves warCry true with no side effect', () => {
    const wu1 = warCryUnit('wu1', { row: ROWS.MELEE })
    const wu2 = warCryUnit('wu2', { row: ROWS.MELEE })
    const p0 = emptyPlayer({
      hand: [wu2],
      board: {
        melee: { type: ROWS.MELEE, cards: [wu1], warCry: true },
        ranged: emptyRow(ROWS.RANGED),
        siege: emptyRow(ROWS.SIEGE),
      },
    })
    const state = gameState(p0, emptyPlayer())
    const next = resolveWarCryUnit(state, 'wu2', 0)
    expect(next.players[0].board.melee.warCry).toBe(true)
    expect(next.players[0].board.melee.cards).toHaveLength(2)
  })

  it('does not modify the opponent', () => {
    const card = warCryUnit('wu1')
    const state = gameState(emptyPlayer({ hand: [card] }), emptyPlayer())
    const next = resolveWarCryUnit(state, 'wu1', 0)
    expect(next.players[1]).toBe(state.players[1])
  })

  it('works correctly when playerIndex is 1', () => {
    const card = warCryUnit('wu1', { row: ROWS.SIEGE })
    const state = gameState(emptyPlayer(), emptyPlayer({ hand: [card] }))
    const next = resolveWarCryUnit(state, 'wu1', 1)
    expect(next.players[1].board.siege.cards.find((c) => c.id === 'wu1')).toBeDefined()
    expect(next.players[1].board.siege.warCry).toBe(true)
    expect(next.players[0]).toBe(state.players[0])
  })
})
