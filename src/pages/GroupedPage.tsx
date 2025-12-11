import { useMemo } from 'react';
import { Flag, FolderOpen, Calendar } from 'lucide-react';
import { useAppStore } from '@/stores/useAppStore';
import { TaskInput } from '@/components/tasks/TaskInput';
import { TaskList } from '@/components/tasks/TaskList';
import { cn } from '@/lib/utils';
import { CATEGORIES, PRIORITY_CONFIG, Priority, CategoryId, Task } from '@/types';
import { isToday, isTomorrow, isThisWeek, isPast, startOfDay } from 'date-fns';

const viewTabs = [
  { id: 'priority' as const, label: 'Priority', icon: Flag },
  { id: 'categories' as const, label: 'Categories', icon: FolderOpen },
  { id: 'chrono' as const, label: 'Chrono', icon: Calendar },
];

export default function GroupedPage() {
  const { tasks, groupedView, setGroupedView } = useAppStore();
  const activeTasks = useMemo(() => tasks.filter((t) => !t.completedAt), [tasks]);

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
        {groupedView === 'priority' && <PriorityView tasks={activeTasks} />}
        {groupedView === 'categories' && <CategoriesView tasks={activeTasks} />}
        {groupedView === 'chrono' && <ChronoView tasks={activeTasks} />}
      </div>
    </div>
  );
}

function PriorityView({ tasks }: { tasks: Task[] }) {
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
    <div className="space-y-6">
      {(['high', 'medium', 'low', 'deferred'] as Priority[]).map((priority) => (
        <section key={priority} className="animate-fade-in">
          <div className="flex items-center gap-2 mb-3">
            <div className={cn('w-3 h-3 rounded-full', `bg-priority-${priority}`)} />
            <h2 className="text-sm font-semibold text-foreground capitalize">
              {PRIORITY_CONFIG[priority].label}
            </h2>
            <span className="text-xs text-muted-foreground">
              ({grouped[priority].length})
            </span>
          </div>
          
          <TaskInput defaultPriority={priority} className="mb-3" />
          
          <TaskList
            tasks={grouped[priority]}
            emptyMessage={`No ${priority} priority tasks`}
          />
        </section>
      ))}
    </div>
  );
}

function CategoriesView({ tasks }: { tasks: Task[] }) {
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
    <div className="space-y-6">
      {CATEGORIES.map((category) => (
        <section key={category.id} className="animate-fade-in">
          <div className="flex items-center gap-2 mb-3">
            <span className="text-lg">{category.icon}</span>
            <h2 className="text-sm font-semibold text-foreground">
              {category.name}
            </h2>
            <span className="text-xs text-muted-foreground">
              ({grouped[category.id].length})
            </span>
          </div>
          
          <TaskInput defaultCategories={[category.id]} className="mb-3" />
          
          <TaskList
            tasks={grouped[category.id]}
            emptyMessage={`No ${category.name.toLowerCase()} tasks`}
          />
        </section>
      ))}
    </div>
  );
}

function ChronoView({ tasks }: { tasks: Task[] }) {
  const grouped = useMemo(() => {
    const now = new Date();
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
    <div className="space-y-6">
      {buckets.map(({ key, label, color }) => (
        <section key={key} className="animate-fade-in">
          <div className="flex items-center gap-2 mb-3">
            <Calendar className={cn('w-4 h-4', color)} />
            <h2 className={cn('text-sm font-semibold', color)}>
              {label}
            </h2>
            <span className="text-xs text-muted-foreground">
              ({grouped[key].length})
            </span>
          </div>
          
          {key === 'today' && <TaskInput className="mb-3" />}
          
          <TaskList
            tasks={grouped[key]}
            emptyMessage={`No tasks ${label.toLowerCase()}`}
          />
        </section>
      ))}
    </div>
  );
}
