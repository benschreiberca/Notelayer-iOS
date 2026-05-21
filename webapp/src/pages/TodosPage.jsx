import { useState } from 'react';
import AppShell from '../components/layout/AppShell';
import LensSwitcher from '../components/layout/LensSwitcher';
import TaskRow from '../components/ui/TaskRow';
import TaskInput from '../components/ui/TaskInput';

const SAMPLE_TASKS = [
  { id: '1', title: 'Organize the drawer that eats single socks', priority: 'low',    categories: ['house'],   createdAt: new Date().toISOString(), updatedAt: new Date().toISOString() },
  { id: '2', title: 'Call mom (she knows I saw her text)',         priority: 'high',   categories: ['travel'],  createdAt: new Date().toISOString(), updatedAt: new Date().toISOString(), dueDate: new Date(Date.now() + 86400000).toISOString() },
  { id: '3', title: 'Research NAS drive options',                  priority: 'medium', categories: ['tech'],    createdAt: new Date().toISOString(), updatedAt: new Date().toISOString() },
  { id: '4', title: 'File Q1 receipts',                           priority: 'high',   categories: ['finance'], createdAt: new Date().toISOString(), updatedAt: new Date().toISOString(), dueDate: new Date(Date.now() + 3 * 86400000).toISOString() },
  { id: '5', title: 'Order replacement windshield wipers',         priority: 'low',    categories: ['vehicle'], createdAt: new Date().toISOString(), updatedAt: new Date().toISOString() },
  { id: '6', title: 'Pick up dry cleaning',                       priority: 'medium', categories: ['shopping'], createdAt: new Date().toISOString(), updatedAt: new Date().toISOString(), completedAt: new Date().toISOString() },
];

export default function TodosPage() {
  const [tasks, setTasks]   = useState(SAMPLE_TASKS);
  const [showing, setShowing] = useState('doing');
  const [lens, setLens]     = useState('List');

  const doingCount = tasks.filter(t => !t.completedAt).length;
  const doneCount  = tasks.filter(t =>  t.completedAt).length;

  const visible = tasks.filter(t =>
    showing === 'doing' ? !t.completedAt : !!t.completedAt
  );

  const handleToggle = (id) => {
    setTasks(prev => prev.map(t =>
      t.id === id
        ? { ...t, completedAt: t.completedAt ? null : new Date().toISOString() }
        : t
    ));
  };

  const handleAdd = (title) => {
    setTasks(prev => [{
      id: crypto.randomUUID(),
      title,
      priority: 'medium',
      categories: [],
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    }, ...prev]);
  };

  return (
    <div style={{
      minHeight: '100dvh',
      background: 'linear-gradient(135deg, #D8E5FF 0%, #E6DAFE 50%, #FDD9EC 100%)',
      position: 'relative',
    }}>
      {/* Wallpaper white overlay */}
      <div style={{
        position: 'fixed', inset: 0, pointerEvents: 'none',
        background: 'linear-gradient(180deg, rgba(255,255,255,0.35) 0%, rgba(255,255,255,0.55) 100%)',
      }} />

      <div style={{ position: 'relative', zIndex: 1, paddingBottom: 80 }}>
        <AppShell
          doingCount={doingCount}
          doneCount={doneCount}
          showing={showing}
          onShowingToggle={() => setShowing(s => s === 'doing' ? 'done' : 'doing')}
          onSettings={() => {}}
        >
          <LensSwitcher active={lens} onChange={setLens} />
        </AppShell>

        <div style={{ padding: '0 16px' }}>
          <TaskInput onAdd={handleAdd} />
          {visible.map(task => (
            <TaskRow key={task.id} task={task} onToggle={handleToggle} />
          ))}
          {visible.length === 0 && (
            <div style={{
              textAlign: 'center', padding: '40px 20px',
              color: 'var(--text-tertiary)', fontFamily: 'var(--font-body)', fontSize: 15,
            }}>
              {showing === 'doing' ? 'No tasks to do. Add one above.' : 'Nothing done yet.'}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
