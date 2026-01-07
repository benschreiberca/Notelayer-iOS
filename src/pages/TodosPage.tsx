import { useCallback, useEffect, useMemo, useState } from 'react';
import type { ReactNode } from 'react';
import { Calendar, ChevronDown, ChevronRight } from 'lucide-react';
import { useAppStore } from '@/stores/useAppStore';
import { TaskInput } from '@/components/tasks/TaskInput';
import { DraggableTaskList } from '@/components/tasks/DraggableTaskList';
import { TaskEditSheet } from '@/components/tasks/TaskEditSheet';
import { GroupedTaskList } from '@/components/tasks/GroupedTaskList';
import { BulkCategorySheet } from '@/components/tasks/BulkCategorySheet';
import { CategoryManagerDialog } from '@/components/categories/CategoryManagerDialog';
import { useSwipeNavigation } from '@/hooks/useSwipeNavigation';
import { cn } from '@/lib/utils';
import { Collapsible, CollapsibleContent, CollapsibleTrigger } from '@/components/ui/collapsible';
import { PriorityIcon } from '@/components/common/PriorityIcon';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import {
  PRIORITY_CONFIG,
  CategoryId,
  Priority,
  Task,
  sortTasksByDate,
  sortTasksByPriorityThenDate,
} from '@/types';
import { addDays, endOfWeek, isPast, isThisWeek, isToday, isTomorrow, startOfDay } from 'date-fns';

const viewTabs = [
  { id: 'list' as const, label: 'List' },
  { id: 'priority' as const, label: 'Priority' },
  { id: 'category' as const, label: 'Category' },
  { id: 'date' as const, label: 'Date' },
];

