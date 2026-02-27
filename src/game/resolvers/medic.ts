import { ABILITIES } from '@/lib/terminology'
import type { GameState, PlayerState, UnitCard } from '@/types/game'
import { ROW_KEY } from '../rows'

export type ResolverDispatch = (
  state: GameState,
  cardId: string,
  playerIndex: 0 | 1,
  rng: () => number,
) => GameState

export function resolveMedic(
  state: GameState,
  cardId: string,
  playerIndex: 0 | 1,
  rng: () => number,
  dispatch: ResolverDispatch,
): GameState {
  const player = state.players[playerIndex]
  const card = player.hand.find((c) => c.id === cardId) as UnitCard | undefined
  if (!card) return state

  const hand = player.hand.filter((c) => c.id !== cardId)
  const rowKey = ROW_KEY[card.row]
  const board = {
    ...player.board,
    [rowKey]: {
      ...player.board[rowKey],
      cards: [...player.board[rowKey].cards, card],
    },
  }

  const eligibleCards = player.discard.filter((c): c is UnitCard => c.type === 'unit' && !c.isHero)

  const updatedPlayer: PlayerState = { ...player, hand, board }
  const players: [PlayerState, PlayerState] =
    playerIndex === 0 ? [updatedPlayer, state.players[1]] : [state.players[0], updatedPlayer]
  const partialState: GameState = { ...state, players }

  if (eligibleCards.length === 0) return partialState

  if (partialState.randomRestoration) {
    const selected = eligibleCards[Math.floor(rng() * eligibleCards.length)]
    return completeMedicSelection(partialState, selected.id, playerIndex, dispatch, rng)
  }

  return { ...partialState, selectionMode: 'medic', pendingOptions: eligibleCards }
}

export function completeMedicSelection(
  state: GameState,
  selectedCardId: string,
  playerIndex: 0 | 1,
  dispatch: ResolverDispatch,
  rng: () => number,
): GameState {
  const player = state.players[playerIndex]
  const card = player.discard.find((c) => c.id === selectedCardId) as UnitCard | undefined
  if (!card || card.type !== 'unit') return state

  const discard = player.discard.filter((c) => c.id !== selectedCardId)
  const rowKey = ROW_KEY[card.row]
  const board = {
    ...player.board,
    [rowKey]: {
      ...player.board[rowKey],
      cards: [...player.board[rowKey].cards, card],
    },
  }

  const updatedPlayer: PlayerState = { ...player, discard, board }
  const players: [PlayerState, PlayerState] =
    playerIndex === 0 ? [updatedPlayer, state.players[1]] : [state.players[0], updatedPlayer]
  const nextState: GameState = { ...state, players, selectionMode: 'default', pendingOptions: [] }

  if (card.ability !== null && card.ability !== ABILITIES.MEDIC) {
    return dispatch(nextState, card.id, playerIndex, rng)
  }

  return nextState
}
