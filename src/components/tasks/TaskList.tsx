import { Task } from '@/types';
import { TaskItem } from './TaskItem';
import { cn } from '@/lib/utils';

interface TaskListProps {
  tasks: Task[];
  emptyMessage?: string;
  showCompleted?: boolean;
  onEdit?: (task: Task) => void;
  className?: string;
}

export function TaskList({
  tasks,
  emptyMessage = 'No tasks yet',
  showCompleted = false,
  onEdit,
  className,
}: TaskListProps) {
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
          className="animate-slide-up"
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
