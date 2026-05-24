import { useState } from 'react'
import type { Task, Category } from '../types'
import TaskItem from './TaskItem'

interface Props {
  tasks: Task[]
  categories: Category[]
  loading: boolean
  onAdd: (title: string, priority: Task['priority']) => Promise<void>
  onToggle: (task: Task) => Promise<void>
  onDelete: (id: string) => Promise<void>
}

type Filter = 'open' | 'done'

export default function TodosView({ tasks, categories, loading, onAdd, onToggle, onDelete }: Props) {
  const [filter, setFilter] = useState<Filter>('open')
  const [adding, setAdding] = useState(false)
  const [newTitle, setNewTitle] = useState('')
  const [newPriority, setNewPriority] = useState<Task['priority']>('medium')
  const [saving, setSaving] = useState(false)

  const filtered = tasks.filter((t) =>
    filter === 'open' ? !t.completedAt : !!t.completedAt
  )

  async function handleAdd(e: React.FormEvent) {
    e.preventDefault()
    if (!newTitle.trim()) return
    setSaving(true)
    try {
      await onAdd(newTitle.trim(), newPriority)
      setNewTitle('')
      setAdding(false)
    } finally {
      setSaving(false)
    }
  }

  const priorityOptions: { value: Task['priority']; label: string; color: string }[] = [
    { value: 'high', label: 'High', color: '#EF4444' },
    { value: 'medium', label: 'Medium', color: '#F59E0B' },
    { value: 'low', label: 'Low', color: '#6B7280' },
    { value: 'deferred', label: 'Deferred', color: '#374151' },
  ]

  return (
    <div className="flex flex-col flex-1 overflow-hidden">
      {/* Header */}
      <div className="flex items-center justify-between px-4 py-3">
        <div
          className="flex rounded-xl p-0.5"
          style={{ background: '#1F2937' }}
        >
          {(['open', 'done'] as Filter[]).map((f) => (
            <button
              key={f}
              onClick={() => setFilter(f)}
              className="px-3 py-1.5 rounded-xl text-xs font-medium transition-all"
              style={{
                background: filter === f ? '#6366F1' : 'transparent',
                color: filter === f ? 'white' : '#6B7280',
                border: 'none',
                cursor: 'pointer',
              }}
            >
              {f === 'open' ? 'Open' : 'Done'}
            </button>
          ))}
        </div>

        <button
          onClick={() => setAdding((v) => !v)}
          className="w-8 h-8 rounded-full flex items-center justify-center transition-all"
          style={{
            background: adding ? '#6366F1' : 'rgba(99,102,241,0.12)',
            border: 'none',
            cursor: 'pointer',
          }}
        >
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
            <path
              d={adding ? 'M18 6L6 18M6 6l12 12' : 'M12 5v14M5 12h14'}
              stroke="white"
              strokeWidth="2"
              strokeLinecap="round"
            />
          </svg>
        </button>
      </div>

      {/* Add form */}
      {adding && (
        <form
          onSubmit={handleAdd}
          className="mx-4 mb-3 p-3 rounded-xl"
          style={{ background: '#1F2937', border: '1px solid #374151' }}
        >
          <input
            autoFocus
            value={newTitle}
            onChange={(e) => setNewTitle(e.target.value)}
            placeholder="New to-do…"
            className="w-full text-sm outline-none bg-transparent mb-2"
            style={{ color: '#F3F4F6' }}
          />
          <div className="flex items-center justify-between">
            <div className="flex gap-1">
              {priorityOptions.map((p) => (
                <button
                  key={p.value}
                  type="button"
                  onClick={() => setNewPriority(p.value)}
                  className="px-2 py-1 rounded-lg text-xs font-medium transition-all"
                  style={{
                    background: newPriority === p.value ? `${p.color}22` : 'transparent',
                    color: newPriority === p.value ? p.color : '#6B7280',
                    border: newPriority === p.value ? `1px solid ${p.color}44` : '1px solid transparent',
                    cursor: 'pointer',
                  }}
                >
                  {p.label}
                </button>
              ))}
            </div>
            <button
              type="submit"
              disabled={saving || !newTitle.trim()}
              className="px-3 py-1 rounded-lg text-xs font-medium text-white"
              style={{
                background: saving || !newTitle.trim() ? '#374151' : '#6366F1',
                border: 'none',
                cursor: saving || !newTitle.trim() ? 'not-allowed' : 'pointer',
              }}
            >
              {saving ? '…' : 'Add'}
            </button>
          </div>
        </form>
      )}

      {/* List */}
      <div className="flex-1 overflow-y-auto">
        {loading ? (
          <div className="flex items-center justify-center py-8">
            <div className="w-5 h-5 rounded-full border-2 border-indigo-500 border-t-transparent animate-spin" />
          </div>
        ) : filtered.length === 0 ? (
          <div className="flex flex-col items-center justify-center py-10" style={{ color: '#4B5563' }}>
            <svg width="32" height="32" viewBox="0 0 24 24" fill="none" className="mb-2">
              <path d="M9 11l3 3L22 4M21 12v7a2 2 0 01-2 2H5a2 2 0 01-2-2V5a2 2 0 012-2h11" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/>
            </svg>
            <p className="text-sm">
              {filter === 'open' ? 'No open to-dos' : 'No completed to-dos'}
            </p>
          </div>
        ) : (
          filtered.map((task) => (
            <TaskItem
              key={task.id}
              task={task}
              categories={categories}
              onToggle={onToggle}
              onDelete={onDelete}
            />
          ))
        )}
      </div>
    </div>
  )
}
