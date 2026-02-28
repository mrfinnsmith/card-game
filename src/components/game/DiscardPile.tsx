'use client'

import { useState } from 'react'
import { useGameStore } from '@/store/gameStore'
import type { Card } from '@/types/game'

function DiscardCard({ card }: { card: Card }) {
  const unit = card.type === 'unit' ? card : null

  return (
    <div
      className={[
        'flex flex-col items-center justify-center rounded border w-14 h-20 shrink-0',
        unit?.isHero
          ? 'bg-yellow-50 border-yellow-400'
          : card.type === 'special'
            ? 'bg-purple-50 border-purple-300'
            : card.type === 'weather'
              ? 'bg-sky-50 border-sky-300'
              : 'bg-white border-gray-300',
      ].join(' ')}
    >
      {unit && <span className="text-sm font-bold text-gray-800">{unit.baseStrength}</span>}
      {unit?.isHero && <span className="text-[10px] text-yellow-500 leading-none">★</span>}
      <span className="text-[9px] text-gray-500 leading-tight px-0.5 text-center w-full truncate">
        {card.name}
      </span>
      {unit?.ability && (
        <span className="text-[9px] text-gray-400 leading-none">{unit.ability.slice(0, 3)}</span>
      )}
    </div>
  )
}

export function DiscardPile({ playerIndex }: { playerIndex: 0 | 1 }) {
  const [open, setOpen] = useState(false)
  const discard = useGameStore((s) => s.players[playerIndex].discard)
  const label = playerIndex === 0 ? 'Your' : "Opponent's"

  return (
    <>
      <button
        onClick={() => setOpen(true)}
        className="flex flex-col items-center justify-center w-10 h-14 rounded border border-gray-300 bg-gray-50 hover:bg-gray-100 transition-colors shrink-0"
        aria-label={`${label} discard pile, ${discard.length} card${discard.length !== 1 ? 's' : ''}`}
      >
        <span className="text-xs font-semibold text-gray-600">{discard.length}</span>
        <span className="text-[9px] text-gray-400 leading-none">Disc</span>
      </button>

      {open && (
        <div
          className="fixed inset-0 z-50 flex items-center justify-center bg-black/40"
          onClick={() => setOpen(false)}
        >
          <div
            className="bg-white rounded-lg border border-gray-200 shadow-lg w-full max-w-md mx-4 max-h-[70vh] flex flex-col"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="flex items-center justify-between px-4 py-3 border-b border-gray-200">
              <h2 className="text-sm font-semibold text-gray-800">
                {label} Discard Pile ({discard.length})
              </h2>
              <button
                onClick={() => setOpen(false)}
                className="text-gray-400 hover:text-gray-600 text-xl leading-none"
                aria-label="Close"
              >
                ×
              </button>
            </div>
            <div className="flex-1 overflow-y-auto p-4">
              {discard.length === 0 ? (
                <p className="text-sm text-gray-400 italic text-center py-6">Empty</p>
              ) : (
                <div className="flex flex-wrap gap-2">
                  {discard.map((card) => (
                    <DiscardCard key={card.id} card={card} />
                  ))}
                </div>
              )}
            </div>
          </div>
        </div>
      )}
    </>
  )
}
