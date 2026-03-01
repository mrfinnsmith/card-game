import type { GameState, RowType } from '@/types/game'
import { ROWS } from '@/lib/terminology'
import {
  completeLeaderAbilitySelection,
  completeSelection,
  confirmMulligan,
  pass,
  performMulligan,
  playCard,
  useLeaderAbility,
} from '@/game/stateMachine'

export type MovePayload = {
  action: string
  cardId?: string
  rowChoice?: string
}

export type MoveResult = { valid: true; nextState: GameState } | { valid: false; error: string }

const VALID_ROWS: RowType[] = [ROWS.MELEE, ROWS.RANGED, ROWS.SIEGE]

function requireActivePlayer(state: GameState, playerIndex: 0 | 1): string | null {
  if (state.activePlayer !== playerIndex) return 'Not your turn'
  if (state.players[playerIndex].passed) return 'You have already passed'
  return null
}

function requireDefaultMode(state: GameState): string | null {
  return state.selectionMode === 'default' ? null : `Awaiting selection: ${state.selectionMode}`
}

function requireMode(state: GameState, expected: string): string | null {
  return state.selectionMode === expected ? null : `Expected selection mode: ${expected}`
}

function requireCardInHand(state: GameState, playerIndex: 0 | 1, cardId: string): string | null {
  return state.players[playerIndex].hand.find((c) => c.id === cardId) ? null : 'Card not in hand'
}

function parseRow(rowChoice: string | undefined): RowType | null {
  return VALID_ROWS.find((r) => r === rowChoice) ?? null
}

