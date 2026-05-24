import { initializeApp } from 'firebase/app'
import { getAuth } from 'firebase/auth'
import { getFirestore } from 'firebase/firestore'

// TODO: Replace appId with your web app's Firebase App ID.
// Find it in Firebase Console → Project Settings → Your apps → Web app.
// The other values are shared across platforms.
const firebaseConfig = {
  apiKey: 'AIzaSyABWHYGN9dr-m3a0qaUwYHlrJAhNd7PfvA',
  authDomain: 'notelayer-c7bba.firebaseapp.com',
  projectId: 'notelayer-c7bba',
  storageBucket: 'notelayer-c7bba.firebasestorage.app',
  messagingSenderId: '762003542605',
  appId: 'REPLACE_WITH_WEB_APP_ID',
}

export const app = initializeApp(firebaseConfig)
export const auth = getAuth(app)
export const db = getFirestore(app)
