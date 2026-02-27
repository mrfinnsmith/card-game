import { ABILITIES, FACTIONS, ROWS, WEATHER } from '@/lib/terminology'
import type {
  Card,
  FactionId,
  RowType,
  SpecialCard,
  UnitAbility,
  UnitCard,
  WeatherCard,
} from '@/types/game'

function unit(
  id: string,
  faction: FactionId,
  row: RowType,
  baseStrength: number,
  ability: UnitAbility | null,
  isHero: boolean,
  rallyGroup: string | null,
  name?: string,
): UnitCard {
  return {
    id,
    type: 'unit',
    name: name ?? id,
    faction,
    row,
    baseStrength,
    ability,
    isHero,
    rallyGroup,
  }
}

// FACTION A — 37 unit cards (Formation-heavy)
export const FACTION_A_CARDS: UnitCard[] = [
  // Formation group FA_F1 — 3x Melee, str 8
  unit('fa-001', FACTIONS.A, ROWS.MELEE, 8, ABILITIES.FORMATION, false, null, 'FA_F1'),
  unit('fa-002', FACTIONS.A, ROWS.MELEE, 8, ABILITIES.FORMATION, false, null, 'FA_F1'),
  unit('fa-003', FACTIONS.A, ROWS.MELEE, 8, ABILITIES.FORMATION, false, null, 'FA_F1'),
  // Formation group FA_F2 — 3x Ranged, str 6
  unit('fa-004', FACTIONS.A, ROWS.RANGED, 6, ABILITIES.FORMATION, false, null, 'FA_F2'),
  unit('fa-005', FACTIONS.A, ROWS.RANGED, 6, ABILITIES.FORMATION, false, null, 'FA_F2'),
  unit('fa-006', FACTIONS.A, ROWS.RANGED, 6, ABILITIES.FORMATION, false, null, 'FA_F2'),
  // Formation group FA_F3 — 2x Siege, str 10
  unit('fa-007', FACTIONS.A, ROWS.SIEGE, 10, ABILITIES.FORMATION, false, null, 'FA_F3'),
  unit('fa-008', FACTIONS.A, ROWS.SIEGE, 10, ABILITIES.FORMATION, false, null, 'FA_F3'),
  // Formation group FA_F4 — 3x Melee, str 5
  unit('fa-009', FACTIONS.A, ROWS.MELEE, 5, ABILITIES.FORMATION, false, null, 'FA_F4'),
  unit('fa-010', FACTIONS.A, ROWS.MELEE, 5, ABILITIES.FORMATION, false, null, 'FA_F4'),
  unit('fa-011', FACTIONS.A, ROWS.MELEE, 5, ABILITIES.FORMATION, false, null, 'FA_F4'),
  // Formation group FA_F5 — 2x Ranged, str 7
  unit('fa-012', FACTIONS.A, ROWS.RANGED, 7, ABILITIES.FORMATION, false, null, 'FA_F5'),
  unit('fa-013', FACTIONS.A, ROWS.RANGED, 7, ABILITIES.FORMATION, false, null, 'FA_F5'),
  // Formation group FA_F6 — 3x Siege, str 4
  unit('fa-014', FACTIONS.A, ROWS.SIEGE, 4, ABILITIES.FORMATION, false, null, 'FA_F6'),
  unit('fa-015', FACTIONS.A, ROWS.SIEGE, 4, ABILITIES.FORMATION, false, null, 'FA_F6'),
  unit('fa-016', FACTIONS.A, ROWS.SIEGE, 4, ABILITIES.FORMATION, false, null, 'FA_F6'),
  // Formation group FA_F7 — 2x Melee, str 9
  unit('fa-017', FACTIONS.A, ROWS.MELEE, 9, ABILITIES.FORMATION, false, null, 'FA_F7'),
  unit('fa-018', FACTIONS.A, ROWS.MELEE, 9, ABILITIES.FORMATION, false, null, 'FA_F7'),
  // Formation group FA_F8 — 2x Ranged, str 5
  unit('fa-019', FACTIONS.A, ROWS.RANGED, 5, ABILITIES.FORMATION, false, null, 'FA_F8'),
  unit('fa-020', FACTIONS.A, ROWS.RANGED, 5, ABILITIES.FORMATION, false, null, 'FA_F8'),
  // Heroes
  unit('fa-021', FACTIONS.A, ROWS.MELEE, 15, ABILITIES.HERO, true, null),
  unit('fa-022', FACTIONS.A, ROWS.SIEGE, 10, ABILITIES.HERO, true, null),
  // Morale Boost
  unit('fa-023', FACTIONS.A, ROWS.MELEE, 3, ABILITIES.MORALE_BOOST, false, null),
  unit('fa-024', FACTIONS.A, ROWS.RANGED, 4, ABILITIES.MORALE_BOOST, false, null),
  unit('fa-025', FACTIONS.A, ROWS.SIEGE, 2, ABILITIES.MORALE_BOOST, false, null),
  // Row Scorch
  unit('fa-026', FACTIONS.A, ROWS.SIEGE, 6, ABILITIES.ROW_SCORCH, false, null),
  unit('fa-027', FACTIONS.A, ROWS.SIEGE, 7, ABILITIES.ROW_SCORCH, false, null),
  // War Cry (unit ability)
  unit('fa-028', FACTIONS.A, ROWS.MELEE, 5, ABILITIES.WAR_CRY, false, null),
  unit('fa-029', FACTIONS.A, ROWS.RANGED, 6, ABILITIES.WAR_CRY, false, null),
  // Regular
  unit('fa-030', FACTIONS.A, ROWS.MELEE, 7, null, false, null),
  unit('fa-031', FACTIONS.A, ROWS.MELEE, 4, null, false, null),
  unit('fa-032', FACTIONS.A, ROWS.RANGED, 8, null, false, null),
  unit('fa-033', FACTIONS.A, ROWS.RANGED, 3, null, false, null),
  unit('fa-034', FACTIONS.A, ROWS.SIEGE, 5, null, false, null),
  unit('fa-035', FACTIONS.A, ROWS.SIEGE, 6, null, false, null),
  unit('fa-036', FACTIONS.A, ROWS.MELEE, 6, null, false, null),
  unit('fa-037', FACTIONS.A, ROWS.RANGED, 9, null, false, null),
]