export function validateAndApply(
  state: GameState,
  playerIndex: 0 | 1,
  payload: MovePayload,
  rng: () => number = Math.random,
): MoveResult {
  const { action, cardId, rowChoice } = payload

  // Mulligan phase
  if (action === 'mulligan') {
    if (state.selectionMode !== 'mulligan') return { valid: false, error: 'Not in mulligan phase' }
    if (state.mulligansConfirmed[playerIndex])
      return { valid: false, error: 'Mulligan already confirmed' }
    if (state.mulligansUsed[playerIndex] >= 2)
      return { valid: false, error: 'No mulligan swaps remaining' }
    if (!cardId) return { valid: false, error: 'cardId required' }
    const handErr = requireCardInHand(state, playerIndex, cardId)
    if (handErr) return { valid: false, error: handErr }
    if (state.mulliganedCardIds[playerIndex].includes(cardId))
      return { valid: false, error: 'Card already mulliganed' }
    return { valid: true, nextState: performMulligan(state, cardId, playerIndex) }
  }

  if (action === 'confirmMulligan') {
    if (state.selectionMode !== 'mulligan') return { valid: false, error: 'Not in mulligan phase' }
    if (state.mulligansConfirmed[playerIndex])
      return { valid: false, error: 'Mulligan already confirmed' }
    return { valid: true, nextState: confirmMulligan(state, playerIndex) }
  }

  if (state.selectionMode === 'mulligan') {
    return { valid: false, error: 'Game is still in mulligan phase' }
  }

  // Standard turn actions
  if (action === 'playCard') {
    const turnErr = requireActivePlayer(state, playerIndex)
    if (turnErr) return { valid: false, error: turnErr }
    const modeErr = requireDefaultMode(state)
    if (modeErr) return { valid: false, error: modeErr }
    if (!cardId) return { valid: false, error: 'cardId required' }
    const handErr = requireCardInHand(state, playerIndex, cardId)
    if (handErr) return { valid: false, error: handErr }
    return { valid: true, nextState: playCard(state, cardId, playerIndex, rng) }
  }

  if (action === 'pass') {
    const turnErr = requireActivePlayer(state, playerIndex)
    if (turnErr) return { valid: false, error: turnErr }
    const modeErr = requireDefaultMode(state)
    if (modeErr) return { valid: false, error: modeErr }
    return { valid: true, nextState: pass(state, playerIndex) }
  }

  if (action === 'leaderAbility') {
    const turnErr = requireActivePlayer(state, playerIndex)
    if (turnErr) return { valid: false, error: turnErr }
    const modeErr = requireDefaultMode(state)
    if (modeErr) return { valid: false, error: modeErr }
    if (state.players[playerIndex].leaderAbilityUsed)
      return { valid: false, error: 'Leader ability already used' }
    if (!state.players[playerIndex].leader) return { valid: false, error: 'No leader assigned' }
    // eslint-disable-next-line react-hooks/rules-of-hooks
    return { valid: true, nextState: useLeaderAbility(state, playerIndex, rng) }
  }

  // Selection completions — all require the active player
  if (state.activePlayer !== playerIndex) return { valid: false, error: 'Not your turn' }

  if (action === 'medic') {
    const modeErr = requireMode(state, 'medic')
    if (modeErr) return { valid: false, error: modeErr }
    if (!cardId) return { valid: false, error: 'cardId required' }
    return {
      valid: true,
      nextState: completeSelection(
        state,
        { mode: 'medic', selectedCardId: cardId },
        playerIndex,
        rng,
      ),
    }
  }

  if (action === 'decoy') {
    const modeErr = requireMode(state, 'decoy')
    if (modeErr) return { valid: false, error: modeErr }
    if (!cardId) return { valid: false, error: 'cardId required' }
    return {
      valid: true,
      nextState: completeSelection(
        state,
        { mode: 'decoy', selectedCardId: cardId },
        playerIndex,
        rng,
      ),
    }
  }

  if (action === 'agile') {
    const modeErr = requireMode(state, 'agile')
    if (modeErr) return { valid: false, error: modeErr }
    const row = parseRow(rowChoice)
    if (!row) return { valid: false, error: 'Invalid row' }
    return {
      valid: true,
      nextState: completeSelection(state, { mode: 'agile', row }, playerIndex, rng),
    }
  }

  if (action === 'warCry') {
    const modeErr = requireMode(state, 'warCry')
    if (modeErr) return { valid: false, error: modeErr }
    const row = parseRow(rowChoice)
    if (!row) return { valid: false, error: 'Invalid row' }
    return {
      valid: true,
      nextState: completeSelection(state, { mode: 'warCry', row }, playerIndex, rng),
    }
  }

  if (action === 'leaderB4') {
    const modeErr = requireMode(state, 'leaderB4')
    if (modeErr) return { valid: false, error: modeErr }
    if (!cardId) return { valid: false, error: 'cardId required' }
    return {
      valid: true,
      nextState: completeLeaderAbilitySelection(
        state,
        { mode: 'leaderB4', selectedCardId: cardId },
        playerIndex,
        rng,
      ),
    }
  }

  if (action === 'leaderD2') {
    const modeErr = requireMode(state, 'leaderD2')
    if (modeErr) return { valid: false, error: modeErr }
    if (!cardId) return { valid: false, error: 'cardId required' }
    return {
      valid: true,
      nextState: completeLeaderAbilitySelection(
        state,
        { mode: 'leaderD2', selectedCardId: cardId },
        playerIndex,
        rng,
      ),
    }
  }

  if (action === 'leaderD4discard') {
    const modeErr = requireMode(state, 'leaderD4discard')
    if (modeErr) return { valid: false, error: modeErr }
    if (!cardId) return { valid: false, error: 'cardId required' }
    return {
      valid: true,
      nextState: completeLeaderAbilitySelection(
        state,
        { mode: 'leaderD4discard', selectedCardId: cardId },
        playerIndex,
        rng,
      ),
    }
  }

  if (action === 'leaderD4draw') {
    const modeErr = requireMode(state, 'leaderD4draw')
    if (modeErr) return { valid: false, error: modeErr }
    if (!cardId) return { valid: false, error: 'cardId required' }
    return {
      valid: true,
      nextState: completeLeaderAbilitySelection(
        state,
        { mode: 'leaderD4draw', selectedCardId: cardId },
        playerIndex,
        rng,
      ),
    }
  }

  if (action === 'leaderD5') {
    const modeErr = requireMode(state, 'leaderD5')
    if (modeErr) return { valid: false, error: modeErr }
    if (!cardId) return { valid: false, error: 'cardId required' }
    return {
      valid: true,
      nextState: completeLeaderAbilitySelection(
        state,
        { mode: 'leaderD5', selectedCardId: cardId },
        playerIndex,
        rng,
      ),
    }
  }

  return { valid: false, error: 'Unknown action' }
}
