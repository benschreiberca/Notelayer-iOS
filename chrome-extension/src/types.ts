export type Priority = 'high' | 'medium' | 'low' | 'deferred'

export interface Task {
  id: string
  title: string
  categories: string[]
  priority: Priority
  dueDate?: string
  completedAt?: string
  taskNotes?: string
  createdAt: string
  updatedAt: string
  orderIndex?: number
  parentTaskId?: string
}

export interface Note {
  id: string
  text: string
  createdAt: string
}

export interface Category {
  id: string
  name: string
  icon: string
  color: string
  order: number
}

export type TabId = 'todos' | 'notes'
