import { describe, expect, it } from 'vitest'
import { FACTIONS, LEADERS, ROWS, WEATHER } from '@/lib/terminology'
import type {
  GameState,
  PlayerFaction,
  PlayerState,
  RowState,
  RowType,
  UnitCard,
  WeatherCard,
} from '@/types/game'
import { validateAndApply } from './validateMove'

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

// ---- Invalid moves ----

describe('validateAndApply — out of turn', () => {
  it('rejects playCard when it is not the player turn', () => {
    const card = unit('u1')
    const p0 = emptyPlayer(FACTIONS.A, { hand: [card] })
    const state = gameState(p0, emptyPlayer(FACTIONS.B), { activePlayer: 1 })
    const result = validateAndApply(state, 0, { action: 'playCard', cardId: 'u1' })
    expect(result.valid).toBe(false)
    if (!result.valid) expect(result.error).toBe('Not your turn')
  })

  it('rejects pass when it is not the player turn', () => {
    const state = gameState(emptyPlayer(FACTIONS.A), emptyPlayer(FACTIONS.B), { activePlayer: 1 })
    const result = validateAndApply(state, 0, { action: 'pass' })
    expect(result.valid).toBe(false)
    if (!result.valid) expect(result.error).toBe('Not your turn')
  })

  it('rejects leaderAbility when it is not the player turn', () => {
    const p0 = emptyPlayer(FACTIONS.A, { leader: LEADERS.A2 })
    const state = gameState(p0, emptyPlayer(FACTIONS.B), { activePlayer: 1 })
    const result = validateAndApply(state, 0, { action: 'leaderAbility' })
    expect(result.valid).toBe(false)
    if (!result.valid) expect(result.error).toBe('Not your turn')
  })

  it('rejects selection completions when it is not the player turn', () => {
    const state = gameState(emptyPlayer(FACTIONS.A), emptyPlayer(FACTIONS.B), {
      activePlayer: 1,
      selectionMode: 'medic',
    })
    const result = validateAndApply(state, 0, { action: 'medic', cardId: 'u1' })
    expect(result.valid).toBe(false)
    if (!result.valid) expect(result.error).toBe('Not your turn')
  })
})

describe('validateAndApply — playing after passing', () => {
  it('rejects playCard after the player has passed', () => {
    const card = unit('u1')
    const p0 = emptyPlayer(FACTIONS.A, { hand: [card], passed: true })
    const state = gameState(p0, emptyPlayer(FACTIONS.B))
    const result = validateAndApply(state, 0, { action: 'playCard', cardId: 'u1' })
    expect(result.valid).toBe(false)
    if (!result.valid) expect(result.error).toBe('You have already passed')
  })

  it('rejects pass after the player has already passed', () => {
    const p0 = emptyPlayer(FACTIONS.A, { passed: true })
    const state = gameState(p0, emptyPlayer(FACTIONS.B))
    const result = validateAndApply(state, 0, { action: 'pass' })
    expect(result.valid).toBe(false)
    if (!result.valid) expect(result.error).toBe('You have already passed')
  })
})

describe('validateAndApply — card not in hand', () => {
  it('rejects playCard when the card is not in the player hand', () => {
    const state = gameState(emptyPlayer(FACTIONS.A), emptyPlayer(FACTIONS.B))
    const result = validateAndApply(state, 0, { action: 'playCard', cardId: 'ghost' })
    expect(result.valid).toBe(false)
    if (!result.valid) expect(result.error).toBe('Card not in hand')
  })

  it('rejects playCard with a card that belongs to the opponent hand', () => {
    const opponentCard = unit('u1')
    const p1 = emptyPlayer(FACTIONS.B, { hand: [opponentCard] })
    const state = gameState(emptyPlayer(FACTIONS.A), p1)
    const result = validateAndApply(state, 0, { action: 'playCard', cardId: 'u1' })
    expect(result.valid).toBe(false)
    if (!result.valid) expect(result.error).toBe('Card not in hand')
  })
})

