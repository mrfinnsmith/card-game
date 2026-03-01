export type LobbyStatus =
  | 'waiting'
  | 'ready'
  | 'selecting'
  | 'in_progress'
  | 'completed'
  | 'expired'

export interface Lobby {
  id: string
  join_code: string | null
  host_id: string
  guest_id: string | null
  host_ready: boolean
  guest_ready: boolean
  status: LobbyStatus
  created_at: string
}
