import { ABILITIES, FACTIONS, ROWS, WEATHER } from '@/lib/terminology'

export type RowType = (typeof ROWS)[keyof typeof ROWS]
export type FactionId = (typeof FACTIONS)[keyof typeof FACTIONS] | 'Neutral'
export type WeatherType = (typeof WEATHER)[keyof typeof WEATHER]

export type UnitAbility =
  | typeof ABILITIES.HERO
  | typeof ABILITIES.INFILTRATOR
  | typeof ABILITIES.MEDIC
  | typeof ABILITIES.FORMATION
  | typeof ABILITIES.RALLY
  | typeof ABILITIES.MORALE_BOOST
  | typeof ABILITIES.AGILE
  | typeof ABILITIES.ROW_SCORCH
  | typeof ABILITIES.WAR_CRY

export type SelectionMode = 'default' | 'medic' | 'decoy' | 'agile' | 'mulligan'

export interface UnitCard {
  id: string
  type: 'unit'
  name: string
  faction: FactionId
  row: RowType
  baseStrength: number
  ability: UnitAbility | null
  isHero: boolean
  rallyGroup: string | null
}

export interface SpecialCard {
  id: string
  type: 'special'
  name: string
  ability: typeof ABILITIES.SCORCH | typeof ABILITIES.WAR_CRY | typeof ABILITIES.DECOY
}

export interface WeatherCard {
  id: string
  type: 'weather'
  name: string
  weatherType: WeatherType
}

export type Card = UnitCard | SpecialCard | WeatherCard

export interface PlayerRow {
  melee: UnitCard[]
  ranged: UnitCard[]
  siege: UnitCard[]
}

export interface PlayerState {
  hand: Card[]
  deck: Card[]
  discard: Card[]
  board: PlayerRow
  gems: number
  passed: boolean
  leaderAbilityUsed: boolean
}

export interface GameState {
  players: [PlayerState, PlayerState]
  weatherZone: WeatherCard[]
  round: number
  activePlayer: 0 | 1
  selectionMode: SelectionMode
}
