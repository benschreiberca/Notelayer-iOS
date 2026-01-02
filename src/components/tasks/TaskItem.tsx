import { Check, Paperclip, Calendar } from 'lucide-react';
import { format } from 'date-fns';
import { cn } from '@/lib/utils';
import { Task } from '@/types';
import { useAppStore } from '@/stores/useAppStore';
import { CategoryChip } from '@/components/common/CategoryChip';

interface TaskItemProps {
  task: Task;
  showCompleted?: boolean;
  onEdit?: (task: Task) => void;
  isDragging?: boolean;
  className?: string;
}

/**
 * TaskItem - Individual task card component
 * 
 * Gesture Model:
 * - Tap: Opens task edit sheet
 * - Long-press: Handled by parent (DraggableTaskList) for drag-and-drop
 * - No per-card swipe gestures (horizontal swipes reserved for page navigation)
 */
export function TaskItem({
  task,
  showCompleted = false,
  onEdit,
  isDragging = false,
  className,
}: TaskItemProps) {
  const { completeTask, restoreTask } = useAppStore();

  const isCompleted = !!task.completedAt;

  const handleToggleComplete = (e: React.MouseEvent) => {
    e.stopPropagation();
    if (isCompleted) {
      restoreTask(task.id);
    } else {
      completeTask(task.id);
    }
  };

  const handleTap = () => {
    // Don't trigger tap if we're in drag mode
    if (isDragging) return;
    onEdit?.(task);
  };

  // Meta visibility
  const hasBadges = task.categories.length > 0 || task.attachments.length > 0;
  const hasDate = !!task.dueDate;
  const hasMetaRow = hasBadges || hasDate;

  return (
    <div className="relative overflow-hidden rounded-xl">
      {/* Main Content (no per-card swipe; drag handled by parent wrapper) */}
      <div
        onClick={handleTap}
        className={cn(
          'group relative bg-card rounded-xl border border-border/50 shadow-soft transition-all tap-highlight cursor-pointer select-none touch-manipulation',
          'hover:shadow-card hover:border-border active:scale-[0.99]',
          isCompleted && 'opacity-60',
          className
        )}
      >
        <div className="flex items-start gap-3 p-3 pl-4">
          {/* Content */}
          <div className="flex-1 min-w-0">
            {/* Title row */}
            <div className="flex items-start justify-between gap-2">
              <div className="flex items-start gap-2 flex-1 min-w-0">
                {/* Priority indicator (dot for now; icons handled elsewhere if desired) */}
                <div
                  className={cn(
                    'w-2 h-2 rounded-full flex-shrink-0 mt-1.5',
                    task.priority === 'high' && 'bg-priority-high',
                    task.priority === 'medium' && 'bg-priority-medium',
                    task.priority === 'low' && 'bg-priority-low',
                    task.priority === 'deferred' && 'bg-priority-deferred'
                  )}
                />
                <h3
                  className={cn(
                    'text-sm font-medium text-foreground leading-snug flex-1',
                    isCompleted && 'line-through text-muted-foreground'
                  )}
                >
                  {task.title}
                </h3>
              </div>
            </div>

            {/* Meta row: badges left-aligned, date right-aligned */}
            {hasMetaRow && (
              <div className="flex items-center justify-between gap-2 mt-2">
                {/* Left side */}
                <div className="flex items-center gap-2 flex-wrap flex-1 min-w-0">
                  {task.categories.map((categoryId) => (
                    <CategoryChip
                      key={categoryId}
                      categoryId={categoryId}
                      selected
                      size="sm"
                    />
                  ))}
                  {task.attachments.length > 0 && (
                    <div className="flex items-center gap-1 text-xs text-muted-foreground">
                      <Paperclip className="w-3 h-3" />
                      <span>{task.attachments.length}</span>
                    </div>
                  )}
                </div>

                {/* Right side */}
                {hasDate && (
                  <div className="flex items-center gap-1 text-xs text-muted-foreground flex-shrink-0">
                    <Calendar className="w-3 h-3" />
                    <span>{format(new Date(task.dueDate!), 'MMM d')}</span>
                  </div>
                )}
              </div>
            )}
          </div>

          {/* Complete button (right side) */}
          <button
            type="button"
            onClick={handleToggleComplete}
            className={cn(
              'w-6 h-6 rounded-full border-2 flex-shrink-0 flex items-center justify-center transition-all duration-200 mt-0.5',
              isCompleted
                ? 'bg-primary border-primary'
                : 'border-muted-foreground/40 hover:border-primary active:scale-95'
            )}
          >
            {isCompleted && (
              <Check className="w-3.5 h-3.5 text-primary-foreground" />
            )}
          </button>
        </div>
      </div>
    </div>
  );
}
