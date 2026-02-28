'use client'

import { ROWS, WEATHER } from '@/lib/terminology'
import { computeStrength } from '@/game/computeStrength'
import { computeBoardScore } from '@/game/stateMachine'
import { useGameStore } from '@/store/gameStore'
import type { GameState, RowState, UnitCard, WeatherCard } from '@/types/game'

// ---- helpers ----

const WEATHER_FOR_ROW: Record<string, string> = {
  [ROWS.MELEE]: WEATHER.BLIZZARD,
  [ROWS.RANGED]: WEATHER.SHROUD,
  [ROWS.SIEGE]: WEATHER.DELUGE,
}

function rowTotal(row: RowState, state: GameState): number {
  return row.cards.reduce((sum, card) => sum + computeStrength(card.id, row, state), 0)
}

function weatherActiveForRow(row: RowState, weatherZone: WeatherCard[]): boolean {
  return weatherZone.some((w) => w.weatherType === WEATHER_FOR_ROW[row.type])
}

// ---- sub-components ----

function BoardCard({ card, row, state }: { card: UnitCard; row: RowState; state: GameState }) {
  const str = computeStrength(card.id, row, state)
  const boosted = str > card.baseStrength
  const reduced = str < card.baseStrength

  return (
    <div
      className={`flex flex-col items-center justify-center rounded border w-12 h-16 shrink-0
        ${card.isHero ? 'bg-yellow-50 border-yellow-400' : 'bg-white border-gray-300'}`}
    >
      <span
        className={`text-sm font-bold
          ${boosted ? 'text-green-600' : reduced ? 'text-blue-500' : 'text-gray-800'}`}
      >
        {str}
      </span>
      {card.ability && (
        <span className="text-[10px] text-gray-400 leading-none px-0.5 truncate w-full text-center">
          {card.ability.slice(0, 3)}
        </span>
      )}
      {card.isHero && <span className="text-[10px] text-yellow-500">★</span>}
    </div>
  )
}

function BoardRow({ row, state }: { row: RowState; state: GameState }) {
  const total = rowTotal(row, state)
  const weatherOn = weatherActiveForRow(row, state.weatherZone)

  return (
    <div className="flex items-stretch gap-2 px-3 py-1 min-h-[80px] border-b border-gray-200">
      <div className="flex flex-col items-center justify-center w-16 shrink-0 gap-0.5">
        <span className="text-[10px] font-semibold text-gray-400 uppercase tracking-wider">
          {row.type}
        </span>
        <span className={`text-lg font-bold ${weatherOn ? 'text-blue-500' : 'text-gray-800'}`}>
          {total}
        </span>
        {weatherOn && <span className="text-[10px] text-blue-400 leading-none">weather</span>}
        {row.warCry && (
          <span className="text-[10px] text-orange-500 font-semibold leading-none">x2</span>
        )}
      </div>
      <div className="w-px bg-gray-200 shrink-0" />
      <div className="flex-1 flex items-center gap-1 overflow-x-auto py-1">
        {row.cards.map((card) => (
          <BoardCard key={card.id} card={card} row={row} state={state} />
        ))}
      </div>
    </div>
  )
}

function WeatherZone({ weatherZone }: { weatherZone: WeatherCard[] }) {
  return (
    <div className="flex items-center gap-3 px-3 py-2 bg-sky-50 border-y border-sky-200 min-h-[44px]">
      <span className="text-[10px] font-semibold text-sky-500 uppercase tracking-wider shrink-0">
        Weather
      </span>
      <div className="flex gap-1.5 overflow-x-auto">
        {weatherZone.length === 0 ? (
          <span className="text-xs text-gray-400 italic">clear</span>
        ) : (
          weatherZone.map((w) => (
            <span
              key={w.id}
              className="px-2 py-0.5 rounded-full bg-sky-100 text-sky-700 text-xs font-medium border border-sky-200 whitespace-nowrap"
            >
              {w.weatherType}
            </span>
          ))
        )}
      </div>
    </div>
  )
}

function GemDisplay({ gems }: { gems: number }) {
  return (
    <div className="flex gap-1" aria-label={`${gems} gem${gems !== 1 ? 's' : ''}`}>
      {[0, 1].map((i) => (
        <div
          key={i}
          className={`w-3.5 h-3.5 rounded-full border-2 ${
            i < gems ? 'bg-amber-400 border-amber-500' : 'bg-gray-100 border-gray-300'
          }`}
        />
      ))}
    </div>
  )
}

function PlayerInfo({
  playerIndex,
  state,
  flipped,
}: {
  playerIndex: 0 | 1
  state: GameState
  flipped?: boolean
}) {
  const player = state.players[playerIndex]
  const score = computeBoardScore(state, playerIndex)
  const isActive = state.activePlayer === playerIndex && state.selectionMode !== 'mulligan'

  return (
    <div
      className={`flex items-center justify-between px-4 py-2 border-gray-200
        ${flipped ? 'border-b bg-gray-100' : 'border-t bg-gray-50'}`}
    >
      <div className="flex items-center gap-3">
        <GemDisplay gems={player.gems} />
        <span className="text-sm text-gray-600">{player.faction}</span>
        {player.passed && <span className="text-xs text-red-500 font-medium">Passed</span>}
        {isActive && !player.passed && (
          <span className="text-xs text-green-600 font-medium">Active</span>
        )}
      </div>
      <div className="flex items-center gap-3">
        <span className="text-xs text-gray-400">Hand: {player.hand.length}</span>
        <span className="text-xl font-bold text-gray-800 tabular-nums">{score}</span>
      </div>
    </div>
  )
}

// ---- main component ----

export function Board() {
  const state = useGameStore((s) => s)
  const opponent = state.players[1]
  const player = state.players[0]

  return (
    <div className="flex flex-col w-full bg-white rounded-lg border border-gray-200 overflow-hidden">
      <PlayerInfo playerIndex={1} state={state} flipped />

      {/* Opponent rows: Siege, Ranged, Melee (top to bottom) */}
      <BoardRow row={opponent.board.siege} state={state} />
      <BoardRow row={opponent.board.ranged} state={state} />
      <BoardRow row={opponent.board.melee} state={state} />

      <WeatherZone weatherZone={state.weatherZone} />

      {/* Player rows: Melee, Ranged, Siege (top to bottom) */}
      <BoardRow row={player.board.melee} state={state} />
      <BoardRow row={player.board.ranged} state={state} />
      <BoardRow row={player.board.siege} state={state} />

      <PlayerInfo playerIndex={0} state={state} />
    </div>
  )
}
