// Run with: npx tsx src/game/cli.ts  OR  npm run cli
import * as readline from 'readline'

import { FACTIONS, ROWS } from '@/lib/terminology'
import type { Card, GameState, PlayerFaction, PlayerState, RowState, RowType } from '@/types/game'

import {
  FACTION_A_CARDS,
  FACTION_B_CARDS,
  NEUTRAL_SPECIAL_CARDS,
  NEUTRAL_UNIT_CARDS,
  NEUTRAL_WEATHER_CARDS,
} from './cards'
import { computeStrength } from './computeStrength'
import {
  completeSelection,
  computeBoardScore,
  confirmMulligan,
  endRound,
  getMatchResult,
  initMatch,
  isMatchOver,
  isRoundOver,
  pass,
  performMulligan,
  playCard,
} from './stateMachine'

// ---- Setup helpers ----

function shuffle<T>(arr: T[], rng: () => number): T[] {
  const a = [...arr]
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(rng() * (i + 1))
    ;[a[i], a[j]] = [a[j], a[i]]
  }
  return a
}

function makePlayer(faction: PlayerFaction, deckCards: Card[], rng: () => number): PlayerState {
  return {
    faction,
    hand: [],
    deck: shuffle(deckCards, rng),
    discard: [],
    board: {
      melee: { type: ROWS.MELEE, cards: [], warCry: false },
      ranged: { type: ROWS.RANGED, cards: [], warCry: false },
      siege: { type: ROWS.SIEGE, cards: [], warCry: false },
    },
    gems: 2,
    passed: false,
    leaderAbilityUsed: false,
  }
}

// ---- Display helpers ----

function printRow(label: string, row: RowState, state: GameState): void {
  const wc = row.warCry ? ' [WAR CRY]' : ''
  const cards = row.cards.map((c) => `${c.id}[${computeStrength(c.id, row, state)}]`).join(' ')
  console.log(`    ${label}${wc}: ${cards || '(empty)'}`)
}

function printState(state: GameState): void {
  const bar = '─'.repeat(60)
  console.log(`\n${bar}`)
  console.log(
    `Round ${state.round}  |  Mode: ${state.selectionMode}  |  Active: P${state.activePlayer}`,
  )
  console.log(
    `Wins: P0=${state.roundWins[0]} P1=${state.roundWins[1]}  |  Weather: ${
      state.weatherZone.map((w) => w.weatherType).join(', ') || 'none'
    }`,
  )

  // Print P1 at top (opponent), P0 at bottom (self)
  for (const pi of [1, 0] as const) {
    const p = state.players[pi]
    const score = computeBoardScore(state, pi)
    const tags = [p.passed ? 'PASSED' : '', state.activePlayer === pi ? 'ACTIVE' : '']
      .filter(Boolean)
      .join(' | ')
    console.log(
      `\n  P${pi} — ${p.faction}  Gems: ${'◆'.repeat(p.gems)}${'◇'.repeat(2 - p.gems)}  Score: ${score}${tags ? `  [${tags}]` : ''}`,
    )
    printRow('Siege ', p.board.siege, state)
    printRow('Ranged', p.board.ranged, state)
    printRow('Melee ', p.board.melee, state)
    console.log(`    Hand (${p.hand.length}): ${p.hand.map((c) => c.id).join('  ') || '(empty)'}`)
    console.log(`    Deck: ${p.deck.length}  Discard: ${p.discard.length}`)
  }

  if (state.selectionMode === 'medic' || state.selectionMode === 'decoy') {
    console.log(`\n  Choose from: ${state.pendingOptions.map((c) => c.id).join('  ')}`)
  }

  console.log(bar)
}

function printHelp(mode: string): void {
  const cmds: Record<string, string[]> = {
    default: ['play <id>', 'pass', 'state', 'help'],
    mulligan: ['mulligan <id>', 'confirm', 'state', 'help'],
    medic: ['select <id>', 'state', 'help'],
    decoy: ['select <id>', 'state', 'help'],
    agile: ['row <melee|ranged>', 'state', 'help'],
    warCry: ['row <melee|ranged|siege>', 'state', 'help'],
  }
  const list = cmds[mode] ?? cmds['default']
  console.log(`  Commands: ${list.join('  |  ')}`)
}

// ---- Main ----

