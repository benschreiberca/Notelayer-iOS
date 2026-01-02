import { useState } from 'react';
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

  // Touch-based reordering
  const [touchDragId, setTouchDragId] = useState<string | null>(null);
  const [touchY, setTouchY] = useState(0);

  const handleTouchStart = (taskId: string, e: React.TouchEvent) => {
    const touch = e.touches[0];
    setTouchY(touch.clientY);
    // Start drag after a short delay
    const timeout = setTimeout(() => {
      setTouchDragId(taskId);
    }, 200);
    
    const cleanup = () => {
      clearTimeout(timeout);
    };
    
    e.currentTarget.addEventListener('touchend', cleanup, { once: true });
    e.currentTarget.addEventListener('touchmove', (moveE) => {
      const moveTouch = (moveE as TouchEvent).touches[0];
      if (Math.abs(moveTouch.clientY - touch.clientY) > 10 || Math.abs(moveTouch.clientX - touch.clientX) > 10) {
        clearTimeout(timeout);
      }
    }, { once: true });
  };

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
          draggable
          onDragStart={(e) => handleDragStart(e, task.id)}
          onDragOver={(e) => handleDragOver(e, task.id)}
          onDragLeave={handleDragLeave}
          onDrop={(e) => handleDrop(e, task.id)}
          onDragEnd={handleDragEnd}
          onTouchStart={(e) => handleTouchStart(task.id, e)}
          className={cn(
            'animate-slide-up transition-all duration-200',
            draggedId === task.id && 'opacity-50 scale-95',
            dragOverId === task.id && 'scale-[1.02] shadow-lg',
            touchDragId === task.id && 'scale-[1.02] shadow-lg z-10'
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
