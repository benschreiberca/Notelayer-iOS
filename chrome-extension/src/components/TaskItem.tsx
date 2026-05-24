import type { Task, Category } from '../types'

interface Props {
  task: Task
  categories: Category[]
  onToggle: (task: Task) => void
  onDelete: (id: string) => void
}

const priorityDot: Record<string, string> = {
  high: '#EF4444',
  medium: '#F59E0B',
  low: '#6B7280',
  deferred: '#374151',
}

function formatDate(iso: string) {
  const d = new Date(iso)
  const now = new Date()
  const diff = d.getTime() - now.getTime()
  const days = Math.ceil(diff / 86400000)
  if (days === 0) return 'Today'
  if (days === 1) return 'Tomorrow'
  if (days === -1) return 'Yesterday'
  if (days < 0) return `${Math.abs(days)}d overdue`
  if (days < 7) return `${days}d`
  return d.toLocaleDateString('en-US', { month: 'short', day: 'numeric' })
}

export default function TaskItem({ task, categories, onToggle, onDelete }: Props) {
  const done = !!task.completedAt
  const taskCats = categories.filter((c) => task.categories.includes(c.id))

  return (
    <div
      className="flex items-start gap-3 px-4 py-3 group"
      style={{
        borderBottom: '1px solid rgba(55,65,81,0.5)',
      }}
    >
      {/* Checkbox */}
      <button
        onClick={() => onToggle(task)}
        className="mt-0.5 flex-shrink-0 w-5 h-5 rounded-full flex items-center justify-center transition-all"
        style={{
          border: done ? 'none' : `2px solid ${priorityDot[task.priority] ?? '#6B7280'}`,
          background: done ? '#6366F1' : 'transparent',
          cursor: 'pointer',
        }}
      >
        {done && (
          <svg width="10" height="10" viewBox="0 0 12 12" fill="none">
            <path d="M2 6l3 3 5-5" stroke="white" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/>
          </svg>
        )}
      </button>

      {/* Content */}
      <div className="flex-1 min-w-0">
        <p
          className="text-sm leading-snug"
          style={{
            color: done ? '#6B7280' : '#F3F4F6',
            textDecoration: done ? 'line-through' : 'none',
          }}
        >
          {task.title}
        </p>

        {/* Meta row */}
        <div className="flex items-center gap-2 mt-1 flex-wrap">
          {task.dueDate && !done && (
            <span
              className="text-xs"
              style={{ color: new Date(task.dueDate) < new Date() ? '#EF4444' : '#9CA3AF' }}
            >
              {formatDate(task.dueDate)}
            </span>
          )}
          {taskCats.map((cat) => (
            <span
              key={cat.id}
              className="text-xs px-1.5 py-0.5 rounded-md flex items-center gap-1"
              style={{
                background: `${cat.color}22`,
                color: cat.color,
              }}
            >
              {cat.icon} {cat.name}
            </span>
          ))}
        </div>
      </div>

      {/* Delete (shows on hover) */}
      <button
        onClick={() => onDelete(task.id)}
        className="opacity-0 group-hover:opacity-100 flex-shrink-0 p-1 rounded transition-opacity"
        style={{ color: '#6B7280', cursor: 'pointer', background: 'transparent', border: 'none' }}
      >
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none">
          <path d="M18 6L6 18M6 6l12 12" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round"/>
        </svg>
      </button>
    </div>
  )
}
