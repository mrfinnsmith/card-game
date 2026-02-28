'use client'

import { useGameStore } from '@/store/gameStore'
import { ROWS } from '@/lib/terminology'
import type { Card, RowType, UnitCard } from '@/types/game'

// ---- Props ----

export interface SelectionOverlayProps {
  onMedicSelect: (cardId: string) => void
  onDecoySelect: (cardId: string) => void
  onAgileSelect: (row: RowType) => void
  onWarCrySelect: (row: RowType) => void
  onMulliganSwap: (cardId: string) => void
  onMulliganConfirm: () => void
}

// ---- Shared subcomponents ----

function SelectableCard({
  card,
  onClick,
  disabled,
}: {
  card: Card
  onClick?: () => void
  disabled?: boolean
}) {
  const unit = card.type === 'unit' ? (card as UnitCard) : null
  const interactive = !!onClick && !disabled

  return (
    <button
      onClick={onClick}
      disabled={!interactive}
      className={[
        'flex flex-col items-center justify-center rounded border w-14 h-20 shrink-0 select-none transition-transform',
        interactive
          ? 'cursor-pointer hover:-translate-y-1.5 hover:shadow-md active:translate-y-0 ring-2 ring-blue-400'
          : 'cursor-default opacity-50',
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

function Panel({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center pb-4 bg-black/50">
      <div className="bg-white rounded-lg border border-gray-200 shadow-xl w-full max-w-2xl mx-4 max-h-[60vh] flex flex-col">
        <div className="px-4 py-3 border-b border-gray-200 shrink-0">
          <h2 className="text-sm font-semibold text-gray-800">{title}</h2>
        </div>
        <div className="flex-1 overflow-y-auto p-4">{children}</div>
      </div>
    </div>
  )
}

// ---- Mode panels ----

function MedicPanel({
  options,
  onSelect,
}: {
  options: UnitCard[]
  onSelect: (id: string) => void
}) {
  return (
    <Panel title="Medic: restore a unit from your discard">
      <div className="flex flex-wrap gap-2">
        {options.map((card) => (
          <SelectableCard key={card.id} card={card} onClick={() => onSelect(card.id)} />
        ))}
      </div>
    </Panel>
  )
}

function DecoyPanel({
  options,
  ownIds,
  onSelect,
}: {
  options: UnitCard[]
  ownIds: Set<string>
  onSelect: (id: string) => void
}) {
  const own = options.filter((c) => ownIds.has(c.id))
  const opp = options.filter((c) => !ownIds.has(c.id))

  return (
    <Panel title="Decoy: select a unit to return to hand">
      <div className="flex flex-col gap-4">
        {own.length > 0 && (
          <div>
            <p className="text-xs font-medium text-gray-500 mb-2 uppercase tracking-wide">
              Your board
            </p>
            <div className="flex flex-wrap gap-2">
              {own.map((card) => (
                <SelectableCard key={card.id} card={card} onClick={() => onSelect(card.id)} />
              ))}
            </div>
          </div>
        )}
        {opp.length > 0 && (
          <div>
            <p className="text-xs font-medium text-gray-500 mb-2 uppercase tracking-wide">
              {"Opponent's board"}
            </p>
            <div className="flex flex-wrap gap-2">
              {opp.map((card) => (
                <SelectableCard key={card.id} card={card} onClick={() => onSelect(card.id)} />
              ))}
            </div>
          </div>
        )}
      </div>
    </Panel>
  )
}

const ROW_DISPLAY: Record<string, string> = {
  [ROWS.MELEE]: 'Melee',
  [ROWS.RANGED]: 'Ranged',
  [ROWS.SIEGE]: 'Siege',
}

function RowChoicePanel({
  title,
  rows,
  onSelect,
}: {
  title: string
  rows: RowType[]
  onSelect: (row: RowType) => void
}) {
  return (
    <Panel title={title}>
      <div className="flex gap-3 justify-center py-2">
        {rows.map((row) => (
          <button
            key={row}
            onClick={() => onSelect(row)}
            className="px-8 py-3 rounded-lg border-2 border-blue-400 bg-blue-50 text-blue-700 font-semibold text-sm hover:bg-blue-100 transition-colors"
          >
            {ROW_DISPLAY[row] ?? row}
          </button>
        ))}
      </div>
    </Panel>
  )
}

function MulliganPanel({
  hand,
  mulligansUsed,
  mulliganedCardIds,
  confirmed,
  onSwap,
  onConfirm,
}: {
  hand: Card[]
  mulligansUsed: number
  mulliganedCardIds: string[]
  confirmed: boolean
  onSwap: (cardId: string) => void
  onConfirm: () => void
}) {
  const swapsLeft = 2 - mulligansUsed

  if (confirmed) {
    return (
      <Panel title="Mulligan">
        <p className="text-sm text-gray-500 italic text-center py-4">
          Waiting for opponent to confirm...
        </p>
      </Panel>
    )
  }

  return (
    <Panel title={`Mulligan: ${swapsLeft} swap${swapsLeft !== 1 ? 's' : ''} remaining`}>
      <div className="flex flex-col gap-4">
        <div className="flex flex-wrap gap-2">
          {hand.map((card) => {
            const alreadySwapped = mulliganedCardIds.includes(card.id)
            const canSwap = !alreadySwapped && mulligansUsed < 2
            return (
              <SelectableCard
                key={card.id}
                card={card}
                onClick={canSwap ? () => onSwap(card.id) : undefined}
                disabled={!canSwap}
              />
            )
          })}
        </div>
        <div className="flex justify-end pt-2 border-t border-gray-100">
          <button
            onClick={onConfirm}
            className="px-5 py-2 rounded-lg bg-green-600 text-white font-semibold text-sm hover:bg-green-700 transition-colors"
          >
            Confirm hand
          </button>
        </div>
      </div>
    </Panel>
  )
}

// ---- Main export ----

export function SelectionOverlay({
  onMedicSelect,
  onDecoySelect,
  onAgileSelect,
  onWarCrySelect,
  onMulliganSwap,
  onMulliganConfirm,
}: SelectionOverlayProps) {
  const mode = useGameStore((s) => s.selectionMode)
  const pendingOptions = useGameStore((s) => s.pendingOptions)
  const hand = useGameStore((s) => s.players[0].hand)
  const mulligansUsed = useGameStore((s) => s.mulligansUsed[0])
  const mulliganedCardIds = useGameStore((s) => s.mulliganedCardIds[0])
  const mulliganConfirmed = useGameStore((s) => s.mulligansConfirmed[0])
  const playerBoard = useGameStore((s) => s.players[0].board)

  if (mode === 'default') return null

  const ownIds = new Set([
    ...playerBoard.melee.cards.map((c) => c.id),
    ...playerBoard.ranged.cards.map((c) => c.id),
    ...playerBoard.siege.cards.map((c) => c.id),
  ])

  switch (mode) {
    case 'medic':
      return <MedicPanel options={pendingOptions} onSelect={onMedicSelect} />
    case 'decoy':
      return <DecoyPanel options={pendingOptions} ownIds={ownIds} onSelect={onDecoySelect} />
    case 'agile':
      return (
        <RowChoicePanel
          title="Agile: place in which row?"
          rows={[ROWS.MELEE, ROWS.RANGED]}
          onSelect={onAgileSelect}
        />
      )
    case 'warCry':
      return (
        <RowChoicePanel
          title="War Cry: which row to boost?"
          rows={[ROWS.MELEE, ROWS.RANGED, ROWS.SIEGE]}
          onSelect={onWarCrySelect}
        />
      )
    case 'mulligan':
      return (
        <MulliganPanel
          hand={hand}
          mulligansUsed={mulligansUsed}
          mulliganedCardIds={mulliganedCardIds}
          confirmed={mulliganConfirmed}
          onSwap={onMulliganSwap}
          onConfirm={onMulliganConfirm}
        />
      )
    default:
      return null
  }
}
