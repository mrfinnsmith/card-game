import { ROWS } from '@/lib/terminology'
import type { Card, GameState, PlayerState, UnitCard } from '@/types/game'

export type MaskedHand = Card[] | { cardCount: number }

export type MaskedPlayerState = Omit<PlayerState, 'hand'> & { hand: MaskedHand }

export type MaskedGameState = Omit<GameState, 'players'> & {
  players: [MaskedPlayerState, MaskedPlayerState]
}

/**
 * Produces a masked copy of the game state for a specific player.
 * The opponent's hand is replaced with a card count. revealedCards (Leader B1)
 * is stripped unless the recipient is the active player who triggered it.
 */
export function maskState(state: GameState, forPlayer: 0 | 1): MaskedGameState {
  const opponentIndex: 0 | 1 = forPlayer === 0 ? 1 : 0
  const { revealedCards, ...rest } = state

  const masked: MaskedGameState = {
    ...rest,
    players: [{ ...state.players[0] }, { ...state.players[1] }],
  }

  masked.players[opponentIndex] = {
    ...state.players[opponentIndex],
    hand: { cardCount: state.players[opponentIndex].hand.length },
  }

  if (revealedCards && forPlayer === state.activePlayer) {
    masked.revealedCards = revealedCards
  }

  return masked
}

function makePlaceholderCard(index: number): UnitCard {
  return {
    id: `hidden-${index}`,
    type: 'unit',
    name: '',
    faction: 'Neutral',
    row: ROWS.MELEE,
    baseStrength: 0,
    ability: null,
    isHero: false,
    rallyGroup: null,
  }
}

/**
 * Converts a MaskedGameState into a full GameState for the Zustand store.
 * The opponent's masked hand is replaced with N placeholder cards so that
 * existing components can use hand.length without modification.
 *
 * When playerIndex is 1 (guest), the players array and all player-indexed
 * fields are swapped so that "me" is always at index 0 in the local store,
 * matching the convention expected by the solo game components.
 */
export function hydrateMaskedState(masked: MaskedGameState, playerIndex: 0 | 1): GameState {
  const opponentIndex: 0 | 1 = playerIndex === 0 ? 1 : 0

  const players: [PlayerState, PlayerState] = [
    { ...masked.players[0], hand: masked.players[0].hand as Card[] },
    { ...masked.players[1], hand: masked.players[1].hand as Card[] },
  ]

  const opponentHand = masked.players[opponentIndex].hand
  if (!Array.isArray(opponentHand)) {
    players[opponentIndex] = {
      ...(masked.players[opponentIndex] as PlayerState),
      hand: Array.from({ length: opponentHand.cardCount }, (_, i) => makePlaceholderCard(i)),
    }
  }

  const base: GameState = { ...masked, players }

  if (playerIndex === 0) return base

  return {
    ...base,
    players: [players[1], players[0]],
    activePlayer: (base.activePlayer === 0 ? 1 : 0) as 0 | 1,
    roundWins: [base.roundWins[1], base.roundWins[0]] as [number, number],
    mulligansUsed: [base.mulligansUsed[1], base.mulligansUsed[0]] as [number, number],
    mulliganedCardIds: [base.mulliganedCardIds[1], base.mulliganedCardIds[0]] as [
      string[],
      string[],
    ],
    mulligansConfirmed: [base.mulligansConfirmed[1], base.mulligansConfirmed[0]] as [
      boolean,
      boolean,
    ],
  }
}