describe('validateAndApply — illegal selectionMode transitions', () => {
  it('rejects playCard when in medic selection mode', () => {
    const card = unit('u1')
    const p0 = emptyPlayer(FACTIONS.A, { hand: [card] })
    const state = gameState(p0, emptyPlayer(FACTIONS.B), { selectionMode: 'medic' })
    const result = validateAndApply(state, 0, { action: 'playCard', cardId: 'u1' })
    expect(result.valid).toBe(false)
    if (!result.valid) expect(result.error).toContain('medic')
  })

  it('rejects pass when in warCry selection mode', () => {
    const state = gameState(emptyPlayer(FACTIONS.A), emptyPlayer(FACTIONS.B), {
      selectionMode: 'warCry',
    })
    const result = validateAndApply(state, 0, { action: 'pass' })
    expect(result.valid).toBe(false)
    if (!result.valid) expect(result.error).toContain('warCry')
  })

  it('rejects medic when not in medic mode', () => {
    const state = gameState(emptyPlayer(FACTIONS.A), emptyPlayer(FACTIONS.B))
    const result = validateAndApply(state, 0, { action: 'medic', cardId: 'u1' })
    expect(result.valid).toBe(false)
    if (!result.valid) expect(result.error).toBe('Expected selection mode: medic')
  })

  it('rejects decoy when not in decoy mode', () => {
    const state = gameState(emptyPlayer(FACTIONS.A), emptyPlayer(FACTIONS.B))
    const result = validateAndApply(state, 0, { action: 'decoy', cardId: 'u1' })
    expect(result.valid).toBe(false)
    if (!result.valid) expect(result.error).toBe('Expected selection mode: decoy')
  })

  it('rejects agile when not in agile mode', () => {
    const state = gameState(emptyPlayer(FACTIONS.A), emptyPlayer(FACTIONS.B))
    const result = validateAndApply(state, 0, { action: 'agile', rowChoice: ROWS.MELEE })
    expect(result.valid).toBe(false)
    if (!result.valid) expect(result.error).toBe('Expected selection mode: agile')
  })

  it('rejects warCry when not in warCry mode', () => {
    const state = gameState(emptyPlayer(FACTIONS.A), emptyPlayer(FACTIONS.B))
    const result = validateAndApply(state, 0, { action: 'warCry', rowChoice: ROWS.MELEE })
    expect(result.valid).toBe(false)
    if (!result.valid) expect(result.error).toBe('Expected selection mode: warCry')
  })

  it('rejects leaderB4 when not in leaderB4 mode', () => {
    const state = gameState(emptyPlayer(FACTIONS.A), emptyPlayer(FACTIONS.B))
    const result = validateAndApply(state, 0, { action: 'leaderB4', cardId: 'u1' })
    expect(result.valid).toBe(false)
    if (!result.valid) expect(result.error).toBe('Expected selection mode: leaderB4')
  })

  it('rejects leaderD2 when not in leaderD2 mode', () => {
    const state = gameState(emptyPlayer(FACTIONS.A), emptyPlayer(FACTIONS.B))
    const result = validateAndApply(state, 0, { action: 'leaderD2', cardId: 'u1' })
    expect(result.valid).toBe(false)
    if (!result.valid) expect(result.error).toBe('Expected selection mode: leaderD2')
  })

  it('rejects leaderD4discard when not in leaderD4discard mode', () => {
    const state = gameState(emptyPlayer(FACTIONS.A), emptyPlayer(FACTIONS.B))
    const result = validateAndApply(state, 0, { action: 'leaderD4discard', cardId: 'u1' })
    expect(result.valid).toBe(false)
    if (!result.valid) expect(result.error).toBe('Expected selection mode: leaderD4discard')
  })

  it('rejects leaderD4draw when not in leaderD4draw mode', () => {
    const state = gameState(emptyPlayer(FACTIONS.A), emptyPlayer(FACTIONS.B))
    const result = validateAndApply(state, 0, { action: 'leaderD4draw', cardId: 'u1' })
    expect(result.valid).toBe(false)
    if (!result.valid) expect(result.error).toBe('Expected selection mode: leaderD4draw')
  })

  it('rejects leaderD5 when not in leaderD5 mode', () => {
    const state = gameState(emptyPlayer(FACTIONS.A), emptyPlayer(FACTIONS.B))
    const result = validateAndApply(state, 0, { action: 'leaderD5', cardId: 'u1' })
    expect(result.valid).toBe(false)
    if (!result.valid) expect(result.error).toBe('Expected selection mode: leaderD5')
  })

  it('rejects agile with an invalid row value', () => {
    const state = gameState(emptyPlayer(FACTIONS.A), emptyPlayer(FACTIONS.B), {
      selectionMode: 'agile',
    })
    const result = validateAndApply(state, 0, { action: 'agile', rowChoice: 'NotARow' })
    expect(result.valid).toBe(false)
    if (!result.valid) expect(result.error).toBe('Invalid row')
  })

  it('rejects warCry with no row provided', () => {
    const state = gameState(emptyPlayer(FACTIONS.A), emptyPlayer(FACTIONS.B), {
      selectionMode: 'warCry',
    })
    const result = validateAndApply(state, 0, { action: 'warCry' })
    expect(result.valid).toBe(false)
    if (!result.valid) expect(result.error).toBe('Invalid row')
  })

  it('blocks standard actions while in mulligan phase', () => {
    const card = unit('u1')
    const p0 = emptyPlayer(FACTIONS.A, { hand: [card] })
    const state = gameState(p0, emptyPlayer(FACTIONS.B), { selectionMode: 'mulligan' })
    const result = validateAndApply(state, 0, { action: 'playCard', cardId: 'u1' })
    expect(result.valid).toBe(false)
    if (!result.valid) expect(result.error).toBe('Game is still in mulligan phase')
  })
})