// FACTION B — 38 unit cards (Infiltrator-heavy)
export const FACTION_B_CARDS: UnitCard[] = [
  // Infiltrators
  unit('fb-001', FACTIONS.B, ROWS.MELEE, 7, ABILITIES.INFILTRATOR, false, null),
  unit('fb-002', FACTIONS.B, ROWS.MELEE, 5, ABILITIES.INFILTRATOR, false, null),
  unit('fb-003', FACTIONS.B, ROWS.RANGED, 6, ABILITIES.INFILTRATOR, false, null),
  unit('fb-004', FACTIONS.B, ROWS.RANGED, 8, ABILITIES.INFILTRATOR, false, null),
  unit('fb-005', FACTIONS.B, ROWS.SIEGE, 5, ABILITIES.INFILTRATOR, false, null),
  unit('fb-006', FACTIONS.B, ROWS.SIEGE, 7, ABILITIES.INFILTRATOR, false, null),
  unit('fb-007', FACTIONS.B, ROWS.MELEE, 4, ABILITIES.INFILTRATOR, false, null),
  // Heroes
  unit('fb-008', FACTIONS.B, ROWS.RANGED, 14, ABILITIES.HERO, true, null),
  unit('fb-009', FACTIONS.B, ROWS.MELEE, 11, ABILITIES.HERO, true, null),
  // Formation group FB_F1 — 2x Ranged, str 7
  unit('fb-010', FACTIONS.B, ROWS.RANGED, 7, ABILITIES.FORMATION, false, null, 'FB_F1'),
  unit('fb-011', FACTIONS.B, ROWS.RANGED, 7, ABILITIES.FORMATION, false, null, 'FB_F1'),
  // Formation group FB_F2 — 2x Melee, str 6
  unit('fb-012', FACTIONS.B, ROWS.MELEE, 6, ABILITIES.FORMATION, false, null, 'FB_F2'),
  unit('fb-013', FACTIONS.B, ROWS.MELEE, 6, ABILITIES.FORMATION, false, null, 'FB_F2'),
  // Medic
  unit('fb-014', FACTIONS.B, ROWS.RANGED, 5, ABILITIES.MEDIC, false, null),
  unit('fb-015', FACTIONS.B, ROWS.RANGED, 4, ABILITIES.MEDIC, false, null),
  unit('fb-016', FACTIONS.B, ROWS.MELEE, 3, ABILITIES.MEDIC, false, null),
  // Morale Boost
  unit('fb-017', FACTIONS.B, ROWS.MELEE, 5, ABILITIES.MORALE_BOOST, false, null),
  unit('fb-018', FACTIONS.B, ROWS.RANGED, 4, ABILITIES.MORALE_BOOST, false, null),
  // Agile
  unit('fb-019', FACTIONS.B, ROWS.MELEE, 7, ABILITIES.AGILE, false, null),
  unit('fb-020', FACTIONS.B, ROWS.MELEE, 6, ABILITIES.AGILE, false, null),
  unit('fb-021', FACTIONS.B, ROWS.MELEE, 5, ABILITIES.AGILE, false, null),
  // Row Scorch
  unit('fb-022', FACTIONS.B, ROWS.SIEGE, 8, ABILITIES.ROW_SCORCH, false, null),
  // War Cry
  unit('fb-023', FACTIONS.B, ROWS.MELEE, 6, ABILITIES.WAR_CRY, false, null),
  // Regular
  unit('fb-024', FACTIONS.B, ROWS.MELEE, 7, null, false, null),
  unit('fb-025', FACTIONS.B, ROWS.MELEE, 5, null, false, null),
  unit('fb-026', FACTIONS.B, ROWS.MELEE, 3, null, false, null),
  unit('fb-027', FACTIONS.B, ROWS.RANGED, 9, null, false, null),
  unit('fb-028', FACTIONS.B, ROWS.RANGED, 6, null, false, null),
  unit('fb-029', FACTIONS.B, ROWS.RANGED, 4, null, false, null),
  unit('fb-030', FACTIONS.B, ROWS.SIEGE, 8, null, false, null),
  unit('fb-031', FACTIONS.B, ROWS.SIEGE, 6, null, false, null),
  unit('fb-032', FACTIONS.B, ROWS.SIEGE, 4, null, false, null),
  unit('fb-033', FACTIONS.B, ROWS.MELEE, 8, null, false, null),
  unit('fb-034', FACTIONS.B, ROWS.RANGED, 5, null, false, null),
  unit('fb-035', FACTIONS.B, ROWS.SIEGE, 7, null, false, null),
  unit('fb-036', FACTIONS.B, ROWS.MELEE, 6, null, false, null),
  unit('fb-037', FACTIONS.B, ROWS.RANGED, 7, null, false, null),
  unit('fb-038', FACTIONS.B, ROWS.SIEGE, 5, null, false, null),
]