async function main(): Promise<void> {
  const rng = Math.random.bind(Math)
  const neutrals: Card[] = [
    ...NEUTRAL_UNIT_CARDS,
    ...NEUTRAL_WEATHER_CARDS,
    ...NEUTRAL_SPECIAL_CARDS,
  ]

  const p0 = makePlayer(FACTIONS.A, [...FACTION_A_CARDS, ...neutrals], rng)
  const p1 = makePlayer(FACTIONS.B, [...FACTION_B_CARDS, ...neutrals], rng)
  let state = initMatch(p0, p1, rng)

  console.log('=== Card Game CLI ===')
  console.log('P0: Faction A  |  P1: Faction B')
  console.log('Card ids shown on board as: id[computedStrength]')
  printState(state)
  printHelp(state.selectionMode)

  const rl = readline.createInterface({ input: process.stdin, output: process.stdout })

  // During mulligan, P0 goes first regardless of activePlayer, then P1.
  function mulliganPlayer(): 0 | 1 {
    return state.mulligansConfirmed[0] ? 1 : 0
  }

  function promptPlayer(): 0 | 1 {
    return state.selectionMode === 'mulligan' ? mulliganPlayer() : state.activePlayer
  }

  function prompt(): void {
    const pi = promptPlayer()
    rl.question(`P${pi}> `, (line) => {
      const parts = line.trim().split(/\s+/)
      const cmd = parts[0]?.toLowerCase() ?? ''

      if (!cmd) {
        prompt()
        return
      }

      if (cmd === 'help') {
        printHelp(state.selectionMode)
        prompt()
        return
      }

      if (cmd === 'state') {
        printState(state)
        prompt()
        return
      }

      const prev = state

      if (state.selectionMode === 'default') {
        if (cmd === 'play' && parts[1]) {
          state = playCard(state, parts[1], state.activePlayer, rng)
          if (state === prev) console.log('  Invalid move — card not in hand or not your turn.')
        } else if (cmd === 'pass') {
          state = pass(state, state.activePlayer)
        } else {
          printHelp('default')
          prompt()
          return
        }
      } else if (state.selectionMode === 'mulligan') {
        if (cmd === 'mulligan' && parts[1]) {
          state = performMulligan(state, parts[1], pi)
          if (state === prev)
            console.log('  Cannot mulligan that card (already swapped or not in hand).')
        } else if (cmd === 'confirm') {
          state = confirmMulligan(state, pi)
        } else {
          printHelp('mulligan')
          prompt()
          return
        }
      } else if (state.selectionMode === 'medic') {
        if (cmd === 'select' && parts[1]) {
          state = completeSelection(
            state,
            { mode: 'medic', selectedCardId: parts[1] },
            state.activePlayer,
            rng,
          )
          if (state === prev) console.log('  Card not available in discard.')
        } else {
          printHelp('medic')
          prompt()
          return
        }
      } else if (state.selectionMode === 'decoy') {
        if (cmd === 'select' && parts[1]) {
          state = completeSelection(
            state,
            { mode: 'decoy', selectedCardId: parts[1] },
            state.activePlayer,
            rng,
          )
          if (state === prev) console.log('  Cannot target that card.')
        } else {
          printHelp('decoy')
          prompt()
          return
        }
      } else if (state.selectionMode === 'agile') {
        if (cmd === 'row' && parts[1]) {
          const rowMap: Record<string, RowType> = { melee: ROWS.MELEE, ranged: ROWS.RANGED }
          const row = rowMap[parts[1].toLowerCase()]
          if (row) {
            state = completeSelection(state, { mode: 'agile', row }, state.activePlayer, rng)
          } else {
            console.log('  Invalid row. Use: melee | ranged')
            prompt()
            return
          }
        } else {
          printHelp('agile')
          prompt()
          return
        }
      } else if (state.selectionMode === 'warCry') {
        if (cmd === 'row' && parts[1]) {
          const rowMap: Record<string, RowType> = {
            melee: ROWS.MELEE,
            ranged: ROWS.RANGED,
            siege: ROWS.SIEGE,
          }
          const row = rowMap[parts[1].toLowerCase()]
          if (row) {
            state = completeSelection(state, { mode: 'warCry', row }, state.activePlayer, rng)
          } else {
            console.log('  Invalid row. Use: melee | ranged | siege')
            prompt()
            return
          }
        } else {
          printHelp('warCry')
          prompt()
          return
        }
      }

      if (state !== prev) {
        printState(state)
      }

      // Auto-resolve round end
      if (state.selectionMode === 'default' && isRoundOver(state)) {
        const s0 = computeBoardScore(state, 0)
        const s1 = computeBoardScore(state, 1)
        console.log(`\n*** Round over! P0: ${s0}  P1: ${s1} ***`)
        state = endRound(state, rng)
        printState(state)
      }

      // Check match end
      if (isMatchOver(state)) {
        const result = getMatchResult(state)
        if (result?.winner !== null && result?.winner !== undefined) {
          console.log(`\n*** Match over — P${result.winner} wins! ***`)
        } else {
          console.log('\n*** Match over — Draw! ***')
        }
        rl.close()
        return
      }

      printHelp(state.selectionMode)
      prompt()
    })
  }

  prompt()
}

main().catch((err) => {
  console.error(err)
  process.exit(1)
})
