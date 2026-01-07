import { useMemo, useState, useCallback } from 'react';
import { Flag, FolderOpen, Calendar, ChevronRight } from 'lucide-react';
import { useAppStore } from '@/stores/useAppStore';
import { TaskInput } from '@/components/tasks/TaskInput';
import { GroupedTaskList } from '@/components/tasks/GroupedTaskList';
import { TaskEditSheet } from '@/components/tasks/TaskEditSheet';
import { useSwipeNavigation } from '@/hooks/useSwipeNavigation';
import { cn } from '@/lib/utils';
import {
  CATEGORIES,
  PRIORITY_CONFIG,
  Priority,
  CategoryId,
  Task,
  sortTasksByPriorityThenDate,
  sortTasksByDate,
} from '@/types';
import { isToday, isTomorrow, isThisWeek, isPast, addDays, startOfDay, endOfWeek } from 'date-fns';
import { Collapsible, CollapsibleTrigger, CollapsibleContent } from '@/components/ui/collapsible';
import { PriorityIcon } from '@/components/common/PriorityIcon';

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
      <header className="px-3 pt-6 pb-4 safe-area-top">
        <h1 className="text-2xl font-bold text-foreground px-1">Grouped</h1>
        
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

      {/* Content - iOS-appropriate margins with safe-area padding */}
      <div className="flex-1 overflow-y-auto px-3 pb-4 smooth-scroll safe-area-left safe-area-right">
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

interface GroupedSectionProps {
  title: string;
  icon?: React.ReactNode;
  count: number;
  children: React.ReactNode;
  headerColor?: string;
  defaultOpen?: boolean;
}

function GroupedSection({ 
  title, 
  icon, 
  count, 
  children, 
  headerColor, 
  defaultOpen = true 
}: GroupedSectionProps) {
  const [isOpen, setIsOpen] = useState(defaultOpen);

  return (
    <Collapsible
      open={isOpen}
      onOpenChange={setIsOpen}
      className="group border-b border-border/50 last:border-0"
    >
      <CollapsibleTrigger className="flex items-center w-full py-3 px-1 hover:bg-muted/30 active:bg-muted/50 transition-colors text-left rounded-md my-0.5">
        <div className="flex items-center gap-2 flex-1">
          <ChevronRight 
            className={cn(
              "w-4 h-4 text-muted-foreground transition-transform duration-200", 
              isOpen && "rotate-90"
            )} 
          />
          {icon}
          <h2 className={cn("text-sm font-semibold flex-1", headerColor || "text-foreground")}>
            {title}
          </h2>
          <span className="text-xs text-muted-foreground font-medium bg-muted/80 px-2 py-0.5 rounded-full">
            {count}
          </span>
        </div>
      </CollapsibleTrigger>
      
      <CollapsibleContent className="animate-slide-down">
        <div className="pl-2 pb-3 pt-1">
          {children}
        </div>
      </CollapsibleContent>
    </Collapsible>
  );
}

function PriorityView({ tasks, onEdit }: ViewProps) {
  const { updateTask } = useAppStore();

  // Group tasks by priority, then sort by createdAt within each group
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
    // Sort each group by createdAt (newest first)
    (['high', 'medium', 'low', 'deferred'] as Priority[]).forEach((p) => {
      groups[p] = sortTasksByDate(groups[p]);
    });
    return groups;
  }, [tasks]);

  // Handle regrouping: update task priority when dragged to a different section
  const handleTaskRegrouped = useCallback(
    (taskId: string, newPriority: string) => {
      updateTask(taskId, { priority: newPriority as Priority });
    },
    [updateTask]
  );

  // Handle nesting: set parent/child relationship
  const handleTaskNested = useCallback(
    (draggedTaskId: string, parentTaskId: string) => {
      updateTask(draggedTaskId, { parentTaskId });
    },
    [updateTask]
  );

  return (
    <div className="flex flex-col">
      {(['high', 'medium', 'low', 'deferred'] as Priority[]).map((priority) => (
        <GroupedSection
          key={priority}
          title={PRIORITY_CONFIG[priority].label}
          count={grouped[priority].length}
          defaultOpen={grouped[priority].length > 0}
          icon={<PriorityIcon priority={priority} size="sm" />}
        >
          <TaskInput defaultPriority={priority} className="mb-2" />
          <GroupedTaskList
            tasks={grouped[priority]}
            sectionId={priority}
            onEdit={onEdit}
            onTaskRegrouped={handleTaskRegrouped}
            onTaskNested={handleTaskNested}
            emptyMessage={`No ${priority} priority tasks`}
            className="py-2"
          />
        </GroupedSection>
      ))}
    </div>
  );
}