// FACTION C — 37 unit cards (Agile + Rally)
export const FACTION_C_CARDS: UnitCard[] = [
  // Heroes
  unit('fc-001', FACTIONS.C, ROWS.MELEE, 13, ABILITIES.HERO, true, null),
  unit('fc-002', FACTIONS.C, ROWS.RANGED, 10, ABILITIES.HERO, true, null),
  // Agile
  unit('fc-003', FACTIONS.C, ROWS.MELEE, 8, ABILITIES.AGILE, false, null),
  unit('fc-004', FACTIONS.C, ROWS.MELEE, 7, ABILITIES.AGILE, false, null),
  unit('fc-005', FACTIONS.C, ROWS.MELEE, 6, ABILITIES.AGILE, false, null),
  unit('fc-006', FACTIONS.C, ROWS.MELEE, 5, ABILITIES.AGILE, false, null),
  unit('fc-007', FACTIONS.C, ROWS.MELEE, 9, ABILITIES.AGILE, false, null),
  unit('fc-008', FACTIONS.C, ROWS.MELEE, 4, ABILITIES.AGILE, false, null),
  // Rally group FC_R1 — 3x Melee, str 5
  unit('fc-009', FACTIONS.C, ROWS.MELEE, 5, ABILITIES.RALLY, false, 'FC_R1'),
  unit('fc-010', FACTIONS.C, ROWS.MELEE, 5, ABILITIES.RALLY, false, 'FC_R1'),
  unit('fc-011', FACTIONS.C, ROWS.MELEE, 5, ABILITIES.RALLY, false, 'FC_R1'),
  // Rally group FC_R2 — 3x Ranged, str 4
  unit('fc-012', FACTIONS.C, ROWS.RANGED, 4, ABILITIES.RALLY, false, 'FC_R2'),
  unit('fc-013', FACTIONS.C, ROWS.RANGED, 4, ABILITIES.RALLY, false, 'FC_R2'),
  unit('fc-014', FACTIONS.C, ROWS.RANGED, 4, ABILITIES.RALLY, false, 'FC_R2'),
  // Rally group FC_R3 — 3x Siege, str 6
  unit('fc-015', FACTIONS.C, ROWS.SIEGE, 6, ABILITIES.RALLY, false, 'FC_R3'),
  unit('fc-016', FACTIONS.C, ROWS.SIEGE, 6, ABILITIES.RALLY, false, 'FC_R3'),
  unit('fc-017', FACTIONS.C, ROWS.SIEGE, 6, ABILITIES.RALLY, false, 'FC_R3'),
  // Rally group FC_R4 — 2x Melee, str 7
  unit('fc-018', FACTIONS.C, ROWS.MELEE, 7, ABILITIES.RALLY, false, 'FC_R4'),
  unit('fc-019', FACTIONS.C, ROWS.MELEE, 7, ABILITIES.RALLY, false, 'FC_R4'),
  // Formation group FC_F1 — 2x Melee, str 6
  unit('fc-020', FACTIONS.C, ROWS.MELEE, 6, ABILITIES.FORMATION, false, null, 'FC_F1'),
  unit('fc-021', FACTIONS.C, ROWS.MELEE, 6, ABILITIES.FORMATION, false, null, 'FC_F1'),
  // Formation group FC_F2 — 2x Ranged, str 8
  unit('fc-022', FACTIONS.C, ROWS.RANGED, 8, ABILITIES.FORMATION, false, null, 'FC_F2'),
  unit('fc-023', FACTIONS.C, ROWS.RANGED, 8, ABILITIES.FORMATION, false, null, 'FC_F2'),
  // Morale Boost
  unit('fc-024', FACTIONS.C, ROWS.MELEE, 4, ABILITIES.MORALE_BOOST, false, null),
  unit('fc-025', FACTIONS.C, ROWS.RANGED, 3, ABILITIES.MORALE_BOOST, false, null),
  // Row Scorch
  unit('fc-026', FACTIONS.C, ROWS.SIEGE, 7, ABILITIES.ROW_SCORCH, false, null),
  // War Cry
  unit('fc-027', FACTIONS.C, ROWS.MELEE, 5, ABILITIES.WAR_CRY, false, null),
  // Regular
  unit('fc-028', FACTIONS.C, ROWS.MELEE, 7, null, false, null),
  unit('fc-029', FACTIONS.C, ROWS.MELEE, 5, null, false, null),
  unit('fc-030', FACTIONS.C, ROWS.RANGED, 8, null, false, null),
  unit('fc-031', FACTIONS.C, ROWS.RANGED, 6, null, false, null),
  unit('fc-032', FACTIONS.C, ROWS.SIEGE, 5, null, false, null),
  unit('fc-033', FACTIONS.C, ROWS.SIEGE, 7, null, false, null),
  unit('fc-034', FACTIONS.C, ROWS.MELEE, 4, null, false, null),
  unit('fc-035', FACTIONS.C, ROWS.RANGED, 9, null, false, null),
  unit('fc-036', FACTIONS.C, ROWS.SIEGE, 4, null, false, null),
  unit('fc-037', FACTIONS.C, ROWS.MELEE, 6, null, false, null),
]