describe('validateAndApply — mulligan phase', () => {
  it('rejects mulligan when not in mulligan phase', () => {
    const card = unit('u1')
    const p0 = emptyPlayer(FACTIONS.A, { hand: [card] })
    const state = gameState(p0, emptyPlayer(FACTIONS.B))
    const result = validateAndApply(state, 0, { action: 'mulligan', cardId: 'u1' })
    expect(result.valid).toBe(false)
    if (!result.valid) expect(result.error).toBe('Not in mulligan phase')
  })

  it('rejects mulligan when the player has already confirmed', () => {
    const card = unit('u1')
    const p0 = emptyPlayer(FACTIONS.A, { hand: [card] })
    const state = gameState(p0, emptyPlayer(FACTIONS.B), {
      selectionMode: 'mulligan',
      mulligansConfirmed: [true, false],
    })
    const result = validateAndApply(state, 0, { action: 'mulligan', cardId: 'u1' })
    expect(result.valid).toBe(false)
    if (!result.valid) expect(result.error).toBe('Mulligan already confirmed')
  })

  it('rejects mulligan when two swaps have already been used', () => {
    const card = unit('u1')
    const p0 = emptyPlayer(FACTIONS.A, { hand: [card] })
    const state = gameState(p0, emptyPlayer(FACTIONS.B), {
      selectionMode: 'mulligan',
      mulligansUsed: [2, 0],
    })
    const result = validateAndApply(state, 0, { action: 'mulligan', cardId: 'u1' })
    expect(result.valid).toBe(false)
    if (!result.valid) expect(result.error).toBe('No mulligan swaps remaining')
  })

  it('rejects mulligan for a card not in the player hand', () => {
    const state = gameState(emptyPlayer(FACTIONS.A), emptyPlayer(FACTIONS.B), {
      selectionMode: 'mulligan',
    })
    const result = validateAndApply(state, 0, { action: 'mulligan', cardId: 'ghost' })
    expect(result.valid).toBe(false)
    if (!result.valid) expect(result.error).toBe('Card not in hand')
  })

  it('rejects mulligan for a card already mulliganed this turn', () => {
    const card = unit('u1')
    const p0 = emptyPlayer(FACTIONS.A, { hand: [card], deck: [unit('d1')] })
    const state = gameState(p0, emptyPlayer(FACTIONS.B), {
      selectionMode: 'mulligan',
      mulliganedCardIds: [['u1'], []],
    })
    const result = validateAndApply(state, 0, { action: 'mulligan', cardId: 'u1' })
    expect(result.valid).toBe(false)
    if (!result.valid) expect(result.error).toBe('Card already mulliganed')
  })

  it('rejects confirmMulligan when the player has already confirmed', () => {
    const state = gameState(emptyPlayer(FACTIONS.A), emptyPlayer(FACTIONS.B), {
      selectionMode: 'mulligan',
      mulligansConfirmed: [true, false],
    })
    const result = validateAndApply(state, 0, { action: 'confirmMulligan' })
    expect(result.valid).toBe(false)
    if (!result.valid) expect(result.error).toBe('Mulligan already confirmed')
  })
})

