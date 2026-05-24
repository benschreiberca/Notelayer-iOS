import type { Note } from '../types'

interface Props {
  note: Note
  onDelete: (id: string) => void
}

function timeAgo(iso: string) {
  const diff = Date.now() - new Date(iso).getTime()
  const mins = Math.floor(diff / 60000)
  if (mins < 1) return 'just now'
  if (mins < 60) return `${mins}m ago`
  const hrs = Math.floor(mins / 60)
  if (hrs < 24) return `${hrs}h ago`
  const days = Math.floor(hrs / 24)
  if (days < 7) return `${days}d ago`
  return new Date(iso).toLocaleDateString('en-US', { month: 'short', day: 'numeric' })
}

export default function NoteItem({ note, onDelete }: Props) {
  const lines = note.text.split('\n')
  const preview = lines[0]
  const rest = lines.slice(1).join(' ').trim()

  return (
    <div
      className="px-4 py-3 group"
      style={{ borderBottom: '1px solid rgba(55,65,81,0.5)' }}
    >
      <div className="flex items-start justify-between gap-2">
        <div className="flex-1 min-w-0">
          <p className="text-sm font-medium leading-snug" style={{ color: '#F3F4F6' }}>
            {preview}
          </p>
          {rest && (
            <p
              className="text-xs mt-0.5 truncate"
              style={{ color: '#6B7280' }}
            >
              {rest}
            </p>
          )}
          <p className="text-xs mt-1" style={{ color: '#4B5563' }}>
            {timeAgo(note.createdAt)}
          </p>
        </div>

        <button
          onClick={() => onDelete(note.id)}
          className="opacity-0 group-hover:opacity-100 flex-shrink-0 p-1 rounded transition-opacity"
          style={{ color: '#6B7280', cursor: 'pointer', background: 'transparent', border: 'none' }}
        >
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none">
            <path d="M18 6L6 18M6 6l12 12" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round"/>
          </svg>
        </button>
      </div>
    </div>
  )
}
