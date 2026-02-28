'use client'

import { useGameStore } from '@/store/gameStore'
import type { Card } from '@/types/game'

function HandCard({ card, onClick }: { card: Card; onClick?: () => void }) {
  const unit = card.type === 'unit' ? card : null
  const isClickable = Boolean(onClick)

  return (
    <button
      onClick={onClick}
      disabled={!isClickable}
      className={[
        'relative flex flex-col items-center justify-center rounded border w-14 h-20 shrink-0 select-none transition-transform',
        isClickable
          ? 'cursor-pointer hover:-translate-y-1.5 hover:shadow-md active:translate-y-0'
          : 'cursor-default',
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
    </button>
  )
}

export function PlayerHand({ onPlay }: { onPlay?: (cardId: string) => void }) {
  const hand = useGameStore((s) => s.players[0].hand)
  const canAct = useGameStore(
    (s) => s.activePlayer === 0 && s.selectionMode === 'default' && !s.players[0].passed,
  )

  return (
    <div className="flex items-end gap-1.5 px-3 py-2 overflow-x-auto min-h-[96px]">
      {hand.length === 0 ? (
        <span className="text-sm text-gray-400 italic self-center">No cards in hand</span>
      ) : (
        hand.map((card) => (
          <HandCard
            key={card.id}
            card={card}
            onClick={canAct && onPlay ? () => onPlay(card.id) : undefined}
          />
        ))
      )}
    </div>
  )
}

export function OpponentHand() {
  const count = useGameStore((s) => s.players[1].hand.length)

  return (
    <div className="flex items-center gap-1.5 px-3 py-2 overflow-x-auto min-h-[72px]">
      {count === 0 ? (
        <span className="text-sm text-gray-400 italic">No cards</span>
      ) : (
        Array.from({ length: count }, (_, i) => (
          <div
            key={i}
            className="w-10 h-14 rounded border border-gray-300 bg-gray-200 shrink-0"
            aria-hidden="true"
          />
        ))
      )}
      {count > 0 && <span className="text-xs text-gray-500 ml-1 shrink-0">{count}</span>}
    </div>
  )
}
