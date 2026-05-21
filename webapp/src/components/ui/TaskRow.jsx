import CategoryChip from './CategoryChip';
import PriorityLabel from './PriorityLabel';

export default function TaskRow({ task, onToggle }) {
  const { id, title, dueDate, priority, categories = [], completedAt } = task;
  const done = !!completedAt;

  const priorityMap = { high: 'High', medium: 'Med', low: 'Low', deferred: 'Def' };
  const priorityLabel = priorityMap[priority];
  const dueFmt = dueDate
    ? new Date(dueDate).toLocaleDateString('en-US', { month: 'short', day: 'numeric' })
    : null;

  return (
    <div style={{
      display: 'flex',
      gap: 12,
      alignItems: 'flex-start',
      padding: '10px 12px',
      background: 'rgba(255,255,255,0.65)',
      border: '0.5px solid rgba(255,255,255,0.9)',
      borderRadius: 'var(--radius-lg)',
      margin: '6px 0',
      boxShadow: 'var(--shadow-subtle)',
      transition: 'background 0.15s',
    }}>
      {/* Checkbox */}
      <button
        onClick={() => onToggle?.(id)}
        style={{
          width: 22, height: 22, borderRadius: '50%', flexShrink: 0, marginTop: 2,
          border: done ? 'none' : '2px solid var(--gray-400)',
          background: done ? 'var(--indigo-500)' : 'transparent',
          cursor: 'pointer', padding: 0,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          transition: 'background 0.15s, border 0.15s',
        }}
      >
        {done && (
          <svg width="12" height="12" viewBox="0 0 12 12" fill="none">
            <path d="M2 6.5l2.5 2.5L10 3.5" stroke="#fff" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
          </svg>
        )}
      </button>

      {/* Content */}
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{
          fontFamily: 'var(--font-body)',
          fontSize: 15.5, lineHeight: '21px',
          color: done ? 'var(--text-disabled)' : 'var(--site-text)',
          textDecoration: done ? 'line-through' : 'none',
        }}>
          {title}
        </div>
        <div style={{
          display: 'flex', alignItems: 'center', gap: 8,
          marginTop: 5, flexWrap: 'wrap', overflow: 'hidden',
        }}>
          {dueFmt && (
            <span style={{ fontSize: 12, color: 'var(--text-tertiary)' }}>{dueFmt}</span>
          )}
          {priorityLabel && <PriorityLabel level={priorityLabel} />}
          {categories.slice(0, 1).map(cid => (
            <CategoryChip key={cid} categoryId={cid} compact />
          ))}
        </div>
      </div>
    </div>
  );
}
