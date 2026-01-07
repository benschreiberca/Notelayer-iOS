import { useState, useRef, useCallback } from 'react';
import { Task } from '@/types';
import { TaskItem } from './TaskItem';
import { cn } from '@/lib/utils';

/**
 * Data transferred during drag operations.
 * Stored as JSON in dataTransfer.
 */
interface DragData {
  taskId: string;
  sourceSectionId: string;
}

interface GroupedTaskListProps {
  tasks: Task[];
  /** Unique identifier for this section (priority, categoryId, or chrono bucket key) */
  sectionId: string;
  emptyMessage?: string;
  showCompleted?: boolean;
  onEdit?: (task: Task) => void;
  className?: string;
  /**
   * Called when a task is dropped into this section from another section.
   * The parent should update the task's grouping field (priority, categories, or dueDate).
   */
  onTaskRegrouped?: (taskId: string, newSectionId: string, sourceSectionId: string) => void;
  /**
   * Called when a task is dropped directly onto another task (not in the gap between).
   * Creates a parent/child relationship.
   */
  onTaskNested?: (draggedTaskId: string, parentTaskId: string) => void;
  selectionMode?: boolean;
  selectedTaskIds?: string[];
  onToggleSelect?: (taskId: string) => void;
}

const DRAG_DATA_TYPE = 'application/x-grouped-task';

