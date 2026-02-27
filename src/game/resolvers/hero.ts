import type { UnitCard } from '@/types/game'

// Heroes cannot be targeted by Decoy, Medic, or Scorch.
export function canBeTargeted(card: UnitCard): boolean {
  return !card.isHero
}
