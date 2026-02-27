import { FACTIONS } from '@/lib/terminology'
import type { GameState, PlayerState, UnitCard } from '@/types/game'
import { ROW_KEY } from './rows'

export function applyFactionADraw(state: GameState, playerIndex: 0 | 1): GameState {
  const player = state.players[playerIndex]
  if (player.faction !== FACTIONS.A || player.deck.length === 0) return state

  const [drawn, ...deck] = player.deck
  const updated: PlayerState = { ...player, hand: [...player.hand, drawn], deck }
  const players: [PlayerState, PlayerState] =
    playerIndex === 0 ? [updated, state.players[1]] : [state.players[0], updated]
  return { ...state, players }
}

export function resolveRoundGems(state: GameState, p0Score: number, p1Score: number): GameState {
  const [p0, p1] = state.players

  if (p0Score > p1Score) {
    return { ...state, players: [p0, { ...p1, gems: p1.gems - 1 }] }
  }

  if (p1Score > p0Score) {
    return { ...state, players: [{ ...p0, gems: p0.gems - 1 }, p1] }
  }

  // Draw: Faction B wins — only opponent loses a gem
  if (p0.faction === FACTIONS.B) {
    return { ...state, players: [p0, { ...p1, gems: p1.gems - 1 }] }
  }
  if (p1.faction === FACTIONS.B) {
    return { ...state, players: [{ ...p0, gems: p0.gems - 1 }, p1] }
  }

  // Neither is Faction B — both lose a gem
  return {
    ...state,
    players: [
      { ...p0, gems: p0.gems - 1 },
      { ...p1, gems: p1.gems - 1 },
    ],
  }
}

export function applyFactionCFirstTurn(state: GameState, chosenFirstPlayer: 0 | 1): GameState {
  const hasFactionC = state.players.some((p) => p.faction === FACTIONS.C)
  if (!hasFactionC) return state
  return { ...state, activePlayer: chosenFirstPlayer }
}

export function applyFactionDRetain(
  state: GameState,
  playerIndex: 0 | 1,
  rng: () => number,
): GameState {
  const player = state.players[playerIndex]
  if (player.faction !== FACTIONS.D) return state

  const units = player.discard.filter((c): c is UnitCard => c.type === 'unit')
  if (units.length === 0) return state

  const retained = units[Math.floor(rng() * units.length)]
  const discard = player.discard.filter((c) => c.id !== retained.id)
  const rowKey = ROW_KEY[retained.row]
  const board = {
    ...player.board,
    [rowKey]: {
      ...player.board[rowKey],
      cards: [...player.board[rowKey].cards, retained],
    },
  }

  const updated: PlayerState = { ...player, discard, board }
  const players: [PlayerState, PlayerState] =
    playerIndex === 0 ? [updated, state.players[1]] : [state.players[0], updated]
  return { ...state, players }
}
