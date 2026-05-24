import { useState } from 'react'
import type { Note } from '../types'
import NoteItem from './NoteItem'

interface Props {
  notes: Note[]
  loading: boolean
  onAdd: (text: string) => Promise<void>
  onDelete: (id: string) => Promise<void>
  pageTitle?: string
  pageUrl?: string
}

export default function NotesView({ notes, loading, onAdd, onDelete, pageTitle, pageUrl }: Props) {
  const [adding, setAdding] = useState(false)
  const [text, setText] = useState('')
  const [saving, setSaving] = useState(false)
  const [search, setSearch] = useState('')

  async function handleAdd(e: React.FormEvent) {
    e.preventDefault()
    if (!text.trim()) return
    setSaving(true)
    try {
      await onAdd(text.trim())
      setText('')
      setAdding(false)
    } finally {
      setSaving(false)
    }
  }

  function prefillFromPage() {
    const parts = []
    if (pageTitle) parts.push(pageTitle)
    if (pageUrl) parts.push(pageUrl)
    setText(parts.join('\n'))
    setAdding(true)
  }

  const filtered = search
    ? notes.filter((n) => n.text.toLowerCase().includes(search.toLowerCase()))
    : notes

  return (
    <div className="flex flex-col flex-1 overflow-hidden">
      {/* Header */}
      <div className="flex items-center gap-2 px-4 py-3">
        <div
          className="flex-1 flex items-center gap-2 px-3 py-2 rounded-xl"
          style={{ background: '#1F2937', border: '1px solid #374151' }}
        >
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" style={{ flexShrink: 0 }}>
            <circle cx="11" cy="11" r="8" stroke="#6B7280" strokeWidth="1.75"/>
            <path d="M21 21l-4.35-4.35" stroke="#6B7280" strokeWidth="1.75" strokeLinecap="round"/>
          </svg>
          <input
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search notes…"
            className="flex-1 text-sm outline-none bg-transparent"
            style={{ color: '#F3F4F6' }}
          />
          {search && (
            <button onClick={() => setSearch('')} style={{ background: 'none', border: 'none', cursor: 'pointer', color: '#6B7280', padding: 0 }}>
              <svg width="12" height="12" viewBox="0 0 24 24" fill="none">
                <path d="M18 6L6 18M6 6l12 12" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
              </svg>
            </button>
          )}
        </div>

        <button
          onClick={() => { setAdding((v) => !v); setText('') }}
          className="w-8 h-8 rounded-full flex items-center justify-center"
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

      {/* Save from page banner */}
      {!adding && pageTitle && (
        <button
          onClick={prefillFromPage}
          className="mx-4 mb-2 flex items-center gap-2 px-3 py-2 rounded-xl text-left"
          style={{
            background: 'rgba(99,102,241,0.1)',
            border: '1px solid rgba(99,102,241,0.25)',
            cursor: 'pointer',
          }}
        >
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" style={{ flexShrink: 0 }}>
            <path d="M5 12h14M12 5l7 7-7 7" stroke="#6366F1" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"/>
          </svg>
          <div className="min-w-0">
            <p className="text-xs font-medium truncate" style={{ color: '#6366F1' }}>Save this page</p>
            <p className="text-xs truncate" style={{ color: '#4B5563' }}>{pageTitle}</p>
          </div>
        </button>
      )}

      {/* Add form */}
      {adding && (
        <form
          onSubmit={handleAdd}
          className="mx-4 mb-3 p-3 rounded-xl"
          style={{ background: '#1F2937', border: '1px solid #374151' }}
        >
          <textarea
            autoFocus
            value={text}
            onChange={(e) => setText(e.target.value)}
            placeholder="Note text…"
            rows={3}
            className="w-full text-sm outline-none bg-transparent resize-none mb-2"
            style={{ color: '#F3F4F6' }}
          />
          <div className="flex justify-end gap-2">
            <button
              type="button"
              onClick={() => { setAdding(false); setText('') }}
              className="px-3 py-1 rounded-lg text-xs"
              style={{ background: 'transparent', color: '#6B7280', border: 'none', cursor: 'pointer' }}
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={saving || !text.trim()}
              className="px-3 py-1 rounded-lg text-xs font-medium text-white"
              style={{
                background: saving || !text.trim() ? '#374151' : '#6366F1',
                border: 'none',
                cursor: saving || !text.trim() ? 'not-allowed' : 'pointer',
              }}
            >
              {saving ? '…' : 'Save'}
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
              <path d="M9 12h6M9 16h4M7 4H5a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2V6a2 2 0 00-2-2h-2M9 4a2 2 0 012-2h2a2 2 0 012 2v0a2 2 0 01-2 2h-2a2 2 0 01-2-2z" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/>
            </svg>
            <p className="text-sm">
              {search ? 'No matching notes' : 'No notes yet'}
            </p>
          </div>
        ) : (
          filtered.map((note) => (
            <NoteItem key={note.id} note={note} onDelete={onDelete} />
          ))
        )}
      </div>
    </div>
  )
}
