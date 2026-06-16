import { initializeApp, getApps } from "firebase/app";
import { getAuth } from "firebase/auth";
import { getFirestore } from "firebase/firestore";

const firebaseConfig = {
  apiKey: "AIzaSyBSf-W3F3gWEyGLZL91lE4ZgJkaAB6Xp1g",
  authDomain: "notelayer-c7bba.firebaseapp.com",
  projectId: "notelayer-c7bba",
  storageBucket: "notelayer-c7bba.firebasestorage.app",
  messagingSenderId: "762003542605",
  appId: "1:762003542605:web:cd00261c1d041725294204",
  measurementId: "G-3W6L1HZ8YP",
};

const app = getApps().length === 0 ? initializeApp(firebaseConfig) : getApps()[0];

export const auth = getAuth(app);
export const db = getFirestore(app);
