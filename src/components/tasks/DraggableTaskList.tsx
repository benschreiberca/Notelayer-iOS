import { useState, useRef, useCallback } from 'react';
import { Task } from '@/types';
import { TaskItem } from './TaskItem';
import { cn } from '@/lib/utils';
import { useAppStore } from '@/stores/useAppStore';

interface DraggableTaskListProps {
  tasks: Task[];
  emptyMessage?: string;
  showCompleted?: boolean;
  onEdit?: (task: Task) => void;
  className?: string;
  /** Use a condensed empty state for grouped views */
  condensedEmpty?: boolean;
}

export function DraggableTaskList({
  tasks,
  emptyMessage = 'No tasks yet',
  showCompleted = false,
  onEdit,
  className,
  condensedEmpty = false,
}: DraggableTaskListProps) {
  const { reorderTasks } = useAppStore();
  const [draggedId, setDraggedId] = useState<string | null>(null);
  const [dragOverId, setDragOverId] = useState<string | null>(null);

  // Touch-based drag state
  const [touchDragId, setTouchDragId] = useState<string | null>(null);
  const touchStartRef = useRef<{ x: number; y: number; taskId: string } | null>(null);
  const longPressTimerRef = useRef<NodeJS.Timeout | null>(null);
  const isDraggingRef = useRef(false);

  const handleDragStart = (e: React.DragEvent, taskId: string) => {
    setDraggedId(taskId);
    e.dataTransfer.effectAllowed = 'move';
    e.dataTransfer.setData('text/plain', taskId);
  };

  const handleDragOver = (e: React.DragEvent, taskId: string) => {
    e.preventDefault();
    e.dataTransfer.dropEffect = 'move';
    if (taskId !== draggedId) {
      setDragOverId(taskId);
    }
  };

  const handleDragLeave = () => {
    setDragOverId(null);
  };

  const handleDrop = (e: React.DragEvent, targetId: string) => {
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
  };

  const handleDragEnd = () => {
    setDraggedId(null);
    setDragOverId(null);
  };

  // Touch-based press-and-drag reordering (works from anywhere on the row)
  const handleTouchStart = useCallback((taskId: string, e: React.TouchEvent) => {
    const touch = e.touches[0];
    touchStartRef.current = { x: touch.clientX, y: touch.clientY, taskId };
    isDraggingRef.current = false;
    
    // Long press to initiate drag (300ms for responsive feel)
    longPressTimerRef.current = setTimeout(() => {
      isDraggingRef.current = true;
      setTouchDragId(taskId);
      // Haptic feedback if available
      if (navigator.vibrate) {
        navigator.vibrate(10);
      }
    }, 300);
  }, []);

  const handleTouchMove = useCallback((e: React.TouchEvent) => {
    if (!touchStartRef.current) return;
    
    const touch = e.touches[0];
    const dx = Math.abs(touch.clientX - touchStartRef.current.x);
    const dy = Math.abs(touch.clientY - touchStartRef.current.y);
    
    // Cancel long press if moved significantly before activation
    if (!isDraggingRef.current && (dx > 10 || dy > 10)) {
      if (longPressTimerRef.current) {
        clearTimeout(longPressTimerRef.current);
        longPressTimerRef.current = null;
      }
    }
    
    // During drag, find which task we're over and update dragOverId
    if (isDraggingRef.current && touchDragId) {
      const elements = document.elementsFromPoint(touch.clientX, touch.clientY);
      const taskWrapper = elements.find(el => el.getAttribute('data-task-id'));
      if (taskWrapper) {
        const overId = taskWrapper.getAttribute('data-task-id');
        if (overId && overId !== touchDragId) {
          setDragOverId(overId);
        }
      }
    }
  }, [touchDragId]);

  const handleTouchEnd = useCallback(() => {
    if (longPressTimerRef.current) {
      clearTimeout(longPressTimerRef.current);
      longPressTimerRef.current = null;
    }
    
    // Perform reorder if we were dragging and have a target
    if (isDraggingRef.current && touchDragId && dragOverId && touchDragId !== dragOverId) {
      const draggedIndex = tasks.findIndex((t) => t.id === touchDragId);
      const targetIndex = tasks.findIndex((t) => t.id === dragOverId);
      
      if (draggedIndex !== -1 && targetIndex !== -1) {
        const newOrder = [...tasks];
        const [removed] = newOrder.splice(draggedIndex, 1);
        newOrder.splice(targetIndex, 0, removed);
        reorderTasks(newOrder.map((t) => t.id));
      }
    }
    
    touchStartRef.current = null;
    isDraggingRef.current = false;
    setTouchDragId(null);
    setDragOverId(null);
  }, [touchDragId, dragOverId, tasks, reorderTasks]);

  if (tasks.length === 0) {
    // Condensed empty state for grouped views - minimal height
    if (condensedEmpty) {
      return (
        <div className="flex items-center justify-center py-3 text-center">
          <p className="text-muted-foreground/60 text-xs">{emptyMessage}</p>
        </div>
      );
    }
    // Standard empty state
    return (
      <div className={cn("flex flex-col items-center justify-center py-12 text-center", className)}>
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
          data-task-id={task.id}
          draggable
          onDragStart={(e) => handleDragStart(e, task.id)}
          onDragOver={(e) => handleDragOver(e, task.id)}
          onDragLeave={handleDragLeave}
          onDrop={(e) => handleDrop(e, task.id)}
          onDragEnd={handleDragEnd}
          onTouchStart={(e) => handleTouchStart(task.id, e)}
          onTouchMove={handleTouchMove}
          onTouchEnd={handleTouchEnd}
          className={cn(
            'animate-slide-up transition-all duration-200 touch-manipulation',
            draggedId === task.id && 'opacity-50 scale-95',
            dragOverId === task.id && 'scale-[1.02] shadow-lg ring-2 ring-primary/30',
            touchDragId === task.id && 'scale-[1.02] shadow-lg z-10 opacity-90'
          )}
          style={{ animationDelay: `${index * 50}ms` }}
        >
          <TaskItem
            task={task}
            showCompleted={showCompleted}
            onEdit={onEdit}
          />
        </div>
      ))}
    </div>
  );
}
