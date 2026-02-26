import type { Metadata } from 'next'
import { GameStoreProvider } from '@/store/gameStore'
import './globals.css'

export const metadata: Metadata = {
  title: 'Card Game',
  description: 'A browser-based card game',
}

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        <GameStoreProvider>{children}</GameStoreProvider>
      </body>
    </html>
  )
}
