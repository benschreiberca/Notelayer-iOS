import type { TabId } from '../types'

interface Props {
  activeTab: TabId
  onTabChange: (tab: TabId) => void
  taskCount: number
  noteCount: number
}

const tabs: { id: TabId; label: string; icon: (active: boolean) => React.ReactNode }[] = [
  {
    id: 'todos',
    label: 'To-Dos',
    icon: (active) => (
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
        <path
          d="M9 11l3 3L22 4M21 12v7a2 2 0 01-2 2H5a2 2 0 01-2-2V5a2 2 0 012-2h11"
          stroke={active ? '#6366F1' : '#6B7280'}
          strokeWidth="1.75"
          strokeLinecap="round"
          strokeLinejoin="round"
        />
      </svg>
    ),
  },
  {
    id: 'notes',
    label: 'Notes',
    icon: (active) => (
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
        <path
          d="M9 12h6M9 16h4M7 4H5a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2V6a2 2 0 00-2-2h-2M9 4a2 2 0 012-2h2a2 2 0 012 2v0a2 2 0 01-2 2h-2a2 2 0 01-2-2z"
          stroke={active ? '#6366F1' : '#6B7280'}
          strokeWidth="1.75"
          strokeLinecap="round"
          strokeLinejoin="round"
        />
      </svg>
    ),
  },
]

export default function TabBar({ activeTab, onTabChange, taskCount, noteCount }: Props) {
  const counts: Record<TabId, number> = { todos: taskCount, notes: noteCount }

  return (
    <div
      className="flex items-center justify-around px-4 py-2"
      style={{
        borderTop: '1px solid #1F2937',
        background: 'rgba(17,24,39,0.95)',
        backdropFilter: 'blur(10px)',
        minHeight: '56px',
      }}
    >
      {tabs.map((tab) => {
        const active = activeTab === tab.id
        const count = counts[tab.id]
        return (
          <button
            key={tab.id}
            onClick={() => onTabChange(tab.id)}
            className="flex flex-col items-center gap-0.5 flex-1 py-1 rounded-xl transition-all"
            style={{
              background: active ? 'rgba(99,102,241,0.12)' : 'transparent',
              border: 'none',
              cursor: 'pointer',
            }}
          >
            <div className="relative">
              {tab.icon(active)}
              {count > 0 && (
                <span
                  className="absolute -top-1 -right-2 text-white flex items-center justify-center font-medium"
                  style={{
                    background: '#6366F1',
                    borderRadius: '9999px',
                    fontSize: '9px',
                    minWidth: '14px',
                    height: '14px',
                    padding: '0 3px',
                  }}
                >
                  {count > 99 ? '99+' : count}
                </span>
              )}
            </div>
            <span
              className="text-xs font-medium"
              style={{ color: active ? '#6366F1' : '#6B7280' }}
            >
              {tab.label}
            </span>
          </button>
        )
      })}
    </div>
  )
}