export default function TodosPage() {
  const {
    tasks,
    showDoneTasks,
    toggleShowDoneTasks,
    loadTasksFromSupabase,
    todoView,
    setTodoView,
  } = useAppStore();
  const [editingTask, setEditingTask] = useState<Task | null>(null);
  const [isBulkMode, setIsBulkMode] = useState(false);
  const [selectedTaskIds, setSelectedTaskIds] = useState<string[]>([]);
  const [bulkCategoryOpen, setBulkCategoryOpen] = useState(false);
  const [manageOpen, setManageOpen] = useState(false);

  const viewOrder = useMemo(() => viewTabs.map((tab) => tab.id), []);

  const handleViewSwipe = useCallback(
    (direction: 'left' | 'right') => {
      const currentIndex = viewOrder.indexOf(todoView);
      if (currentIndex === -1) return false;
      const nextIndex =
        direction === 'left'
          ? (currentIndex + 1) % viewOrder.length
          : (currentIndex - 1 + viewOrder.length) % viewOrder.length;
      setTodoView(viewOrder[nextIndex]);
      return true;
    },
    [setTodoView, todoView, viewOrder]
  );

  // Enable swipe navigation between views
  useSwipeNavigation({
    onSwipeLeft: () => handleViewSwipe('left'),
    onSwipeRight: () => handleViewSwipe('right'),
  });

  // Load tasks from Supabase on first mount
  useEffect(() => {
    loadTasksFromSupabase();
  }, [loadTasksFromSupabase]);

  const { activeTasks, completedTasks } = useMemo(() => {
    const active = tasks.filter((t) => !t.completedAt);
    const completed = tasks.filter((t) => !!t.completedAt);
    return { activeTasks: active, completedTasks: completed };
  }, [tasks]);

  const displayedTasks = showDoneTasks ? completedTasks : activeTasks;
  const showTaskInputs = !showDoneTasks;

  const toggleTaskSelection = useCallback((taskId: string) => {
    setSelectedTaskIds((prev) =>
      prev.includes(taskId) ? prev.filter((id) => id !== taskId) : [...prev, taskId]
    );
  }, []);

  const exitBulkMode = useCallback(() => {
    setIsBulkMode(false);
    setSelectedTaskIds([]);
  }, []);

  const toggleBulkMode = useCallback(() => {
    if (isBulkMode) {
      exitBulkMode();
      return;
    }
    setIsBulkMode(true);
  }, [exitBulkMode, isBulkMode]);

  const setShowDoneTasks = useCallback(
    (showDone: boolean) => {
      if (showDone !== showDoneTasks) {
        toggleShowDoneTasks();
      }
    },
    [showDoneTasks, toggleShowDoneTasks]
  );

  return (
    <div className="flex flex-col h-full bg-background">
      {/* Header */}
      <header className="px-3 pt-6 pb-4 safe-area-top">
        <div className="flex items-start justify-between gap-3 px-1">
          <h1 className="text-2xl font-bold text-foreground">To-Dos</h1>
          <TodosHeaderMenu
            isBulkMode={isBulkMode}
            onToggleBulkMode={toggleBulkMode}
            onManageCategories={() => setManageOpen(true)}
            showDoneTasks={showDoneTasks}
            onShowDoneChange={setShowDoneTasks}
          />
        </div>

        {/* Inline View Toggle */}
        <div className="flex items-center gap-1 mt-4 p-1 bg-muted rounded-xl">
          {viewTabs.map(({ id, label }) => (
            <button
              key={id}
              type="button"
              onClick={() => setTodoView(id)}
              className={cn(
                'flex-1 py-2 px-2 rounded-lg text-xs font-medium transition-all duration-200 tap-highlight sm:text-sm',
                todoView === id
                  ? 'bg-card text-foreground shadow-soft'
                  : 'text-muted-foreground hover:text-foreground'
              )}
            >
              {label}
            </button>
          ))}
        </div>
        {isBulkMode && (
          <div className="flex items-center justify-between gap-3 mt-3 px-1">
            <span className="text-xs text-muted-foreground">
              {selectedTaskIds.length} selected
            </span>
            <button
              type="button"
              onClick={() => setBulkCategoryOpen(true)}
              className={cn(
                'px-3 py-1.5 rounded-lg text-xs font-medium transition-all duration-200 tap-highlight sm:text-sm',
                selectedTaskIds.length > 0
                  ? 'bg-primary text-primary-foreground'
                  : 'bg-muted text-muted-foreground cursor-not-allowed'
              )}
              disabled={selectedTaskIds.length === 0}
            >
              Edit Categories
            </button>
          </div>
        )}
      </header>

      {/* Content - iOS-appropriate margins with safe-area padding */}
      <div className="flex-1 overflow-y-auto px-3 pb-4 smooth-scroll safe-area-left safe-area-right">
        {todoView === 'list' && (
          <>
            {/* Task Input */}
            {showTaskInputs && (
              <div className="mb-3 animate-fade-in">
                <TaskInput />
              </div>
            )}

            {/* Task List - near full-width */}
            <DraggableTaskList
              tasks={displayedTasks}
              showCompleted={showDoneTasks}
              onEdit={setEditingTask}
              selectionMode={isBulkMode}
              selectedTaskIds={selectedTaskIds}
              onToggleSelect={toggleTaskSelection}
              emptyMessage={
                showDoneTasks
                  ? 'No completed tasks yet'
                  : 'All caught up! Add a task above.'
              }
            />
          </>
        )}

        {todoView === 'priority' && (
          <PriorityView
            tasks={displayedTasks}
            onEdit={setEditingTask}
            showInputs={showTaskInputs}
            selectionMode={isBulkMode}
            selectedTaskIds={selectedTaskIds}
            onToggleSelect={toggleTaskSelection}
          />
        )}

        {todoView === 'category' && (
          <CategoryView
            tasks={displayedTasks}
            onEdit={setEditingTask}
            showInputs={showTaskInputs}
            selectionMode={isBulkMode}
            selectedTaskIds={selectedTaskIds}
            onToggleSelect={toggleTaskSelection}
          />
        )}

        {todoView === 'date' && (
          <DateView
            tasks={displayedTasks}
            onEdit={setEditingTask}
            showInputs={showTaskInputs}
            selectionMode={isBulkMode}
            selectedTaskIds={selectedTaskIds}
            onToggleSelect={toggleTaskSelection}
          />
        )}
      </div>

      {/* Edit Sheet */}
      <TaskEditSheet
        task={editingTask}
        open={!!editingTask}
        onOpenChange={(open) => !open && setEditingTask(null)}
      />
      <BulkCategorySheet
        open={bulkCategoryOpen}
        onOpenChange={setBulkCategoryOpen}
        selectedTaskIds={selectedTaskIds}
      />
      <CategoryManagerDialog open={manageOpen} onOpenChange={setManageOpen} />
    </div>
  );
}

