'use client'

import { useState } from 'react'
import { FACTION_DATA } from '@/game/factionData'
import type { FactionInfo } from '@/game/factionData'
import type { LeaderId, PlayerFaction } from '@/types/game'

export interface FactionSelection {
  playerFaction: PlayerFaction
  playerLeader: LeaderId
  aiFaction: PlayerFaction
  aiLeader: LeaderId
}

interface FactionSelectProps {
  onConfirm: (selection: FactionSelection) => void
}

function pickRandom<T>(items: T[]): T {
  return items[Math.floor(Math.random() * items.length)]
}

function FactionStep({
  selected,
  onSelect,
}: {
  selected: PlayerFaction | null
  onSelect: (id: PlayerFaction) => void
}) {
  return (
    <div>
      <h1 className="text-xl font-bold text-gray-900 mb-4">Choose your faction</h1>
      <div className="grid grid-cols-2 gap-3">
        {FACTION_DATA.map((f) => (
          <button
            key={f.id}
            onClick={() => onSelect(f.id)}
            className={[
              'text-left p-4 rounded-lg border-2 transition-colors',
              selected === f.id
                ? 'border-blue-500 bg-blue-50'
                : 'border-gray-200 bg-white hover:border-gray-300',
            ].join(' ')}
          >
            <div className="font-semibold text-sm text-gray-900">{f.id}</div>
            <div className="text-xs text-gray-500 mt-1 leading-relaxed">{f.abilityDescription}</div>
          </button>
        ))}
      </div>
    </div>
  )
}

function LeaderStep({
  factionData,
  selected,
  onSelect,
}: {
  factionData: FactionInfo
  selected: LeaderId | null
  onSelect: (id: LeaderId) => void
}) {
  return (
    <div>
      <h2 className="text-lg font-semibold text-gray-800 mb-3">Choose your leader</h2>
      <div className="flex flex-col gap-2">
        {factionData.leaders.map((l) => (
          <button
            key={l.id}
            onClick={() => onSelect(l.id)}
            className={[
              'text-left p-3 rounded-lg border-2 transition-colors',
              selected === l.id
                ? 'border-blue-500 bg-blue-50'
                : 'border-gray-200 bg-white hover:border-gray-300',
            ].join(' ')}
          >
            <div className="font-medium text-sm text-gray-900">{l.id}</div>
            <div className="text-xs text-gray-500 mt-0.5 leading-relaxed">
              {l.abilityDescription}
            </div>
          </button>
        ))}
      </div>
    </div>
  )
}

export function FactionSelect({ onConfirm }: FactionSelectProps) {
  const [selectedFaction, setSelectedFaction] = useState<PlayerFaction | null>(null)
  const [selectedLeader, setSelectedLeader] = useState<LeaderId | null>(null)

  const factionData = FACTION_DATA.find((f) => f.id === selectedFaction) ?? null

  function handleFactionClick(id: PlayerFaction) {
    setSelectedFaction(id)
    setSelectedLeader(null)
  }

  function handleConfirm() {
    if (!selectedFaction || !selectedLeader) return

    const aiFactionData = pickRandom(FACTION_DATA)
    const aiLeaderData = pickRandom(aiFactionData.leaders)

    onConfirm({
      playerFaction: selectedFaction,
      playerLeader: selectedLeader,
      aiFaction: aiFactionData.id,
      aiLeader: aiLeaderData.id,
    })
  }

  return (
    <div className="flex flex-col items-center justify-start min-h-screen bg-gray-50 p-6">
      <div className="w-full max-w-2xl space-y-8">
        <FactionStep selected={selectedFaction} onSelect={handleFactionClick} />

        {factionData && (
          <LeaderStep
            factionData={factionData}
            selected={selectedLeader}
            onSelect={setSelectedLeader}
          />
        )}

        {selectedFaction && selectedLeader && (
          <div className="flex justify-end">
            <button
              onClick={handleConfirm}
              className="px-6 py-2.5 rounded-lg bg-green-600 text-white text-sm font-semibold hover:bg-green-700 transition-colors"
            >
              Start match
            </button>
          </div>
        )}
      </div>
    </div>
  )
}
