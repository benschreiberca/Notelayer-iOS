import { useState, useRef, useCallback, useEffect } from 'react';
import { Task } from '@/types';
import { TaskItem } from './TaskItem';
import { cn } from '@/lib/utils';
import { useAppStore } from '@/stores/useAppStore';
import {
  LONG_PRESS_DELAY,
  LONG_PRESS_MOVEMENT_THRESHOLD,
} from '@/lib/swipe-constants';

interface DraggableTaskListProps {
  tasks: Task[];
  emptyMessage?: string;
  showCompleted?: boolean;
  onEdit?: (task: Task) => void;
  className?: string;
}

/**
 * DraggableTaskList - Task list with long-press-to-drag reordering
 * 
 * Gesture Model:
 * - Long-press (150ms): Activates drag mode with visual feedback
 * - Movement during delay: Cancels drag, allows scroll
 * - Drag: Reorder within list, visual feedback on potential drop targets
 * - Tap: Passes through to TaskItem for edit
 */
export function DraggableTaskList({
  tasks,
  emptyMessage = 'No tasks yet',
  showCompleted = false,
  onEdit,
  className,
}: DraggableTaskListProps) {
  const { reorderTasks } = useAppStore();
  
  // Drag state
  const [draggedId, setDraggedId] = useState<string | null>(null);
  const [dragOverId, setDragOverId] = useState<string | null>(null);
  
  // Long-press state for touch devices
  const longPressTimerRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const touchStartPosRef = useRef<{ x: number; y: number } | null>(null);
  const isDragActiveRef = useRef(false);
  
  // Track elements for reordering during drag
  const taskRefs = useRef<Map<string, HTMLDivElement>>(new Map());

  // Cleanup timer on unmount
  useEffect(() => {
    return () => {
      if (longPressTimerRef.current) {
        clearTimeout(longPressTimerRef.current);
      }
    };
  }, []);

  // ============================================================================
  // LONG-PRESS-TO-DRAG HANDLERS (Touch)
  // ============================================================================

  const handleTouchStart = useCallback((taskId: string, e: React.TouchEvent) => {
    const touch = e.touches[0];
    touchStartPosRef.current = { x: touch.clientX, y: touch.clientY };
    isDragActiveRef.current = false;

    // Start long-press timer
    longPressTimerRef.current = setTimeout(() => {
      // Activate drag mode
      isDragActiveRef.current = true;
      setDraggedId(taskId);
      
      // Haptic feedback if available
      if (navigator.vibrate) {
        navigator.vibrate(10);
      }
    }, LONG_PRESS_DELAY);
  }, []);

  const handleTouchMove = useCallback((taskId: string, e: React.TouchEvent) => {
    const touch = e.touches[0];
    
    // If drag not yet active, check movement threshold
    if (!isDragActiveRef.current && touchStartPosRef.current) {
      const deltaX = Math.abs(touch.clientX - touchStartPosRef.current.x);
      const deltaY = Math.abs(touch.clientY - touchStartPosRef.current.y);
      
      // Movement exceeds threshold - cancel long-press, this is a scroll
      if (deltaX > LONG_PRESS_MOVEMENT_THRESHOLD || deltaY > LONG_PRESS_MOVEMENT_THRESHOLD) {
        if (longPressTimerRef.current) {
          clearTimeout(longPressTimerRef.current);
          longPressTimerRef.current = null;
        }
        touchStartPosRef.current = null;
        return;
      }
    }
    
    // If drag is active, find which task we're over
    if (isDragActiveRef.current && draggedId) {
      e.preventDefault(); // Prevent scroll during drag
      
      // Find task under touch point
      const touchY = touch.clientY;
      let targetId: string | null = null;
      
      taskRefs.current.forEach((el, id) => {
        if (id === draggedId) return;
        const rect = el.getBoundingClientRect();
        if (touchY >= rect.top && touchY <= rect.bottom) {
          targetId = id;
        }
      });
      
      setDragOverId(targetId);
    }
  }, [draggedId]);

  const handleTouchEnd = useCallback(() => {
    // Clear long-press timer
    if (longPressTimerRef.current) {
      clearTimeout(longPressTimerRef.current);
      longPressTimerRef.current = null;
    }
    
    // If drag was active and we have a drop target, reorder
    if (isDragActiveRef.current && draggedId && dragOverId) {
      const draggedIndex = tasks.findIndex((t) => t.id === draggedId);
      const targetIndex = tasks.findIndex((t) => t.id === dragOverId);
      
      if (draggedIndex !== -1 && targetIndex !== -1) {
        const newOrder = [...tasks];
        const [removed] = newOrder.splice(draggedIndex, 1);
        newOrder.splice(targetIndex, 0, removed);
        reorderTasks(newOrder.map((t) => t.id));
      }
    }
    
    // Reset state
    isDragActiveRef.current = false;
    touchStartPosRef.current = null;
    setDraggedId(null);
    setDragOverId(null);
  }, [draggedId, dragOverId, tasks, reorderTasks]);

  // ============================================================================
  // DRAG HANDLERS (Desktop/Mouse)
  // ============================================================================

  const handleDragStart = useCallback((e: React.DragEvent, taskId: string) => {
    setDraggedId(taskId);
    e.dataTransfer.effectAllowed = 'move';
    e.dataTransfer.setData('text/plain', taskId);
    
    // Set drag image with slight offset
    const target = e.currentTarget as HTMLElement;
    if (target) {
      e.dataTransfer.setDragImage(target, 20, 20);
    }
  }, []);

  const handleDragOver = useCallback((e: React.DragEvent, taskId: string) => {
    e.preventDefault();
    e.dataTransfer.dropEffect = 'move';
    if (taskId !== draggedId) {
      setDragOverId(taskId);
    }
  }, [draggedId]);

  const handleDragLeave = useCallback(() => {
    setDragOverId(null);
  }, []);

  const handleDrop = useCallback((e: React.DragEvent, targetId: string) => {
    e.preventDefault();
    
    if (draggedId && draggedId !== targetId) {
      const draggedIndex = tasks.findIndex((t) => t.id === draggedId);
      const targetIndex = tasks.findIndex((t) => t.id === targetId);
      
      const newOrder = [...tasks];
      const [removed] = newOrder.splice(draggedIndex, 1);
      newOrder.splice(targetIndex, 0, removed);
      
      reorderTasks(newOrder.map((t) => t.id));
    }
    
    setDraggedId(null);
    setDragOverId(null);
  }, [draggedId, tasks, reorderTasks]);

  const handleDragEnd = useCallback(() => {
    setDraggedId(null);
    setDragOverId(null);
  }, []);

  // ============================================================================
  // RENDER
  // ============================================================================

  if (tasks.length === 0) {
    return (
      <div className="flex flex-col items-center justify-center py-12 text-center">
        <div className="w-16 h-16 rounded-full bg-muted/50 flex items-center justify-center mb-4">
          <span className="text-2xl">✓</span>
        </div>
        <p className="text-muted-foreground text-sm">{emptyMessage}</p>
      </div>
    );
  }

  return (
    <div className={cn('space-y-2', className)}>
      {tasks.map((task, index) => (
        <div
          key={task.id}
          ref={(el) => {
            if (el) {
              taskRefs.current.set(task.id, el);
            } else {
              taskRefs.current.delete(task.id);
            }
          }}
          draggable
          onDragStart={(e) => handleDragStart(e, task.id)}
          onDragOver={(e) => handleDragOver(e, task.id)}
          onDragLeave={handleDragLeave}
          onDrop={(e) => handleDrop(e, task.id)}
          onDragEnd={handleDragEnd}
          onTouchStart={(e) => handleTouchStart(task.id, e)}
          onTouchMove={(e) => handleTouchMove(task.id, e)}
          onTouchEnd={handleTouchEnd}
          className={cn(
            'animate-slide-up touch-manipulation',
            // Drop target indicator
            dragOverId === task.id && draggedId !== task.id && 
              'ring-2 ring-primary ring-offset-2 ring-offset-background rounded-xl',
          )}
          style={{ animationDelay: `${index * 50}ms` }}
          data-swipeable="true"
        >
          <TaskItem
            task={task}
            showCompleted={showCompleted}
            onEdit={onEdit}
            isDragging={draggedId === task.id}
          />
        </div>
      ))}
    </div>
  );
}
