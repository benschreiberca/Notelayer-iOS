import { useState, useEffect } from 'react'
import { useAuth } from './hooks/useAuth'
import { useTasks, useNotes, useCategories } from './hooks/useFirestore'
import LoginView from './components/LoginView'
import TabBar from './components/TabBar'
import TodosView from './components/TodosView'
import NotesView from './components/NotesView'
import type { TabId } from './types'

function Header({ email, onLogout }: { email: string; onLogout: () => void }) {
  const [menuOpen, setMenuOpen] = useState(false)

  return (
    <div
      className="flex items-center justify-between px-4 py-3"
      style={{ borderBottom: '1px solid #1F2937' }}
    >
      <div className="flex items-center gap-2">
        <div
          className="w-7 h-7 rounded-lg flex items-center justify-center"
          style={{ background: 'linear-gradient(135deg, #6366F1 0%, #4F46E5 100%)' }}
        >
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none">
            <path d="M9 12h6M9 16h4M7 4H5a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2V6a2 2 0 00-2-2h-2M9 4a2 2 0 012-2h2a2 2 0 012 2v0a2 2 0 01-2 2h-2a2 2 0 01-2-2z" stroke="white" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"/>
          </svg>
        </div>
        <span className="text-sm font-semibold text-white tracking-tight">Notelayer</span>
      </div>

      <div className="relative">
        <button
          onClick={() => setMenuOpen((v) => !v)}
          className="w-7 h-7 rounded-full flex items-center justify-center"
          style={{ background: '#1F2937', border: 'none', cursor: 'pointer' }}
        >
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none">
            <circle cx="12" cy="5" r="1.5" fill="#9CA3AF"/>
            <circle cx="12" cy="12" r="1.5" fill="#9CA3AF"/>
            <circle cx="12" cy="19" r="1.5" fill="#9CA3AF"/>
          </svg>
        </button>

        {menuOpen && (
          <>
            <div className="fixed inset-0 z-10" onClick={() => setMenuOpen(false)} />
            <div
              className="absolute right-0 top-full mt-1 z-20 rounded-xl py-1 min-w-40"
              style={{ background: '#1F2937', border: '1px solid #374151' }}
            >
              <div className="px-3 py-2">
                <p className="text-xs font-medium truncate" style={{ color: '#F3F4F6' }}>
                  {email}
                </p>
              </div>
              <div style={{ borderTop: '1px solid #374151' }} />
              <button
                onClick={() => { onLogout(); setMenuOpen(false) }}
                className="w-full text-left px-3 py-2 text-sm"
                style={{ color: '#EF4444', background: 'none', border: 'none', cursor: 'pointer' }}
              >
                Sign out
              </button>
            </div>
          </>
        )}
      </div>
    </div>
  )
}

export default function App() {
  const { user, loading: authLoading, logout } = useAuth()
  const [activeTab, setActiveTab] = useState<TabId>('todos')
  const [pageInfo, setPageInfo] = useState<{ title?: string; url?: string }>({})

  const uid = user?.uid ?? ''
  const { tasks, loading: tasksLoading, addTask, toggleComplete, deleteTask } = useTasks(uid)
  const { notes, loading: notesLoading, addNote, deleteNote } = useNotes(uid)
  const { categories } = useCategories(uid)

  useEffect(() => {
    if (!user) return
    chrome.tabs?.query({ active: true, currentWindow: true }, (tabs) => {
      const tab = tabs[0]
      if (tab) setPageInfo({ title: tab.title, url: tab.url })
    })
  }, [user])

  if (authLoading) {
    return (
      <div className="flex items-center justify-center flex-1" style={{ minHeight: '520px' }}>
        <div
          className="w-6 h-6 rounded-full border-2 border-t-transparent animate-spin"
          style={{ borderColor: '#6366F1', borderTopColor: 'transparent' }}
        />
      </div>
    )
  }

  if (!user) {
    return <LoginView />
  }

  const openTasks = tasks.filter((t) => !t.completedAt)

  return (
    <div className="flex flex-col" style={{ height: '580px' }}>
      <Header email={user.email ?? ''} onLogout={logout} />

      <div className="flex-1 flex flex-col overflow-hidden">
        {activeTab === 'todos' ? (
          <TodosView
            tasks={tasks}
            categories={categories}
            loading={tasksLoading}
            onAdd={addTask}
            onToggle={toggleComplete}
            onDelete={deleteTask}
          />
        ) : (
          <NotesView
            notes={notes}
            loading={notesLoading}
            onAdd={addNote}
            onDelete={deleteNote}
            pageTitle={pageInfo.title}
            pageUrl={pageInfo.url}
          />
        )}
      </div>

      <TabBar
        activeTab={activeTab}
        onTabChange={setActiveTab}
        taskCount={openTasks.length}
        noteCount={notes.length}
      />
    </div>
  )
}
