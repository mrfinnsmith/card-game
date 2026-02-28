import { FACTIONS } from '@/lib/terminology'
import type { Card, PlayerFaction } from '@/types/game'
import { ALL_CARDS } from './cards'

// Pre-built deck card IDs per faction.
// Each deck satisfies deck construction rules: ≥22 unit cards, ≤10 special cards.
const DECK_IDS: Record<PlayerFaction, string[]> = {
  [FACTIONS.A]: [
    // Formation groups (13 units)
    'fa-001',
    'fa-002',
    'fa-003', // FA_F1 Melee str 8
    'fa-004',
    'fa-005',
    'fa-006', // FA_F2 Ranged str 6
    'fa-007',
    'fa-008', // FA_F3 Siege str 10
    'fa-012',
    'fa-013', // FA_F5 Ranged str 7
    'fa-017',
    'fa-018', // FA_F7 Melee str 9
    // Heroes (2)
    'fa-021',
    'fa-022',
    // Morale Boost (3)
    'fa-023',
    'fa-024',
    'fa-025',
    // Row Scorch (2)
    'fa-026',
    'fa-027',
    // War Cry unit (2)
    'fa-028',
    'fa-029',
    // Regular (3)
    'fa-030',
    'fa-032',
    'fa-034',
    // Specials: 5 (≤10)
    'nw-blizzard',
    'nw-shroud',
    'nw-deluge',
    'ns-scorch',
    'ns-warcry',
  ],
  [FACTIONS.B]: [
    // Infiltrators (7)
    'fb-001',
    'fb-002',
    'fb-003',
    'fb-004',
    'fb-005',
    'fb-006',
    'fb-007',
    // Heroes (2)
    'fb-008',
    'fb-009',
    // Formation (4)
    'fb-010',
    'fb-011',
    'fb-012',
    'fb-013',
    // Medic (3)
    'fb-014',
    'fb-015',
    'fb-016',
    // Morale Boost (2)
    'fb-017',
    'fb-018',
    // Agile (3)
    'fb-019',
    'fb-020',
    'fb-021',
    // Row Scorch (1)
    'fb-022',
    // War Cry unit (1)
    'fb-023',
    // Regular (1)
    'fb-024',
    // Specials: 6 (≤10)
    'nw-blizzard',
    'nw-shroud',
    'nw-deluge',
    'nw-dispel',
    'ns-scorch',
    'ns-decoy',
  ],
  [FACTIONS.C]: [
    // Heroes (2)
    'fc-001',
    'fc-002',
    // Agile (6)
    'fc-003',
    'fc-004',
    'fc-005',
    'fc-006',
    'fc-007',
    'fc-008',
    // Rally groups (9)
    'fc-009',
    'fc-010',
    'fc-011', // FC_R1 Melee str 5
    'fc-012',
    'fc-013',
    'fc-014', // FC_R2 Ranged str 4
    'fc-015',
    'fc-016',
    'fc-017', // FC_R3 Siege str 6
    // Formation (4)
    'fc-020',
    'fc-021', // FC_F1 Melee str 6
    'fc-022',
    'fc-023', // FC_F2 Ranged str 8
    // Morale Boost (2)
    'fc-024',
    'fc-025',
    // Regular (1)
    'fc-028',
    // Specials: 6 (≤10)
    'nw-blizzard',
    'nw-shroud',
    'nw-deluge',
    'nw-dispel',
    'ns-warcry',
    'ns-decoy',
  ],
  [FACTIONS.D]: [
    // Heroes (2)
    'fd-001',
    'fd-002',
    // Rally groups (12)
    'fd-003',
    'fd-004',
    'fd-005', // FD_R1 Melee str 6
    'fd-006',
    'fd-007',
    'fd-008', // FD_R2 Ranged str 5
    'fd-009',
    'fd-010',
    'fd-011', // FD_R3 Siege str 7
    'fd-012',
    'fd-013',
    'fd-014', // FD_R4 Melee str 4
    // Medic (2)
    'fd-019',
    'fd-020',
    // Morale Boost (3)
    'fd-021',
    'fd-022',
    'fd-023',
    // Row Scorch (2)
    'fd-024',
    'fd-025',
    // War Cry unit (1)
    'fd-026',
    // Regular (3)
    'fd-029',
    'fd-031',
    'fd-033',
    // Specials: 6 (≤10)
    'nw-blizzard',
    'nw-shroud',
    'nw-deluge',
    'nw-dispel',
    'ns-scorch',
    'ns-warcry',
  ],
}

export function buildDeck(faction: PlayerFaction, prefix: string): Card[] {
  return DECK_IDS[faction].map((id) => {
    const card = ALL_CARDS.find((c) => c.id === id)
    if (!card) throw new Error(`Card not found in deck definition: ${id}`)
    return { ...card, id: `${prefix}-${id}` }
  })
}

export function shuffleDeck(deck: Card[], rng: () => number = Math.random): Card[] {
  const shuffled = [...deck]
  for (let i = shuffled.length - 1; i > 0; i--) {
    const j = Math.floor(rng() * (i + 1))
    ;[shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]]
  }
  return shuffled
}