function CategoriesView({ tasks, onEdit }: ViewProps) {
  const { updateTask } = useAppStore();

  // Group tasks by category, then sort by priority then createdAt
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
    // Sort each group by priority, then by createdAt
    CATEGORIES.forEach((cat) => {
      groups[cat.id] = sortTasksByPriorityThenDate(groups[cat.id]);
    });
    return groups;
  }, [tasks]);

  // Handle regrouping: update task categories when dragged to a different section
  // This adds the new category and removes the old one
  const handleTaskRegrouped = useCallback(
    (taskId: string, newCategoryId: string, sourceCategoryId: string) => {
      const task = tasks.find((t) => t.id === taskId);
      if (!task) return;

      // Build new categories: remove source, add new (if not already present)
      let newCategories = task.categories.filter((c) => c !== sourceCategoryId);
      if (!newCategories.includes(newCategoryId as CategoryId)) {
        newCategories = [...newCategories, newCategoryId as CategoryId];
      }
      updateTask(taskId, { categories: newCategories });
    },
    [tasks, updateTask]
  );

  // Handle nesting: set parent/child relationship
  const handleTaskNested = useCallback(
    (draggedTaskId: string, parentTaskId: string) => {
      updateTask(draggedTaskId, { parentTaskId });
    },
    [updateTask]
  );

  return (
    <div className="flex flex-col">
      {CATEGORIES.map((category) => (
        <GroupedSection
          key={category.id}
          title={category.name}
          count={grouped[category.id].length}
          defaultOpen={grouped[category.id].length > 0}
          icon={<span className="text-base leading-none">{category.icon}</span>}
        >
          <TaskInput defaultCategories={[category.id]} className="mb-2" />
          <GroupedTaskList
            tasks={grouped[category.id]}
            sectionId={category.id}
            onEdit={onEdit}
            onTaskRegrouped={handleTaskRegrouped}
            onTaskNested={handleTaskNested}
            emptyMessage={`No ${category.name.toLowerCase()} tasks`}
            className="py-2"
          />
        </GroupedSection>
      ))}
    </div>
  );
}

type ChronoBucket = 'overdue' | 'today' | 'tomorrow' | 'thisWeek' | 'later' | 'noDueDate';

/**
 * Compute the new dueDate when a task is dropped into a chrono bucket.
 */
function computeDueDateForBucket(bucket: ChronoBucket): Date | undefined {
  const now = new Date();
  const today = startOfDay(now);

  switch (bucket) {
    case 'overdue':
      // Keep at yesterday (overdue by 1 day)
      return addDays(today, -1);
    case 'today':
      return today;
    case 'tomorrow':
      return addDays(today, 1);
    case 'thisWeek':
      // Set to end of this week
      return endOfWeek(today, { weekStartsOn: 1 }); // Monday start
    case 'later':
      // Set to 1 week from now
      return addDays(today, 7);
    case 'noDueDate':
      // Clear the due date
      return undefined;
    default:
      return undefined;
  }
}

function ChronoView({ tasks, onEdit }: ViewProps) {
  const { updateTask } = useAppStore();

  // Group tasks by chrono bucket, then sort by priority then createdAt
  const grouped = useMemo(() => {
    const groups: Record<ChronoBucket, Task[]> = {
      overdue: [],
      today: [],
      tomorrow: [],
      thisWeek: [],
      later: [],
      noDueDate: [],
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

    // Sort each bucket by priority, then by createdAt
    (Object.keys(groups) as ChronoBucket[]).forEach((key) => {
      groups[key] = sortTasksByPriorityThenDate(groups[key]);
    });

    return groups;
  }, [tasks]);

  // Handle regrouping: update task dueDate when dragged to a different bucket
  const handleTaskRegrouped = useCallback(
    (taskId: string, newBucket: string) => {
      const newDueDate = computeDueDateForBucket(newBucket as ChronoBucket);
      updateTask(taskId, { dueDate: newDueDate });
    },
    [updateTask]
  );

  // Handle nesting: set parent/child relationship
  const handleTaskNested = useCallback(
    (draggedTaskId: string, parentTaskId: string) => {
      updateTask(draggedTaskId, { parentTaskId });
    },
    [updateTask]
  );

  const buckets: { key: ChronoBucket; label: string; color: string }[] = [
    { key: 'overdue', label: 'Overdue', color: 'text-destructive' },
    { key: 'today', label: 'Today', color: 'text-primary' },
    { key: 'tomorrow', label: 'Tomorrow', color: 'text-accent' },
    { key: 'thisWeek', label: 'This Week', color: 'text-foreground' },
    { key: 'later', label: 'Later', color: 'text-muted-foreground' },
    { key: 'noDueDate', label: 'No Due Date', color: 'text-muted-foreground' },
  ];

  return (
    <div className="flex flex-col">
      {buckets.map(({ key, label, color }) => (
        <GroupedSection
          key={key}
          title={label}
          count={grouped[key].length}
          headerColor={color}
          defaultOpen={grouped[key].length > 0}
          icon={<Calendar className={cn('w-4 h-4', color)} />}
        >
          {key === 'today' && <TaskInput className="mb-2" />}
          <GroupedTaskList
            tasks={grouped[key]}
            sectionId={key}
            onEdit={onEdit}
            onTaskRegrouped={handleTaskRegrouped}
            onTaskNested={handleTaskNested}
            emptyMessage={`No tasks ${label.toLowerCase()}`}
            className="py-2"
          />
        </GroupedSection>
      ))}
    </div>
  );
}
