import { useState, useEffect } from 'react'
import {
  collection, query, orderBy, onSnapshot,
  addDoc, updateDoc, deleteDoc, doc, serverTimestamp, Timestamp
} from 'firebase/firestore'
import { db } from '../firebase'
import type { Task, Note, Category } from '../types'

function toDate(val: unknown): string {
  if (!val) return new Date().toISOString()
  if (val instanceof Timestamp) return val.toDate().toISOString()
  return String(val)
}

export function useTasks(userId: string) {
  const [tasks, setTasks] = useState<Task[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    if (!userId) return
    const q = query(
      collection(db, 'users', userId, 'tasks'),
      orderBy('createdAt', 'desc')
    )
    const unsub = onSnapshot(q, (snap) => {
      setTasks(snap.docs.map((d) => {
        const data = d.data()
        return {
          id: d.id,
          title: data.title ?? '',
          categories: data.categories ?? [],
          priority: data.priority ?? 'medium',
          dueDate: toDate(data.dueDate),
          completedAt: data.completedAt ? toDate(data.completedAt) : undefined,
          taskNotes: data.taskNotes,
          createdAt: toDate(data.createdAt),
          updatedAt: toDate(data.updatedAt),
          orderIndex: data.orderIndex,
          parentTaskId: data.parentTaskId,
        } as Task
      }))
      setLoading(false)
    })
    return unsub
  }, [userId])

  async function addTask(title: string, priority: Task['priority'] = 'medium') {
    const now = serverTimestamp()
    await addDoc(collection(db, 'users', userId, 'tasks'), {
      title,
      categories: [],
      priority,
      completedAt: null,
      taskNotes: '',
      createdAt: now,
      updatedAt: now,
    })
  }

  async function toggleComplete(task: Task) {
    const ref = doc(db, 'users', userId, 'tasks', task.id)
    await updateDoc(ref, {
      completedAt: task.completedAt ? null : serverTimestamp(),
      updatedAt: serverTimestamp(),
    })
  }

  async function deleteTask(taskId: string) {
    await deleteDoc(doc(db, 'users', userId, 'tasks', taskId))
  }

  return { tasks, loading, addTask, toggleComplete, deleteTask }
}

export function useNotes(userId: string) {
  const [notes, setNotes] = useState<Note[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    if (!userId) return
    const q = query(
      collection(db, 'users', userId, 'notes'),
      orderBy('createdAt', 'desc')
    )
    const unsub = onSnapshot(q, (snap) => {
      setNotes(snap.docs.map((d) => {
        const data = d.data()
        return {
          id: d.id,
          text: data.text ?? '',
          createdAt: toDate(data.createdAt),
        } as Note
      }))
      setLoading(false)
    })
    return unsub
  }, [userId])

  async function addNote(text: string) {
    await addDoc(collection(db, 'users', userId, 'notes'), {
      text,
      createdAt: serverTimestamp(),
    })
  }

  async function deleteNote(noteId: string) {
    await deleteDoc(doc(db, 'users', userId, 'notes', noteId))
  }

  return { notes, loading, addNote, deleteNote }
}

export function useCategories(userId: string) {
  const [categories, setCategories] = useState<Category[]>([])

  useEffect(() => {
    if (!userId) return
    const q = query(
      collection(db, 'users', userId, 'categories'),
      orderBy('order', 'asc')
    )
    const unsub = onSnapshot(q, (snap) => {
      setCategories(snap.docs.map((d) => ({ id: d.id, ...d.data() } as Category)))
    })
    return unsub
  }, [userId])

  return { categories }
}