// FACTION D — 40 unit cards (Rally + weather synergies)
export const FACTION_D_CARDS: UnitCard[] = [
  // Heroes
  unit('fd-001', FACTIONS.D, ROWS.MELEE, 16, ABILITIES.HERO, true, null),
  unit('fd-002', FACTIONS.D, ROWS.RANGED, 12, ABILITIES.HERO, true, null),
  // Rally group FD_R1 — 3x Melee, str 6
  unit('fd-003', FACTIONS.D, ROWS.MELEE, 6, ABILITIES.RALLY, false, 'FD_R1'),
  unit('fd-004', FACTIONS.D, ROWS.MELEE, 6, ABILITIES.RALLY, false, 'FD_R1'),
  unit('fd-005', FACTIONS.D, ROWS.MELEE, 6, ABILITIES.RALLY, false, 'FD_R1'),
  // Rally group FD_R2 — 3x Ranged, str 5
  unit('fd-006', FACTIONS.D, ROWS.RANGED, 5, ABILITIES.RALLY, false, 'FD_R2'),
  unit('fd-007', FACTIONS.D, ROWS.RANGED, 5, ABILITIES.RALLY, false, 'FD_R2'),
  unit('fd-008', FACTIONS.D, ROWS.RANGED, 5, ABILITIES.RALLY, false, 'FD_R2'),
  // Rally group FD_R3 — 3x Siege, str 7
  unit('fd-009', FACTIONS.D, ROWS.SIEGE, 7, ABILITIES.RALLY, false, 'FD_R3'),
  unit('fd-010', FACTIONS.D, ROWS.SIEGE, 7, ABILITIES.RALLY, false, 'FD_R3'),
  unit('fd-011', FACTIONS.D, ROWS.SIEGE, 7, ABILITIES.RALLY, false, 'FD_R3'),
  // Rally group FD_R4 — 3x Melee, str 4
  unit('fd-012', FACTIONS.D, ROWS.MELEE, 4, ABILITIES.RALLY, false, 'FD_R4'),
  unit('fd-013', FACTIONS.D, ROWS.MELEE, 4, ABILITIES.RALLY, false, 'FD_R4'),
  unit('fd-014', FACTIONS.D, ROWS.MELEE, 4, ABILITIES.RALLY, false, 'FD_R4'),
  // Rally group FD_R5 — 2x Ranged, str 8
  unit('fd-015', FACTIONS.D, ROWS.RANGED, 8, ABILITIES.RALLY, false, 'FD_R5'),
  unit('fd-016', FACTIONS.D, ROWS.RANGED, 8, ABILITIES.RALLY, false, 'FD_R5'),
  // Rally group FD_R6 — 2x Siege, str 5
  unit('fd-017', FACTIONS.D, ROWS.SIEGE, 5, ABILITIES.RALLY, false, 'FD_R6'),
  unit('fd-018', FACTIONS.D, ROWS.SIEGE, 5, ABILITIES.RALLY, false, 'FD_R6'),
  // Medic
  unit('fd-019', FACTIONS.D, ROWS.RANGED, 5, ABILITIES.MEDIC, false, null),
  unit('fd-020', FACTIONS.D, ROWS.RANGED, 4, ABILITIES.MEDIC, false, null),
  // Morale Boost
  unit('fd-021', FACTIONS.D, ROWS.MELEE, 3, ABILITIES.MORALE_BOOST, false, null),
  unit('fd-022', FACTIONS.D, ROWS.RANGED, 4, ABILITIES.MORALE_BOOST, false, null),
  unit('fd-023', FACTIONS.D, ROWS.SIEGE, 3, ABILITIES.MORALE_BOOST, false, null),
  // Row Scorch
  unit('fd-024', FACTIONS.D, ROWS.SIEGE, 8, ABILITIES.ROW_SCORCH, false, null),
  unit('fd-025', FACTIONS.D, ROWS.SIEGE, 9, ABILITIES.ROW_SCORCH, false, null),
  // War Cry
  unit('fd-026', FACTIONS.D, ROWS.MELEE, 6, ABILITIES.WAR_CRY, false, null),
  // Agile
  unit('fd-027', FACTIONS.D, ROWS.MELEE, 7, ABILITIES.AGILE, false, null),
  unit('fd-028', FACTIONS.D, ROWS.MELEE, 5, ABILITIES.AGILE, false, null),
  // Regular
  unit('fd-029', FACTIONS.D, ROWS.MELEE, 7, null, false, null),
  unit('fd-030', FACTIONS.D, ROWS.MELEE, 5, null, false, null),
  unit('fd-031', FACTIONS.D, ROWS.RANGED, 8, null, false, null),
  unit('fd-032', FACTIONS.D, ROWS.RANGED, 6, null, false, null),
  unit('fd-033', FACTIONS.D, ROWS.SIEGE, 5, null, false, null),
  unit('fd-034', FACTIONS.D, ROWS.SIEGE, 7, null, false, null),
  unit('fd-035', FACTIONS.D, ROWS.MELEE, 4, null, false, null),
  unit('fd-036', FACTIONS.D, ROWS.RANGED, 9, null, false, null),
  unit('fd-037', FACTIONS.D, ROWS.SIEGE, 4, null, false, null),
  unit('fd-038', FACTIONS.D, ROWS.MELEE, 6, null, false, null),
  unit('fd-039', FACTIONS.D, ROWS.RANGED, 7, null, false, null),
  unit('fd-040', FACTIONS.D, ROWS.SIEGE, 6, null, false, null),
]

