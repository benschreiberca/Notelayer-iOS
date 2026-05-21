/* Firebase Web SDK — Notelayer project: notelayer-c7bba
 *
 * Fill in the real values from:
 * Firebase Console → Project Settings → Your apps → Web app → SDK setup
 */
import { initializeApp } from 'firebase/app';
import { getAuth, GoogleAuthProvider, sendSignInLinkToEmail } from 'firebase/auth';
import { getFirestore } from 'firebase/firestore';

const firebaseConfig = {
  apiKey:            import.meta.env.VITE_FIREBASE_API_KEY            || 'REPLACE',
  authDomain:        import.meta.env.VITE_FIREBASE_AUTH_DOMAIN        || 'notelayer-c7bba.firebaseapp.com',
  projectId:         import.meta.env.VITE_FIREBASE_PROJECT_ID         || 'notelayer-c7bba',
  storageBucket:     import.meta.env.VITE_FIREBASE_STORAGE_BUCKET     || 'notelayer-c7bba.appspot.com',
  messagingSenderId: import.meta.env.VITE_FIREBASE_MESSAGING_SENDER_ID|| 'REPLACE',
  appId:             import.meta.env.VITE_FIREBASE_APP_ID             || 'REPLACE',
};

const app = initializeApp(firebaseConfig);

export const auth = getAuth(app);
export const db   = getFirestore(app);
export const googleProvider = new GoogleAuthProvider();

export const emailLinkSettings = {
  url:             `${window.location.origin}/auth/callback`,
  handleCodeInApp: true,
};

export { sendSignInLinkToEmail };
