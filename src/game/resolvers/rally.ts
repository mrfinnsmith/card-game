import type { GameState, PlayerRow, PlayerState, UnitCard } from '@/types/game'
import { ROW_KEY } from '../rows'

function findOnBoard(board: PlayerRow, cardId: string): UnitCard | undefined {
  return (
    board.melee.cards.find((c) => c.id === cardId) ??
    board.ranged.cards.find((c) => c.id === cardId) ??
    board.siege.cards.find((c) => c.id === cardId)
  )
}

export function resolveRally(state: GameState, cardId: string, playerIndex: 0 | 1): GameState {
  const player = state.players[playerIndex]

  const cardInHand = player.hand.find((c) => c.id === cardId) as UnitCard | undefined

  let card: UnitCard | undefined
  let updatedPlayer: PlayerState

  if (cardInHand) {
    card = cardInHand
    const hand = player.hand.filter((c) => c.id !== cardId)
    const rowKey = ROW_KEY[card.row]
    const board = {
      ...player.board,
      [rowKey]: {
        ...player.board[rowKey],
        cards: [...player.board[rowKey].cards, card],
      },
    }
    updatedPlayer = { ...player, hand, board }
  } else {
    // Called via Medic dispatch — card already placed on board
    card = findOnBoard(player.board, cardId)
    if (!card) return state
    updatedPlayer = player
  }

  if (!card.rallyGroup) {
    const players: [PlayerState, PlayerState] =
      playerIndex === 0 ? [updatedPlayer, state.players[1]] : [state.players[0], updatedPlayer]
    return { ...state, players }
  }

  const { rallyGroup } = card
  const rallyCards = updatedPlayer.deck.filter(
    (c): c is UnitCard => c.type === 'unit' && c.rallyGroup === rallyGroup,
  )
  const rallyIds = new Set(rallyCards.map((c) => c.id))
  const deckAfterRally = updatedPlayer.deck.filter((c) => !rallyIds.has(c.id))

  let board = updatedPlayer.board
  for (const rallied of rallyCards) {
    const rowKey = ROW_KEY[rallied.row]
    board = {
      ...board,
      [rowKey]: {
        ...board[rowKey],
        cards: [...board[rowKey].cards, rallied],
      },
    }
  }

  const finalPlayer: PlayerState = { ...updatedPlayer, deck: deckAfterRally, board }
  const players: [PlayerState, PlayerState] =
    playerIndex === 0 ? [finalPlayer, state.players[1]] : [state.players[0], finalPlayer]

  return { ...state, players }
}