export function GroupedTaskList({
  tasks,
  sectionId,
  emptyMessage = 'No tasks yet',
  showCompleted = false,
  onEdit,
  className,
  onTaskRegrouped,
  onTaskNested,
  selectionMode = false,
  selectedTaskIds = [],
  onToggleSelect,
}: GroupedTaskListProps) {
  const [draggedId, setDraggedId] = useState<string | null>(null);
  const [dragOverId, setDragOverId] = useState<string | null>(null);
  const [isDragOverSection, setIsDragOverSection] = useState(false);
  const [nestTargetId, setNestTargetId] = useState<string | null>(null);
  const containerRef = useRef<HTMLDivElement>(null);

  // ---- Drag handlers for task items ----
  const handleDragStart = (e: React.DragEvent, taskId: string) => {
    if (selectionMode) return;
    setDraggedId(taskId);
    e.dataTransfer.effectAllowed = 'move';
    
    // Store drag data with section info for cross-section drops
    const dragData: DragData = { taskId, sourceSectionId: sectionId };
    e.dataTransfer.setData(DRAG_DATA_TYPE, JSON.stringify(dragData));
    e.dataTransfer.setData('text/plain', taskId);
  };

  const handleDragOver = (e: React.DragEvent, taskId: string) => {
    if (selectionMode) return;
    e.preventDefault();
    e.stopPropagation();
    e.dataTransfer.dropEffect = 'move';
    
    // Check if we're hovering directly over the task (for nesting) vs between tasks
    const target = e.currentTarget as HTMLElement;
    const rect = target.getBoundingClientRect();
    const y = e.clientY - rect.top;
    const height = rect.height;
    
    // If in the middle third of the task, it's a nest operation
    const isNestZone = y > height * 0.3 && y < height * 0.7;
    
    if (isNestZone && taskId !== draggedId) {
      setNestTargetId(taskId);
      setDragOverId(null);
    } else if (taskId !== draggedId) {
      setDragOverId(taskId);
      setNestTargetId(null);
    }
    
    setIsDragOverSection(false);
  };

  const handleDragLeave = (e: React.DragEvent) => {
    if (selectionMode) return;
    // Only clear if leaving the actual element (not entering a child)
    const relatedTarget = e.relatedTarget as HTMLElement;
    if (!e.currentTarget.contains(relatedTarget)) {
      setDragOverId(null);
      setNestTargetId(null);
    }
  };

  const handleDrop = (e: React.DragEvent, targetTaskId: string) => {
    if (selectionMode) return;
    e.preventDefault();
    e.stopPropagation();
    
    const rawData = e.dataTransfer.getData(DRAG_DATA_TYPE);
    if (!rawData) return;
    
    const dragData: DragData = JSON.parse(rawData);
    const { taskId: draggedTaskId, sourceSectionId } = dragData;
    
    // Check if this is a nest operation
    if (nestTargetId === targetTaskId && onTaskNested) {
      onTaskNested(draggedTaskId, targetTaskId);
    } else if (sourceSectionId !== sectionId && onTaskRegrouped) {
      // Cross-section drop - regroup the task
      onTaskRegrouped(draggedTaskId, sectionId, sourceSectionId);
    }
    // Within same section, we don't reorder (sorting is automatic)
    
    resetDragState();
  };

  const handleDragEnd = () => {
    if (selectionMode) return;
    resetDragState();
  };

  // ---- Section-level drag handlers (for dropping into empty sections or section background) ----
  const handleSectionDragOver = (e: React.DragEvent) => {
    if (selectionMode) return;
    e.preventDefault();
    e.dataTransfer.dropEffect = 'move';
    
    // Only show section highlight if not over a specific task
    if (!dragOverId && !nestTargetId) {
      setIsDragOverSection(true);
    }
  };

  const handleSectionDragLeave = (e: React.DragEvent) => {
    if (selectionMode) return;
    const relatedTarget = e.relatedTarget as HTMLElement;
    if (!containerRef.current?.contains(relatedTarget)) {
      setIsDragOverSection(false);
    }
  };

  const handleSectionDrop = (e: React.DragEvent) => {
    if (selectionMode) return;
    e.preventDefault();
    
    const rawData = e.dataTransfer.getData(DRAG_DATA_TYPE);
    if (!rawData) return;
    
    const dragData: DragData = JSON.parse(rawData);
    const { taskId: draggedTaskId, sourceSectionId } = dragData;
    
    // Only handle if dropping from a different section
    if (sourceSectionId !== sectionId && onTaskRegrouped) {
      onTaskRegrouped(draggedTaskId, sectionId, sourceSectionId);
    }
    
    resetDragState();
  };

  const resetDragState = () => {
    setDraggedId(null);
    setDragOverId(null);
    setNestTargetId(null);
    setIsDragOverSection(false);
  };

  // ---- Empty state ----
  if (tasks.length === 0) {
    return (
      <div
        ref={containerRef}
        onDragOver={handleSectionDragOver}
        onDragLeave={handleSectionDragLeave}
        onDrop={handleSectionDrop}
        className={cn(
          'flex items-center justify-center py-4 text-center rounded-lg transition-colors',
          isDragOverSection && 'bg-primary/10 ring-2 ring-primary/30 ring-dashed',
          className
        )}
      >
        <p className="text-muted-foreground/60 text-xs">
          {isDragOverSection ? 'Drop here to move task' : emptyMessage}
        </p>
      </div>
    );
  }

  return (
    <div
      ref={containerRef}
      onDragOver={handleSectionDragOver}
      onDragLeave={handleSectionDragLeave}
      onDrop={handleSectionDrop}
      className={cn(
        'space-y-2 rounded-lg transition-colors',
        isDragOverSection && 'bg-primary/5',
        className
      )}
    >
      {tasks.map((task) => (
        <div
          key={task.id}
          draggable={!selectionMode}
          onDragStart={(e) => handleDragStart(e, task.id)}
          onDragOver={(e) => handleDragOver(e, task.id)}
          onDragLeave={handleDragLeave}
          onDrop={(e) => handleDrop(e, task.id)}
          onDragEnd={handleDragEnd}
          className={cn(
            'transition-all duration-200',
            draggedId === task.id && 'opacity-50 scale-95',
            dragOverId === task.id && 'scale-[1.01] translate-y-1',
            nestTargetId === task.id && 'ring-2 ring-primary ring-offset-2 rounded-lg scale-[1.02]'
          )}
        >
          <TaskItem
            task={task}
            showCompleted={showCompleted}
            onEdit={onEdit}
            selectionMode={selectionMode}
            selected={selectedTaskIds.includes(task.id)}
            onSelectToggle={onToggleSelect}
          />
        </div>
      ))}
    </div>
  );
}
