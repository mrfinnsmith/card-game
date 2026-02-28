'use client'

import { createContext, useContext, useRef } from 'react'
import { createStore, useStore } from 'zustand'
import { FACTIONS, ROWS } from '@/lib/terminology'
import type { GameState, PlayerState } from '@/types/game'

type GameStore = ReturnType<typeof createGameStore>

function createPlayerState(faction = FACTIONS.A): PlayerState {
  return {
    faction,
    hand: [],
    deck: [],
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

const initialState: GameState = {
  players: [createPlayerState(), createPlayerState()],
  weatherZone: [],
  round: 1,
  activePlayer: 0,
  selectionMode: 'default',
  pendingOptions: [],
  randomRestoration: false,
  leaderD1Active: false,
  mulligansUsed: [0, 0],
  mulliganedCardIds: [[], []],
  mulligansConfirmed: [false, false],
  roundWins: [0, 0],
}

function createGameStore() {
  return createStore<GameState>()(() => ({ ...initialState }))
}

const GameStoreContext = createContext<GameStore | null>(null)

export function GameStoreProvider({ children }: { children: React.ReactNode }) {
  const storeRef = useRef<GameStore>(undefined)
  if (!storeRef.current) {
    storeRef.current = createGameStore()
  }
  return <GameStoreContext.Provider value={storeRef.current}>{children}</GameStoreContext.Provider>
}

export function useGameStore<T>(selector: (state: GameState) => T): T {
  const store = useContext(GameStoreContext)
  if (!store) throw new Error('useGameStore must be used within a GameStoreProvider')
  return useStore(store, selector)
}
