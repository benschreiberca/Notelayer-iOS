import { useState, useRef, useCallback } from 'react';
import type { Task } from '@/types';
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
  /** Use a condensed empty state for grouped views */
  condensedEmpty?: boolean;
  selectionMode?: boolean;
  selectedTaskIds?: string[];
  onToggleSelect?: (taskId: string) => void;
}

/**
 * DraggableTaskList - Task list with long-press-to-drag reordering
 *
 * Gesture Model:
 * - Long-press (LONG_PRESS_DELAY): Activates drag mode with visual feedback
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
  condensedEmpty = false,
  selectionMode = false,
  selectedTaskIds = [],
  onToggleSelect,
}: DraggableTaskListProps) {
  const { reorderTasks } = useAppStore();

  // Desktop drag state
  const [draggedId, setDraggedId] = useState<string | null>(null);
  const [dragOverId, setDragOverId] = useState<string | null>(null);

  // Touch-based drag state
  const [touchDragId, setTouchDragId] = useState<string | null>(null);
  const touchStartRef = useRef<{ x: number; y: number; taskId: string } | null>(
    null
  );
  const longPressTimerRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const isDraggingRef = useRef(false);

  // --- Desktop HTML5 Drag handlers ---
  const handleDragStart = useCallback(
    (e: React.DragEvent, taskId: string) => {
      if (selectionMode) return;
      setDraggedId(taskId);
      e.dataTransfer.effectAllowed = 'move';
      e.dataTransfer.setData('text/plain', taskId);

      // Set drag image with slight offset
      const target = e.currentTarget as HTMLElement;
      if (target) {
        e.dataTransfer.setDragImage(target, 20, 20);
      }
    },
    [selectionMode]
  );

  const handleDragOver = useCallback(
    (e: React.DragEvent, taskId: string) => {
      if (selectionMode) return;
      e.preventDefault();
      e.dataTransfer.dropEffect = 'move';
      if (taskId !== draggedId) {
        setDragOverId(taskId);
      }
    },
    [draggedId, selectionMode]
  );

  const handleDragLeave = useCallback(() => {
    setDragOverId(null);
  }, []);

  const handleDrop = useCallback(
    (e: React.DragEvent, targetId: string) => {
      if (selectionMode) return;
      e.preventDefault();

      if (draggedId && draggedId !== targetId) {
        const draggedIndex = tasks.findIndex((t) => t.id === draggedId);
        const targetIndex = tasks.findIndex((t) => t.id === targetId);

        if (draggedIndex !== -1 && targetIndex !== -1) {
          const newOrder = [...tasks];
          const [removed] = newOrder.splice(draggedIndex, 1);
          newOrder.splice(targetIndex, 0, removed);
          reorderTasks(newOrder.map((t) => t.id));
        }
      }

      setDraggedId(null);
      setDragOverId(null);
    },
    [draggedId, tasks, reorderTasks, selectionMode]
  );

  const handleDragEnd = useCallback(() => {
    setDraggedId(null);
    setDragOverId(null);
  }, []);

  // --- Touch long-press drag handlers ---
  const handleTouchStart = useCallback(
    (taskId: string, e: React.TouchEvent) => {
      if (selectionMode) return;
      const touch = e.touches[0];
      touchStartRef.current = { x: touch.clientX, y: touch.clientY, taskId };
      isDraggingRef.current = false;

      // Long-press to initiate drag (fast, controlled via constants)
      if (longPressTimerRef.current) {
        clearTimeout(longPressTimerRef.current);
      }

      longPressTimerRef.current = window.setTimeout(() => {
        isDraggingRef.current = true;
        setTouchDragId(taskId);

        // Optional light haptic feedback
        if (navigator.vibrate) navigator.vibrate(10);
      }, LONG_PRESS_DELAY);
    },
    [selectionMode]
  );

  const handleTouchMove = useCallback(
    (e: React.TouchEvent) => {
      if (selectionMode) return;
      if (!touchStartRef.current) return;

      const touch = e.touches[0];
      const dx = Math.abs(touch.clientX - touchStartRef.current.x);
      const dy = Math.abs(touch.clientY - touchStartRef.current.y);

      // Cancel long press if user starts scrolling/moving before activation
      if (
        !isDraggingRef.current &&
        (dx > LONG_PRESS_MOVEMENT_THRESHOLD ||
          dy > LONG_PRESS_MOVEMENT_THRESHOLD)
      ) {
        if (longPressTimerRef.current) {
          clearTimeout(longPressTimerRef.current);
          longPressTimerRef.current = null;
        }
      }

      // During drag, find which task we're over and update dragOverId
      if (isDraggingRef.current && touchDragId) {
        const elements = document.elementsFromPoint(
          touch.clientX,
          touch.clientY
        );
        const taskWrapper = elements.find((el) =>
          (el as HTMLElement).getAttribute?.('data-task-id')
        ) as HTMLElement | undefined;

        if (taskWrapper) {
          const overId = taskWrapper.getAttribute('data-task-id');
          if (overId && overId !== touchDragId) {
            setDragOverId(overId);
          }
        }
      }
    },
    [touchDragId, selectionMode]
  );

  const handleTouchEnd = useCallback(() => {
    if (selectionMode) return;
    if (longPressTimerRef.current) {
      clearTimeout(longPressTimerRef.current);
      longPressTimerRef.current = null;
    }

    // Perform reorder if we were dragging and have a target
    if (
      isDraggingRef.current &&
      touchDragId &&
      dragOverId &&
      touchDragId !== dragOverId
    ) {
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
  }, [touchDragId, dragOverId, tasks, reorderTasks, selectionMode]);

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
      <div
        className={cn(
          'flex flex-col items-center justify-center py-12 text-center',
          className
        )}
      >
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
          draggable={!selectionMode}
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
            isDragging={draggedId === task.id}
            selectionMode={selectionMode}
            selected={selectedTaskIds.includes(task.id)}
            onSelectToggle={onToggleSelect}
          />
        </div>
      ))}
    </div>
  );
}