// NEUTRAL UNIT CARDS — 8
export const NEUTRAL_UNIT_CARDS: UnitCard[] = [
  unit('n-001', 'Neutral', ROWS.MELEE, 5, null, false, null),
  unit('n-002', 'Neutral', ROWS.RANGED, 6, null, false, null),
  unit('n-003', 'Neutral', ROWS.SIEGE, 4, null, false, null),
  unit('n-004', 'Neutral', ROWS.MELEE, 7, null, false, null),
  unit('n-005', 'Neutral', ROWS.MELEE, 5, ABILITIES.AGILE, false, null),
  unit('n-006', 'Neutral', ROWS.RANGED, 3, ABILITIES.MORALE_BOOST, false, null),
  unit('n-007', 'Neutral', ROWS.MELEE, 4, ABILITIES.WAR_CRY, false, null),
  unit('n-008', 'Neutral', ROWS.RANGED, 3, ABILITIES.MEDIC, false, null),
]

// NEUTRAL WEATHER CARDS — 4
export const NEUTRAL_WEATHER_CARDS: WeatherCard[] = [
  { id: 'nw-blizzard', type: 'weather', name: 'nw-blizzard', weatherType: WEATHER.BLIZZARD },
  { id: 'nw-shroud', type: 'weather', name: 'nw-shroud', weatherType: WEATHER.SHROUD },
  { id: 'nw-deluge', type: 'weather', name: 'nw-deluge', weatherType: WEATHER.DELUGE },
  { id: 'nw-dispel', type: 'weather', name: 'nw-dispel', weatherType: WEATHER.DISPEL },
]

// NEUTRAL SPECIAL CARDS — 3
export const NEUTRAL_SPECIAL_CARDS: SpecialCard[] = [
  { id: 'ns-scorch', type: 'special', name: 'ns-scorch', ability: ABILITIES.SCORCH },
  { id: 'ns-warcry', type: 'special', name: 'ns-warcry', ability: ABILITIES.WAR_CRY },
  { id: 'ns-decoy', type: 'special', name: 'ns-decoy', ability: ABILITIES.DECOY },
]

export const ALL_CARDS: Card[] = [
  ...FACTION_A_CARDS,
  ...FACTION_B_CARDS,
  ...FACTION_C_CARDS,
  ...FACTION_D_CARDS,
  ...NEUTRAL_UNIT_CARDS,
  ...NEUTRAL_WEATHER_CARDS,
  ...NEUTRAL_SPECIAL_CARDS,
]
