import { useState, useRef, useCallback } from 'react';
import { Check, Paperclip, GripVertical, Calendar, Trash2 } from 'lucide-react';
import { format } from 'date-fns';
import { cn } from '@/lib/utils';
import { Task, PRIORITY_CONFIG } from '@/types';
import { useAppStore } from '@/stores/useAppStore';
import {
  ROW_SWIPE_THRESHOLD,
  ROW_SWIPE_MAX_OFFSET,
  SWIPE_DIRECTION_LOCK_THRESHOLD,
  SWIPE_RESET_DURATION,
  SWIPE_ACTION_OPACITY_THRESHOLD,
  clampSwipeOffset,
} from '@/lib/swipe-constants';
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
  const { completeTask, restoreTask, deleteTask } = useAppStore();
  
  const isCompleted = !!task.completedAt;
  
  // Swipe state
  const [offset, setOffset] = useState(0);
  const [isDragging, setIsDragging] = useState(false);
  const [isHorizontalSwipe, setIsHorizontalSwipe] = useState(false);
  
  const startXRef = useRef(0);
  const startYRef = useRef(0);
  const directionLockedRef = useRef(false);

  const handleToggleComplete = (e: React.MouseEvent) => {
    e.stopPropagation();
    if (isCompleted) {
      restoreTask(task.id);
    } else {
      completeTask(task.id);
    }
  };

  const handleTap = () => {
    // Don't trigger tap if we were swiping
    if (Math.abs(offset) > 5) return;
    onEdit?.(task);
  };

  const handleTouchStart = useCallback((e: React.TouchEvent) => {
    startXRef.current = e.touches[0].clientX;
    startYRef.current = e.touches[0].clientY;
    setIsDragging(true);
    setIsHorizontalSwipe(false);
    directionLockedRef.current = false;
  }, []);

  const handleTouchMove = useCallback((e: React.TouchEvent) => {
    if (!isDragging) return;
    
    const currentX = e.touches[0].clientX;
    const currentY = e.touches[0].clientY;
    const deltaX = currentX - startXRef.current;
    const deltaY = currentY - startYRef.current;
    
    // Determine swipe direction once we've moved enough
    if (!directionLockedRef.current && 
        (Math.abs(deltaX) > SWIPE_DIRECTION_LOCK_THRESHOLD || 
         Math.abs(deltaY) > SWIPE_DIRECTION_LOCK_THRESHOLD)) {
      directionLockedRef.current = true;
      const horizontal = Math.abs(deltaX) > Math.abs(deltaY);
      setIsHorizontalSwipe(horizontal);
      
      if (!horizontal) {
        // This is a vertical scroll - release the gesture
        setIsDragging(false);
        setOffset(0);
        return;
      }
    }
    
    // Only update offset if we've confirmed horizontal swipe (only allow left swipe for delete)
    if (directionLockedRef.current && isHorizontalSwipe) {
      // Only allow left swipe (delete) - clamp positive values to 0
      const clampedDiff = Math.max(-ROW_SWIPE_MAX_OFFSET, Math.min(0, deltaX));
      setOffset(clampedDiff);
    }
  }, [isDragging, isHorizontalSwipe]);

  const handleTouchEnd = useCallback(() => {
    if (!isDragging) return;
    setIsDragging(false);
    setIsHorizontalSwipe(false);
    directionLockedRef.current = false;

    if (offset < -ROW_SWIPE_THRESHOLD) {
      // Swipe left - Delete
      deleteTask(task.id);
    }
    setOffset(0);
  }, [isDragging, offset, deleteTask, task.id]);

  return (
    <div 
      className="relative overflow-hidden rounded-xl"
      data-swipeable="true"
    >
      {/* Delete action (revealed on swipe left) */}
      <div
        className={cn(
          'absolute inset-0 flex items-center justify-end pr-4 bg-destructive transition-opacity',
          offset < -SWIPE_ACTION_OPACITY_THRESHOLD ? 'opacity-100' : 'opacity-0'
        )}
      >
        <span className="mr-2 text-sm font-medium text-destructive-foreground">Delete</span>
        <Trash2 className="w-6 h-6 text-destructive-foreground" />
      </div>
      
      <div
        onClick={handleTap}
        onTouchStart={handleTouchStart}
        onTouchMove={handleTouchMove}
        onTouchEnd={handleTouchEnd}
        className={cn(
          'group relative bg-card rounded-xl border border-border/50 shadow-soft tap-highlight cursor-pointer',
          'hover:shadow-card hover:border-border active:scale-[0.99]',
          isCompleted && 'opacity-60',
          isDragging ? 'transition-none' : 'transition-transform',
          className
        )}
        style={{ 
          transform: `translateX(${offset}px)`,
          transitionDuration: isDragging ? '0ms' : `${SWIPE_RESET_DURATION}ms`
        }}
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
    </div>
  );
}
