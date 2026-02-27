import type { Card, GameState, PlayerRow, PlayerState, UnitCard } from '@/types/game'

function collectBoardUnits(board: PlayerRow): UnitCard[] {
  return [...board.melee.cards, ...board.ranged.cards, ...board.siege.cards]
}

function removeFromBoard(board: PlayerRow, cardId: string): PlayerRow {
  return {
    melee: { ...board.melee, cards: board.melee.cards.filter((c) => c.id !== cardId) },
    ranged: { ...board.ranged, cards: board.ranged.cards.filter((c) => c.id !== cardId) },
    siege: { ...board.siege, cards: board.siege.cards.filter((c) => c.id !== cardId) },
  }
}

export function resolveDecoy(state: GameState, cardId: string, playerIndex: 0 | 1): GameState {
  const player = state.players[playerIndex]
  const card = player.hand.find((c) => c.id === cardId)
  if (!card) return state

  const hand = player.hand.filter((c) => c.id !== cardId)
  const discard: Card[] = [...player.discard, card]
  const updatedPlayer: PlayerState = { ...player, hand, discard }
  const players: [PlayerState, PlayerState] =
    playerIndex === 0 ? [updatedPlayer, state.players[1]] : [state.players[0], updatedPlayer]

  const partialState: GameState = { ...state, players }
  const opponentIndex: 0 | 1 = playerIndex === 0 ? 1 : 0
  const allTargets = [
    ...collectBoardUnits(partialState.players[playerIndex].board),
    ...collectBoardUnits(partialState.players[opponentIndex].board),
  ].filter((c) => !c.isHero)

  return { ...partialState, selectionMode: 'decoy', pendingOptions: allTargets }
}

export function completeDecoySelection(
  state: GameState,
  selectedCardId: string,
  playerIndex: 0 | 1,
): GameState {
  const opponentIndex: 0 | 1 = playerIndex === 0 ? 1 : 0
  const player = state.players[playerIndex]
  const opponent = state.players[opponentIndex]

  const cardOnOwn = collectBoardUnits(player.board).find((c) => c.id === selectedCardId)
  if (cardOnOwn) {
    const board = removeFromBoard(player.board, selectedCardId)
    const hand = [...player.hand, cardOnOwn]
    const updatedPlayer: PlayerState = { ...player, board, hand }
    const players: [PlayerState, PlayerState] =
      playerIndex === 0 ? [updatedPlayer, opponent] : [opponent, updatedPlayer]
    return { ...state, players, selectionMode: 'default', pendingOptions: [] }
  }

  const cardOnOpponent = collectBoardUnits(opponent.board).find((c) => c.id === selectedCardId)
  if (!cardOnOpponent) return state

  const opponentBoard = removeFromBoard(opponent.board, selectedCardId)
  const hand = [...player.hand, cardOnOpponent]
  const updatedPlayer: PlayerState = { ...player, hand }
  const updatedOpponent: PlayerState = { ...opponent, board: opponentBoard }
  const players: [PlayerState, PlayerState] =
    playerIndex === 0 ? [updatedPlayer, updatedOpponent] : [updatedOpponent, updatedPlayer]

  return { ...state, players, selectionMode: 'default', pendingOptions: [] }
}
