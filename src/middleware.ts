import { createServerClient } from '@supabase/ssr'
import { NextResponse, type NextRequest } from 'next/server'

export async function middleware(request: NextRequest) {
  let supabaseResponse = NextResponse.next({ request })

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY!,
    {
      cookies: {
        getAll() {
          return request.cookies.getAll()
        },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value }) => request.cookies.set(name, value))
          supabaseResponse = NextResponse.next({ request })
          cookiesToSet.forEach(({ name, value, options }) =>
            supabaseResponse.cookies.set(name, value, options),
          )
        },
      },
    },
  )

  const {
    data: { user },
  } = await supabase.auth.getUser()

  const { pathname } = request.nextUrl
  const isAuthRoute = pathname === '/login' || pathname === '/register'
  const isPublicRoute = pathname === '/' || isAuthRoute
  // Protect /stats, /lobby (exact), and /lobby/<id> (invite waiting room only).
  // /lobby/<id>/select and deeper are accessible to all authenticated users (quick match).
  const needsRegistered =
    pathname === '/stats' || pathname === '/lobby' || /^\/lobby\/[^/]+$/.test(pathname)
  const isAnonymous = user ? (user.is_anonymous ?? false) : false

  // No session at all: send to home (name entry) unless already on a public route.
  if (!user && !isPublicRoute) {
    const url = request.nextUrl.clone()
    url.pathname = '/'
    return NextResponse.redirect(url)
  }

  // Has a session but route requires a registered account: send to register.
  if (user && needsRegistered && isAnonymous) {
    const url = request.nextUrl.clone()
    url.pathname = '/register'
    return NextResponse.redirect(url)
  }

  // Registered user hitting login/register: send home.
  if (user && isAuthRoute && !isAnonymous) {
    const url = request.nextUrl.clone()
    url.pathname = '/'
    return NextResponse.redirect(url)
  }

  return supabaseResponse
}

export const config = {
  matcher: ['/((?!_next/static|_next/image|favicon\\.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)'],
}
