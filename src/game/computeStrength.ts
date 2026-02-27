import { ABILITIES, ROWS, WEATHER } from '@/lib/terminology'
import type { GameState, RowState } from '@/types/game'

const WEATHER_FOR_ROW: Record<string, string> = {
  [ROWS.MELEE]: WEATHER.BLIZZARD,
  [ROWS.RANGED]: WEATHER.SHROUD,
  [ROWS.SIEGE]: WEATHER.DELUGE,
}

export function computeStrength(cardId: string, rowState: RowState, boardState: GameState): number {
  const card = rowState.cards.find((c) => c.id === cardId)
  if (!card) return 0

  // Heroes ignore weather and all modifiers — always show base strength
  if (card.isHero) return card.baseStrength

  // 1. Weather: if this row's weather is active, cap at 1
  const rowWeather = WEATHER_FOR_ROW[rowState.type]
  const weatherActive = boardState.weatherZone.some((w) => w.weatherType === rowWeather)
  if (weatherActive) return 1

  // 2. Formation: base × count of same-named cards in this row
  const formationCount = rowState.cards.filter((c) => c.name === card.name).length
  let strength = formationCount > 1 ? card.baseStrength * formationCount : card.baseStrength

  // 3. Morale Boost: +1 per Morale Boost unit in this row, not counting self
  const moraleBoostCount = rowState.cards.filter(
    (c) => c.id !== cardId && c.ability === ABILITIES.MORALE_BOOST,
  ).length
  strength += moraleBoostCount

  // 4. War Cry: ×2 if active on this row
  if (rowState.warCry) strength *= 2

  return strength
}