interface ViewProps {
  tasks: Task[];
  onEdit: (task: Task) => void;
  showInputs: boolean;
  selectionMode: boolean;
  selectedTaskIds: string[];
  onToggleSelect: (taskId: string) => void;
}

interface GroupedSectionProps {
  title: string;
  icon?: ReactNode;
  count: number;
  children: ReactNode;
  headerColor?: string;
  defaultOpen?: boolean;
}

function GroupedSection({
  title,
  icon,
  count,
  children,
  headerColor,
  defaultOpen = true,
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
              'w-4 h-4 text-muted-foreground transition-transform duration-200',
              isOpen && 'rotate-90'
            )}
          />
          {icon}
          <h2 className={cn('text-sm font-semibold flex-1', headerColor || 'text-foreground')}>
            {title}
          </h2>
          <span className="text-xs text-muted-foreground font-medium bg-muted/80 px-2 py-0.5 rounded-full">
            {count}
          </span>
        </div>
      </CollapsibleTrigger>

      <CollapsibleContent className="animate-slide-down">
        <div className="pl-2 pb-3 pt-1">{children}</div>
      </CollapsibleContent>
    </Collapsible>
  );
}

function PriorityView({
  tasks,
  onEdit,
  showInputs,
  selectionMode,
  selectedTaskIds,
  onToggleSelect,
}: ViewProps) {
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
          {showInputs && <TaskInput defaultPriority={priority} className="mb-2" />}
          <GroupedTaskList
            tasks={grouped[priority]}
            sectionId={priority}
            onEdit={onEdit}
            onTaskRegrouped={handleTaskRegrouped}
            onTaskNested={handleTaskNested}
            emptyMessage={`No ${priority} priority tasks`}
            className="py-2"
            selectionMode={selectionMode}
            selectedTaskIds={selectedTaskIds}
            onToggleSelect={onToggleSelect}
          />
        </GroupedSection>
      ))}
    </div>
  );
}