describe('validateAndApply — leader ability', () => {
  it('rejects leaderAbility when it has already been used', () => {
    const p0 = emptyPlayer(FACTIONS.A, { leader: LEADERS.A2, leaderAbilityUsed: true })
    const state = gameState(p0, emptyPlayer(FACTIONS.B))
    const result = validateAndApply(state, 0, { action: 'leaderAbility' })
    expect(result.valid).toBe(false)
    if (!result.valid) expect(result.error).toBe('Leader ability already used')
  })

  it('rejects leaderAbility when no leader is assigned', () => {
    const state = gameState(emptyPlayer(FACTIONS.A), emptyPlayer(FACTIONS.B))
    const result = validateAndApply(state, 0, { action: 'leaderAbility' })
    expect(result.valid).toBe(false)
    if (!result.valid) expect(result.error).toBe('No leader assigned')
  })
})

// ---- Valid moves ----

describe('validateAndApply — valid move types', () => {
  it('accepts mulligan swap', () => {
    const card = unit('u1')
    const p0 = emptyPlayer(FACTIONS.A, { hand: [card], deck: [unit('d1')] })
    const state = gameState(p0, emptyPlayer(FACTIONS.B), { selectionMode: 'mulligan' })
    const result = validateAndApply(state, 0, { action: 'mulligan', cardId: 'u1' })
    expect(result.valid).toBe(true)
    if (result.valid) {
      expect(result.nextState.mulligansUsed[0]).toBe(1)
    }
  })

  it('accepts confirmMulligan', () => {
    const state = gameState(emptyPlayer(FACTIONS.A), emptyPlayer(FACTIONS.B), {
      selectionMode: 'mulligan',
    })
    const result = validateAndApply(state, 0, { action: 'confirmMulligan' })
    expect(result.valid).toBe(true)
    if (result.valid) {
      expect(result.nextState.mulligansConfirmed[0]).toBe(true)
    }
  })

  it('accepts playCard', () => {
    const card = unit('u1')
    const p0 = emptyPlayer(FACTIONS.A, { hand: [card] })
    const state = gameState(p0, emptyPlayer(FACTIONS.B))
    const result = validateAndApply(state, 0, { action: 'playCard', cardId: 'u1' })
    expect(result.valid).toBe(true)
    if (result.valid) {
      expect(result.nextState.players[0].hand.find((c) => c.id === 'u1')).toBeUndefined()
    }
  })

  it('accepts pass and marks the player as passed', () => {
    const state = gameState(emptyPlayer(FACTIONS.A), emptyPlayer(FACTIONS.B))
    const result = validateAndApply(state, 0, { action: 'pass' })
    expect(result.valid).toBe(true)
    if (result.valid) {
      expect(result.nextState.players[0].passed).toBe(true)
    }
  })

  it('accepts leaderAbility and marks it used', () => {
    const p0 = emptyPlayer(FACTIONS.A, { leader: LEADERS.A2 })
    const state = gameState(p0, emptyPlayer(FACTIONS.B))
    const result = validateAndApply(state, 0, { action: 'leaderAbility' })
    expect(result.valid).toBe(true)
    if (result.valid) {
      expect(result.nextState.players[0].leaderAbilityUsed).toBe(true)
    }
  })

  it('accepts medic selection', () => {
    const discardCard = unit('u1')
    const p0 = emptyPlayer(FACTIONS.A, { discard: [discardCard] })
    const state = gameState(p0, emptyPlayer(FACTIONS.B), { selectionMode: 'medic' })
    const result = validateAndApply(state, 0, { action: 'medic', cardId: 'u1' })
    expect(result.valid).toBe(true)
    if (result.valid) {
      expect(result.nextState.selectionMode).toBe('default')
    }
  })

  it('accepts decoy selection', () => {
    const boardCard = unit('u1')
    const p0 = emptyPlayer(FACTIONS.A, {
      board: {
        melee: { type: ROWS.MELEE, cards: [boardCard], warCry: false },
        ranged: emptyRow(ROWS.RANGED),
        siege: emptyRow(ROWS.SIEGE),
      },
    })
    const state = gameState(p0, emptyPlayer(FACTIONS.B), {
      selectionMode: 'decoy',
      pendingOptions: [boardCard],
    })
    const result = validateAndApply(state, 0, { action: 'decoy', cardId: 'u1' })
    expect(result.valid).toBe(true)
    if (result.valid) {
      expect(result.nextState.selectionMode).toBe('default')
    }
  })

  it('accepts agile row selection', () => {
    const pendingCard = unit('a1')
    const state = gameState(emptyPlayer(FACTIONS.A), emptyPlayer(FACTIONS.B), {
      selectionMode: 'agile',
      pendingOptions: [pendingCard],
    })
    const result = validateAndApply(state, 0, { action: 'agile', rowChoice: ROWS.RANGED })
    expect(result.valid).toBe(true)
    if (result.valid) {
      expect(result.nextState.selectionMode).toBe('default')
    }
  })

  it('accepts warCry row selection', () => {
    const state = gameState(emptyPlayer(FACTIONS.A), emptyPlayer(FACTIONS.B), {
      selectionMode: 'warCry',
    })
    const result = validateAndApply(state, 0, { action: 'warCry', rowChoice: ROWS.SIEGE })
    expect(result.valid).toBe(true)
    if (result.valid) {
      expect(result.nextState.selectionMode).toBe('default')
    }
  })

  it('accepts leaderB4 selection and returns to default mode', () => {
    const state = gameState(emptyPlayer(FACTIONS.A), emptyPlayer(FACTIONS.B), {
      selectionMode: 'leaderB4',
    })
    const result = validateAndApply(state, 0, { action: 'leaderB4', cardId: 'u1' })
    expect(result.valid).toBe(true)
    if (result.valid) {
      expect(result.nextState.selectionMode).toBe('default')
    }
  })

  it('accepts leaderD2 selection and returns to default mode', () => {
    const discardCard = unit('u1')
    const p0 = emptyPlayer(FACTIONS.D, { discard: [discardCard] })
    const state = gameState(p0, emptyPlayer(FACTIONS.B), { selectionMode: 'leaderD2' })
    const result = validateAndApply(state, 0, { action: 'leaderD2', cardId: 'u1' })
    expect(result.valid).toBe(true)
    if (result.valid) {
      expect(result.nextState.selectionMode).toBe('default')
    }
  })

  it('accepts first leaderD4discard and stays in discard mode', () => {
    const state = gameState(emptyPlayer(FACTIONS.D), emptyPlayer(FACTIONS.B), {
      selectionMode: 'leaderD4discard',
      pendingLeaderD4Discards: [],
    })
    const result = validateAndApply(state, 0, { action: 'leaderD4discard', cardId: 'u1' })
    expect(result.valid).toBe(true)
    if (result.valid) {
      expect(result.nextState.pendingLeaderD4Discards).toContain('u1')
    }
  })

  it('accepts second leaderD4discard and transitions to draw mode', () => {
    const state = gameState(emptyPlayer(FACTIONS.D), emptyPlayer(FACTIONS.B), {
      selectionMode: 'leaderD4discard',
      pendingLeaderD4Discards: ['u1'],
    })
    const result = validateAndApply(state, 0, { action: 'leaderD4discard', cardId: 'u2' })
    expect(result.valid).toBe(true)
    if (result.valid) {
      expect(result.nextState.selectionMode).toBe('leaderD4draw')
    }
  })

  it('accepts leaderD4draw and returns to default mode', () => {
    const deckCard = unit('d1')
    const p0 = emptyPlayer(FACTIONS.D, { deck: [deckCard] })
    const state = gameState(p0, emptyPlayer(FACTIONS.B), {
      selectionMode: 'leaderD4draw',
      pendingLeaderD4Discards: ['u1', 'u2'],
    })
    const result = validateAndApply(state, 0, { action: 'leaderD4draw', cardId: 'd1' })
    expect(result.valid).toBe(true)
    if (result.valid) {
      expect(result.nextState.selectionMode).toBe('default')
    }
  })

  it('accepts leaderD5 and returns to default mode', () => {
    const weatherCard: WeatherCard = {
      id: 'w1',
      type: 'weather',
      name: WEATHER.BLIZZARD,
      weatherType: WEATHER.BLIZZARD,
    }
    const p0 = emptyPlayer(FACTIONS.D, { deck: [weatherCard] })
    const state = gameState(p0, emptyPlayer(FACTIONS.B), { selectionMode: 'leaderD5' })
    const result = validateAndApply(state, 0, { action: 'leaderD5', cardId: 'w1' })
    expect(result.valid).toBe(true)
    if (result.valid) {
      expect(result.nextState.selectionMode).toBe('default')
    }
  })
})
