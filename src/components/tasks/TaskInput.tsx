import { useState } from 'react';
import { Plus, Mic, ArrowRight } from 'lucide-react';
import { cn } from '@/lib/utils';
import { CategoryId, Priority, PRIORITY_CONFIG } from '@/types';
import { useAppStore } from '@/stores/useAppStore';
import { PriorityIcon } from '@/components/common/PriorityIcon';
import { CategoryManagerDialog } from '@/components/categories/CategoryManagerDialog';

interface TaskInputProps {
  defaultCategories?: CategoryId[];
  defaultPriority?: Priority;
  onTaskCreated?: (taskId: string) => void;
  className?: string;
}

export function TaskInput({
  defaultCategories = [],
  defaultPriority = 'medium',
  onTaskCreated,
  className,
}: TaskInputProps) {
  const [title, setTitle] = useState('');
  const [selectedCategories, setSelectedCategories] = useState<CategoryId[]>(defaultCategories);
  const [priority, setPriority] = useState<Priority>(defaultPriority);
  const [isExpanded, setIsExpanded] = useState(false);
  const [manageOpen, setManageOpen] = useState(false);
  
  const addTask = useAppStore((state) => state.addTask);
  const categories = useAppStore((state) => state.categories);

  const handleSubmit = () => {
    if (!title.trim()) return;
    
    const taskId = addTask({
      title: title.trim(),
      categories: selectedCategories,
      priority,
      attachments: [],
      inputMethod: 'text',
    });
    
    setTitle('');
    setSelectedCategories(defaultCategories);
    setPriority(defaultPriority);
    setIsExpanded(false);
    onTaskCreated?.(taskId);
  };

  const toggleCategory = (categoryId: CategoryId) => {
    setSelectedCategories((prev) =>
      prev.includes(categoryId)
        ? prev.filter((c) => c !== categoryId)
        : [...prev, categoryId]
    );
  };

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSubmit();
    }
  };

  return (
    <div
      className={cn(
        'w-full max-w-[520px] mx-auto border transition-all duration-300',
        isExpanded
          ? 'bg-card rounded-xl shadow-card border-border/50 p-4'
          : 'bg-muted/50 rounded-full border-dashed border-muted-foreground/30 px-4 py-2 shadow-none hover:bg-muted/70',
        className
      )}
    >
      {/* Input Row */}
      <div className="flex items-center gap-3">
        <div className="w-6 h-6 rounded-full bg-primary/10 flex items-center justify-center flex-shrink-0">
          <Plus className="w-4 h-4 text-primary" />
        </div>
        
        <input
          type="text"
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          onFocus={() => setIsExpanded(true)}
          onKeyDown={handleKeyDown}
          placeholder="New task..."
          className="flex-1 bg-transparent text-foreground placeholder:text-muted-foreground outline-none text-sm"
        />
        
        <div className="flex items-center gap-2">
          <button
            type="button"
            className="p-2 rounded-lg text-muted-foreground hover:text-foreground hover:bg-muted/50 transition-colors"
          >
            <Mic className="w-4 h-4" />
          </button>
          
          {title.trim() && (
            <button
              type="button"
              onClick={handleSubmit}
              className="p-2 rounded-lg bg-primary text-primary-foreground hover:bg-primary/90 transition-colors animate-scale-in"
            >
              <ArrowRight className="w-4 h-4" />
            </button>
          )}
        </div>
      </div>

      {/* Expanded Options */}
      {isExpanded && (
        <div className="mt-4 space-y-3 animate-slide-up">
          {/* Category Chips */}
          <div className="flex flex-wrap gap-2">
            {categories.map((category) => (
              <button
                key={category.id}
                type="button"
                onClick={() => toggleCategory(category.id)}
                className={cn(
                  'inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-medium transition-all duration-200 tap-highlight active:scale-95',
                  selectedCategories.includes(category.id)
                    ? category.color
                    : 'bg-secondary text-secondary-foreground hover:bg-secondary/80'
                )}
              >
                <span>{category.icon}</span>
                <span>{category.name}</span>
              </button>
            ))}
          </div>
          <button
            type="button"
            onClick={() => setManageOpen(true)}
            className="text-xs text-primary hover:text-primary/80 transition-colors"
          >
            Manage Categories
          </button>

          {/* Priority Row */}
          <div className="flex items-center gap-2">
            <span className="text-xs text-muted-foreground mr-1">Priority:</span>
            {(['high', 'medium', 'low', 'deferred'] as Priority[]).map((p) => (
              <button
                key={p}
                type="button"
                onClick={() => setPriority(p)}
                className={cn(
                  'flex items-center gap-1.5 px-2.5 py-1.5 rounded-full text-xs font-medium transition-all duration-200 tap-highlight active:scale-95',
                  priority === p
                    ? `priority-${p}`
                    : 'bg-secondary text-secondary-foreground hover:bg-secondary/80'
                )}
              >
                <PriorityIcon 
                  priority={p} 
                  size="xs" 
                  className={priority === p ? 'text-white' : ''} 
                />
                <span>{PRIORITY_CONFIG[p].label}</span>
              </button>
            ))}
          </div>
        </div>
      )}
      <CategoryManagerDialog open={manageOpen} onOpenChange={setManageOpen} />
    </div>
  );
}