function CategoryView({
  tasks,
  onEdit,
  showInputs,
  selectionMode,
  selectedTaskIds,
  onToggleSelect,
}: ViewProps) {
  const { updateTask, categories } = useAppStore();

  // Group tasks by category, then sort by priority then createdAt
  const grouped = useMemo(() => {
    const groups: Record<CategoryId, Task[]> = {} as Record<CategoryId, Task[]>;
    categories.forEach((cat) => {
      groups[cat.id] = [];
    });
    tasks.forEach((task) => {
      task.categories.forEach((catId) => {
        if (!groups[catId]) {
          groups[catId] = [];
        }
        groups[catId].push(task);
      });
    });
    // Sort each group by priority, then by createdAt
    categories.forEach((cat) => {
      groups[cat.id] = sortTasksByPriorityThenDate(groups[cat.id] ?? []);
    });
    return groups;
  }, [tasks, categories]);

  // Handle regrouping: update task categories when dragged to a different section
  // This adds the new category and removes the old one
  const handleTaskRegrouped = useCallback(
    (taskId: string, newCategoryId: string, sourceCategoryId: string) => {
      const task = tasks.find((t) => t.id === taskId);
      if (!task) return;

      // Build new categories: remove source, add new (if not already present)
      let newCategories = task.categories.filter((c) => c !== sourceCategoryId);
      if (!newCategories.includes(newCategoryId)) {
        newCategories = [...newCategories, newCategoryId];
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
      {categories.map((category) => (
        <GroupedSection
          key={category.id}
          title={category.name}
          count={grouped[category.id].length}
          defaultOpen={grouped[category.id].length > 0}
          icon={<span className="text-base leading-none">{category.icon}</span>}
        >
          {showInputs && <TaskInput defaultCategories={[category.id]} className="mb-2" />}
          <GroupedTaskList
            tasks={grouped[category.id]}
            sectionId={category.id}
            onEdit={onEdit}
            onTaskRegrouped={handleTaskRegrouped}
            onTaskNested={handleTaskNested}
            emptyMessage={`No ${category.name.toLowerCase()} tasks`}
            className="py-2"
            selectionMode={selectionMode}
            selectedTaskIds={selectedTaskIds}
            onToggleSelect={onToggleSelect}
          />
        </GroupedSection>
      ))}
    </div>
  );
}

type DateBucket = 'overdue' | 'today' | 'tomorrow' | 'thisWeek' | 'later' | 'noDueDate';

/**
 * Assumption: the "Date" view uses the same chrono buckets from the previous grouped screen.
 */
function computeDueDateForBucket(bucket: DateBucket): Date | undefined {
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

function DateView({
  tasks,
  onEdit,
  showInputs,
  selectionMode,
  selectedTaskIds,
  onToggleSelect,
}: ViewProps) {
  const { updateTask } = useAppStore();

  // Group tasks by date bucket, then sort by priority then createdAt
  const grouped = useMemo(() => {
    const groups: Record<DateBucket, Task[]> = {
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
    (Object.keys(groups) as DateBucket[]).forEach((key) => {
      groups[key] = sortTasksByPriorityThenDate(groups[key]);
    });

    return groups;
  }, [tasks]);

  // Handle regrouping: update task dueDate when dragged to a different bucket
  const handleTaskRegrouped = useCallback(
    (taskId: string, newBucket: string) => {
      const newDueDate = computeDueDateForBucket(newBucket as DateBucket);
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

  const buckets: { key: DateBucket; label: string; color: string }[] = [
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
          {key === 'today' && showInputs && <TaskInput className="mb-2" />}
          <GroupedTaskList
            tasks={grouped[key]}
            sectionId={key}
            onEdit={onEdit}
            onTaskRegrouped={handleTaskRegrouped}
            onTaskNested={handleTaskNested}
            emptyMessage={`No tasks ${label.toLowerCase()}`}
            className="py-2"
            selectionMode={selectionMode}
            selectedTaskIds={selectedTaskIds}
            onToggleSelect={onToggleSelect}
          />
        </GroupedSection>
      ))}
    </div>
  );
}
function TodosHeaderMenu({
  isBulkMode,
  onToggleBulkMode,
  onManageCategories,
  showDoneTasks,
  onShowDoneChange,
}: {
  isBulkMode: boolean;
  onToggleBulkMode: () => void;
  onManageCategories: () => void;
  showDoneTasks: boolean;
  onShowDoneChange: (showDone: boolean) => void;
}) {
  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <button
          type="button"
          className="h-11 w-11 rounded-full border border-border/50 bg-card text-muted-foreground hover:text-foreground hover:border-border transition-colors flex items-center justify-center"
          aria-label="To-Do actions"
        >
          <ChevronDown className="w-5 h-5" />
        </button>
      </DropdownMenuTrigger>
      <DropdownMenuContent align="end" className="w-52 bg-popover z-50">
        <DropdownMenuItem onClick={onManageCategories}>
          Manage categories
        </DropdownMenuItem>
        <DropdownMenuItem onClick={onToggleBulkMode}>
          {isBulkMode ? 'Cancel' : 'Select'}
        </DropdownMenuItem>
        <DropdownMenuSeparator />
        <DropdownMenuItem onClick={() => onShowDoneChange(false)}>
          Show To Do
        </DropdownMenuItem>
        <DropdownMenuItem onClick={() => onShowDoneChange(true)}>
          Show Done
        </DropdownMenuItem>
      </DropdownMenuContent>
    </DropdownMenu>
  );
}
