import { WEATHER } from '@/lib/terminology'
import type { Card, GameState, PlayerState, WeatherCard } from '@/types/game'

export function resolveWeather(state: GameState, cardId: string, playerIndex: 0 | 1): GameState {
  const player = state.players[playerIndex]
  const card = player.hand.find((c) => c.id === cardId) as WeatherCard | undefined
  if (!card) return state

  const hand = player.hand.filter((c) => c.id !== cardId)

  if (card.weatherType === WEATHER.DISPEL) {
    const discard: Card[] = [...player.discard, card]
    const updatedPlayer: PlayerState = { ...player, hand, discard }
    const players: [PlayerState, PlayerState] =
      playerIndex === 0 ? [updatedPlayer, state.players[1]] : [state.players[0], updatedPlayer]
    return { ...state, players, weatherZone: [] }
  }

  const updatedPlayer: PlayerState = { ...player, hand }
  const players: [PlayerState, PlayerState] =
    playerIndex === 0 ? [updatedPlayer, state.players[1]] : [state.players[0], updatedPlayer]

  return { ...state, players, weatherZone: [...state.weatherZone, card] }
}
