import { useEffect, useMemo, useState } from 'react';
import { useAppStore } from '@/stores/useAppStore';
import { TaskInput } from '@/components/tasks/TaskInput';
import { DraggableTaskList } from '@/components/tasks/DraggableTaskList';
import { TaskEditSheet } from '@/components/tasks/TaskEditSheet';
import { useSwipeNavigation } from '@/hooks/useSwipeNavigation';
import { cn } from '@/lib/utils';
import { Task } from '@/types';

export default function TodosPage() {
  const { tasks, showDoneTasks, toggleShowDoneTasks, loadTasksFromSupabase } = useAppStore();
  const [editingTask, setEditingTask] = useState<Task | null>(null);

  // Enable swipe navigation
  useSwipeNavigation();

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

  return (
    <div className="flex flex-col h-full bg-background">
      {/* Header */}
      <header className="px-3 pt-6 pb-4 safe-area-top">
        <h1 className="text-2xl font-bold text-foreground px-1">To-Dos</h1>

        {/* Toggle */}
        <div className="flex items-center gap-1 mt-4 p-1 bg-muted rounded-xl">
          <button
            type="button"
            onClick={() => showDoneTasks && toggleShowDoneTasks()}
            className={cn(
              'flex-1 py-2 px-4 rounded-lg text-sm font-medium transition-all duration-200 tap-highlight',
              !showDoneTasks
                ? 'bg-card text-foreground shadow-soft'
                : 'text-muted-foreground hover:text-foreground'
            )}
          >
            Not Done ({activeTasks.length})
          </button>
          <button
            type="button"
            onClick={() => !showDoneTasks && toggleShowDoneTasks()}
            className={cn(
              'flex-1 py-2 px-4 rounded-lg text-sm font-medium transition-all duration-200 tap-highlight',
              showDoneTasks
                ? 'bg-card text-foreground shadow-soft'
                : 'text-muted-foreground hover:text-foreground'
            )}
          >
            Done ({completedTasks.length})
          </button>
        </div>
      </header>

      {/* Content - iOS-appropriate margins with safe-area padding */}
      <div className="flex-1 overflow-y-auto px-3 pb-4 smooth-scroll safe-area-left safe-area-right">
        {/* Task Input */}
        {!showDoneTasks && (
          <div className="mb-3 animate-fade-in">
            <TaskInput />
          </div>
        )}

        {/* Task List - near full-width */}
        <DraggableTaskList
          tasks={displayedTasks}
          showCompleted={showDoneTasks}
          onEdit={setEditingTask}
          emptyMessage={
            showDoneTasks
              ? 'No completed tasks yet'
              : 'All caught up! Add a task above.'
          }
        />
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
