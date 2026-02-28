import { FACTIONS, LEADERS } from '@/lib/terminology'
import type { LeaderId, PlayerFaction } from '@/types/game'

export interface LeaderInfo {
  id: LeaderId
  abilityDescription: string
}

export interface FactionInfo {
  id: PlayerFaction
  abilityDescription: string
  leaders: LeaderInfo[]
}

export const FACTION_DATA: FactionInfo[] = [
  {
    id: FACTIONS.A,
    abilityDescription: 'Draw 1 card from your deck when you win a round.',
    leaders: [
      { id: LEADERS.A1, abilityDescription: 'Play Shroud from your deck.' },
      { id: LEADERS.A2, abilityDescription: 'Clear all active weather effects.' },
      {
        id: LEADERS.A3,
        abilityDescription:
          "Destroy the opponent's strongest Ranged units if that row total is 10 or more.",
      },
      {
        id: LEADERS.A4,
        abilityDescription:
          'Double the strength of your Siege row. No effect if a War Cry is already present.',
      },
      {
        id: LEADERS.A5,
        abilityDescription:
          "Destroy the opponent's strongest Siege units if that row total is 10 or more.",
      },
    ],
  },
  {
    id: FACTIONS.B,
    abilityDescription: 'Win rounds that end in a draw. Your opponent still loses a gem.',
    leaders: [
      {
        id: LEADERS.B1,
        abilityDescription:
          "Look at 3 random cards from the opponent's hand. They are not notified.",
      },
      { id: LEADERS.B2, abilityDescription: 'Play Deluge from your deck.' },
      {
        id: LEADERS.B3,
        abilityDescription:
          'For the rest of the match, all card-restoration effects restore a randomly-chosen card. Affects both players.',
      },
      { id: LEADERS.B4, abilityDescription: "Draw a card from the opponent's discard pile." },
      {
        id: LEADERS.B5,
        abilityDescription: "Cancel the opponent's leader ability before they use it.",
      },
    ],
  },
  {
    id: FACTIONS.C,
    abilityDescription: 'Choose who goes first in the opening round.',
    leaders: [
      { id: LEADERS.C1, abilityDescription: 'Draw 1 extra card at the start of the match.' },
      {
        id: LEADERS.C2,
        abilityDescription:
          'Move all your Agile units on the board to whichever valid row maximises their strength.',
      },
      { id: LEADERS.C3, abilityDescription: 'Play Blizzard from your deck.' },
      {
        id: LEADERS.C4,
        abilityDescription:
          "Destroy the opponent's strongest Melee units if that row total is 10 or more.",
      },
      {
        id: LEADERS.C5,
        abilityDescription:
          'Double the strength of your Ranged row. No effect if a War Cry is already present.',
      },
    ],
  },
  {
    id: FACTIONS.D,
    abilityDescription: 'One random unit stays on the board after each round ends.',
    leaders: [
      {
        id: LEADERS.D1,
        abilityDescription:
          'Double the strength of all Infiltrator cards on the board. Affects both sides.',
      },
      { id: LEADERS.D2, abilityDescription: 'Restore a card from your discard pile to your hand.' },
      {
        id: LEADERS.D3,
        abilityDescription:
          'Double the strength of your Melee row. No effect if a War Cry is already present.',
      },
      {
        id: LEADERS.D4,
        abilityDescription:
          'Discard 2 cards from your hand, then draw 1 card of your choice from your deck.',
      },
      { id: LEADERS.D5, abilityDescription: 'Play any weather card from your deck.' },
    ],
  },
]
