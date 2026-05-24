import { useState, useEffect } from 'react'
import { type User, onAuthStateChanged, sendSignInLinkToEmail, isSignInWithEmailLink, signInWithEmailLink, signOut } from 'firebase/auth'
import { auth } from '../firebase'

const PENDING_EMAIL_KEY = 'notelayer_pending_email'
const ACTION_CODE_URL = 'https://notelayer-c7bba.firebaseapp.com/emailSignIn'

export function useAuth() {
  const [user, setUser] = useState<User | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const unsub = onAuthStateChanged(auth, (u) => {
      setUser(u)
      setLoading(false)
    })
    return unsub
  }, [])

  async function sendMagicLink(email: string) {
    await sendSignInLinkToEmail(auth, email, {
      url: ACTION_CODE_URL,
      handleCodeInApp: true,
    })
    chrome.storage.local.set({ [PENDING_EMAIL_KEY]: email })
  }

  async function completeMagicLink(link: string) {
    const result = await chrome.storage.local.get(PENDING_EMAIL_KEY)
    const email = result[PENDING_EMAIL_KEY] as string | undefined
    if (!email) throw new Error('No pending email found. Please request a new link.')
    await signInWithEmailLink(auth, email, link)
    chrome.storage.local.remove(PENDING_EMAIL_KEY)
  }

  function checkIsSignInLink(url: string) {
    return isSignInWithEmailLink(auth, url)
  }

  async function logout() {
    await signOut(auth)
  }

  return { user, loading, sendMagicLink, completeMagicLink, checkIsSignInLink, logout }
}
