import { useState } from 'react';
import { Check, Paperclip, GripVertical, Calendar } from 'lucide-react';
import { format } from 'date-fns';
import { cn } from '@/lib/utils';
import { Task, PRIORITY_CONFIG } from '@/types';
import { useAppStore } from '@/stores/useAppStore';
import { CategoryChip } from '@/components/common/CategoryChip';

interface TaskItemProps {
  task: Task;
  showCompleted?: boolean;
  onEdit?: (task: Task) => void;
  className?: string;
}

export function TaskItem({
  task,
  showCompleted = false,
  onEdit,
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
    onEdit?.(task);
  };

  return (
    <div
      onClick={handleTap}
      className={cn(
        'group relative bg-card rounded-xl border border-border/50 shadow-soft transition-all duration-200 tap-highlight cursor-pointer',
        'hover:shadow-card hover:border-border active:scale-[0.99]',
        isCompleted && 'opacity-60',
        className
      )}
    >
      <div className="flex items-start gap-3 p-4">
        {/* Drag Handle */}
        <div className="opacity-0 group-hover:opacity-100 transition-opacity cursor-grab active:cursor-grabbing pt-0.5">
          <GripVertical className="w-4 h-4 text-muted-foreground" />
        </div>

        {/* Checkbox */}
        <button
          type="button"
          onClick={handleToggleComplete}
          className={cn(
            'w-5 h-5 rounded-full border-2 flex-shrink-0 flex items-center justify-center transition-all duration-200 mt-0.5',
            isCompleted
              ? 'bg-primary border-primary'
              : 'border-muted-foreground/40 hover:border-primary'
          )}
        >
          {isCompleted && <Check className="w-3 h-3 text-primary-foreground" />}
        </button>

        {/* Content */}
        <div className="flex-1 min-w-0">
          <div className="flex items-start justify-between gap-2">
            <h3
              className={cn(
                'text-sm font-medium text-foreground leading-snug',
                isCompleted && 'line-through text-muted-foreground'
              )}
            >
              {task.title}
            </h3>
            
            {/* Priority indicator */}
            <div
              className={cn(
                'w-2 h-2 rounded-full flex-shrink-0 mt-1.5',
                task.priority === 'high' && 'bg-priority-high',
                task.priority === 'medium' && 'bg-priority-medium',
                task.priority === 'low' && 'bg-priority-low',
                task.priority === 'deferred' && 'bg-priority-deferred'
              )}
            />
          </div>

          {/* Categories */}
          {task.categories.length > 0 && (
            <div className="flex flex-wrap gap-1.5 mt-2">
              {task.categories.map((categoryId) => (
                <CategoryChip
                  key={categoryId}
                  categoryId={categoryId}
                  selected
                  size="sm"
                />
              ))}
            </div>
          )}

          {/* Meta row */}
          <div className="flex items-center gap-3 mt-2 text-xs text-muted-foreground">
            {task.attachments.length > 0 && (
              <div className="flex items-center gap-1">
                <Paperclip className="w-3 h-3" />
                <span>{task.attachments.length}</span>
              </div>
            )}
            
            {task.dueDate && (
              <div className="flex items-center gap-1">
                <Calendar className="w-3 h-3" />
                <span>
                  {format(new Date(task.dueDate), 'MMM d')}
                </span>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
