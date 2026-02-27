import { ROWS } from '@/lib/terminology'
import type { PlayerRow } from '@/types/game'

export const ROW_KEY: Record<string, keyof PlayerRow> = {
  [ROWS.MELEE]: 'melee',
  [ROWS.RANGED]: 'ranged',
  [ROWS.SIEGE]: 'siege',
}
