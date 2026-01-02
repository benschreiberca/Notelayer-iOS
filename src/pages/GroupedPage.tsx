import { useMemo, useState } from 'react';
import { Flag, FolderOpen, Calendar } from 'lucide-react';
import { useAppStore } from '@/stores/useAppStore';
import { TaskInput } from '@/components/tasks/TaskInput';
import { DraggableTaskList } from '@/components/tasks/DraggableTaskList';
import { TaskEditSheet } from '@/components/tasks/TaskEditSheet';
import { CollapsibleSection } from '@/components/common/CollapsibleSection';
import { useSwipeNavigation } from '@/hooks/useSwipeNavigation';
import { cn } from '@/lib/utils';
import { CATEGORIES, PRIORITY_CONFIG, Priority, CategoryId, Task } from '@/types';
import { isToday, isTomorrow, isThisWeek, isPast } from 'date-fns';

const viewTabs = [
  { id: 'priority' as const, label: 'Priority', icon: Flag },
  { id: 'categories' as const, label: 'Categories', icon: FolderOpen },
  { id: 'chrono' as const, label: 'Chrono', icon: Calendar },
];

export default function GroupedPage() {
  const { tasks, groupedView, setGroupedView } = useAppStore();
  const activeTasks = useMemo(() => tasks.filter((t) => !t.completedAt), [tasks]);
  const [editingTask, setEditingTask] = useState<Task | null>(null);

  // Enable swipe navigation
  useSwipeNavigation();

  return (
    <div className="flex flex-col h-full bg-background">
      {/* Header */}
      <header className="px-4 pt-6 pb-4 safe-area-top">
        <h1 className="text-2xl font-bold text-foreground">Grouped</h1>
        
        {/* View Tabs */}
        <div className="flex items-center gap-1 mt-4 p-1 bg-muted rounded-xl">
          {viewTabs.map(({ id, label, icon: Icon }) => (
            <button
              key={id}
              type="button"
              onClick={() => setGroupedView(id)}
              className={cn(
                'flex-1 flex items-center justify-center gap-1.5 py-2 px-3 rounded-lg text-sm font-medium transition-all duration-200 tap-highlight',
                groupedView === id
                  ? 'bg-card text-foreground shadow-soft'
                  : 'text-muted-foreground hover:text-foreground'
              )}
            >
              <Icon className="w-4 h-4" />
              <span className="hidden sm:inline">{label}</span>
            </button>
          ))}
        </div>
      </header>

      {/* Content */}
      <div className="flex-1 overflow-y-auto px-4 pb-4 smooth-scroll">
        {groupedView === 'priority' && <PriorityView tasks={activeTasks} onEdit={setEditingTask} />}
        {groupedView === 'categories' && <CategoriesView tasks={activeTasks} onEdit={setEditingTask} />}
        {groupedView === 'chrono' && <ChronoView tasks={activeTasks} onEdit={setEditingTask} />}
      </div>

      {/* Edit Sheet */}
      <TaskEditSheet
        task={editingTask}
        open={!!editingTask}
        onOpenChange={(open) => !open && setEditingTask(null)}
      />
    </div>
  );
}

interface ViewProps {
  tasks: Task[];
  onEdit: (task: Task) => void;
}

function PriorityView({ tasks, onEdit }: ViewProps) {
  const grouped = useMemo(() => {
    const groups: Record<Priority, Task[]> = {
      high: [],
      medium: [],
      low: [],
      deferred: [],
    };
    tasks.forEach((task) => {
      groups[task.priority].push(task);
    });
    return groups;
  }, [tasks]);

  return (
    <div className="space-y-2">
      {(['high', 'medium', 'low', 'deferred'] as Priority[]).map((priority) => (
        <CollapsibleSection
          key={priority}
          icon={
            <div className={cn('w-2.5 h-2.5 rounded-full', `bg-priority-${priority}`)} />
          }
          title={PRIORITY_CONFIG[priority].label}
          count={grouped[priority].length}
          defaultOpen={grouped[priority].length > 0}
          className="animate-fade-in"
        >
          <TaskInput defaultPriority={priority} className="mb-2" />
          <DraggableTaskList
            tasks={grouped[priority]}
            onEdit={onEdit}
            emptyMessage={`No ${priority} priority tasks`}
            condensedEmpty
          />
        </CollapsibleSection>
      ))}
    </div>
  );
}

function CategoriesView({ tasks, onEdit }: ViewProps) {
  const grouped = useMemo(() => {
    const groups: Record<CategoryId, Task[]> = {} as Record<CategoryId, Task[]>;
    CATEGORIES.forEach((cat) => {
      groups[cat.id] = [];
    });
    tasks.forEach((task) => {
      task.categories.forEach((catId) => {
        groups[catId].push(task);
      });
    });
    return groups;
  }, [tasks]);

  return (
    <div className="space-y-2">
      {CATEGORIES.map((category) => (
        <CollapsibleSection
          key={category.id}
          icon={<span className="text-sm">{category.icon}</span>}
          title={category.name}
          count={grouped[category.id].length}
          defaultOpen={grouped[category.id].length > 0}
          className="animate-fade-in"
        >
          <TaskInput defaultCategories={[category.id]} className="mb-2" />
          <DraggableTaskList
            tasks={grouped[category.id]}
            onEdit={onEdit}
            emptyMessage={`No ${category.name.toLowerCase()} tasks`}
            condensedEmpty
          />
        </CollapsibleSection>
      ))}
    </div>
  );
}

function ChronoView({ tasks, onEdit }: ViewProps) {
  const grouped = useMemo(() => {
    const groups = {
      overdue: [] as Task[],
      today: [] as Task[],
      tomorrow: [] as Task[],
      thisWeek: [] as Task[],
      later: [] as Task[],
      noDueDate: [] as Task[],
    };

    tasks.forEach((task) => {
      if (!task.dueDate) {
        groups.noDueDate.push(task);
        return;
      }

      const dueDate = new Date(task.dueDate);
      if (isPast(dueDate) && !isToday(dueDate)) {
        groups.overdue.push(task);
      } else if (isToday(dueDate)) {
        groups.today.push(task);
      } else if (isTomorrow(dueDate)) {
        groups.tomorrow.push(task);
      } else if (isThisWeek(dueDate)) {
        groups.thisWeek.push(task);
      } else {
        groups.later.push(task);
      }
    });

    return groups;
  }, [tasks]);

  const buckets = [
    { key: 'overdue', label: 'Overdue', color: 'text-destructive' },
    { key: 'today', label: 'Today', color: 'text-primary' },
    { key: 'tomorrow', label: 'Tomorrow', color: 'text-accent' },
    { key: 'thisWeek', label: 'This Week', color: 'text-foreground' },
    { key: 'later', label: 'Later', color: 'text-muted-foreground' },
    { key: 'noDueDate', label: 'No Due Date', color: 'text-muted-foreground' },
  ] as const;

  return (
    <div className="space-y-2">
      {buckets.map(({ key, label, color }) => (
        <CollapsibleSection
          key={key}
          icon={<Calendar className={cn('w-3.5 h-3.5', color)} />}
          title={label}
          count={grouped[key].length}
          headerColorClass={color}
          defaultOpen={grouped[key].length > 0 || key === 'today'}
          className="animate-fade-in"
        >
          {key === 'today' && <TaskInput className="mb-2" />}
          <DraggableTaskList
            tasks={grouped[key]}
            onEdit={onEdit}
            emptyMessage={`No tasks ${label.toLowerCase()}`}
            condensedEmpty
          />
        </CollapsibleSection>
      ))}
    </div>
  );
}
