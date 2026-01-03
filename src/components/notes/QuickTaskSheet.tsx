import { useState, useRef, useCallback } from 'react';
import { ArrowRight } from 'lucide-react';
import { cn } from '@/lib/utils';
import { CATEGORIES, CategoryId, Priority, PRIORITY_CONFIG } from '@/types';
import { useAppStore } from '@/stores/useAppStore';
import { Sheet, SheetContent, SheetHeader, SheetTitle } from '@/components/ui/sheet';
import { PriorityIcon } from '@/components/common/PriorityIcon';

interface QuickTaskSheetProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  initialTitle?: string;
  noteId?: string;
}

export function QuickTaskSheet({ open, onOpenChange, initialTitle = '', noteId }: QuickTaskSheetProps) {
  const addTask = useAppStore((state) => state.addTask);
  
  const [title, setTitle] = useState(initialTitle);
  const [selectedCategories, setSelectedCategories] = useState<CategoryId[]>([]);
  const [priority, setPriority] = useState<Priority>('medium');

  const handleSubmit = () => {
    if (!title.trim()) return;
    
    addTask({
      title: title.trim(),
      categories: selectedCategories,
      priority,
      attachments: [],
      inputMethod: 'text',
      noteId,
    });
    
    setTitle('');
    setSelectedCategories([]);
    setPriority('medium');
    onOpenChange(false);
  };

  const toggleCategory = (categoryId: CategoryId) => {
    setSelectedCategories((prev) =>
      prev.includes(categoryId)
        ? prev.filter((c) => c !== categoryId)
        : [...prev, categoryId]
    );
  };

  // Update title when initialTitle changes (when sheet opens)
  useEffect(() => {
    if (open) {
      setTitle(initialTitle);
    }
  }, [open, initialTitle]);

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSubmit();
    }
  };

  return (
    <Sheet open={open} onOpenChange={onOpenChange}>
      <SheetContent side="bottom" className="max-h-[60vh] rounded-t-3xl flex flex-col p-0">
        <SheetHeader className="pb-4 pt-6 px-6 flex-shrink-0">
          <SheetTitle>Create Task from Note</SheetTitle>
        </SheetHeader>

        <div 
          className="flex flex-col gap-4 overflow-y-auto overflow-x-hidden flex-1 min-h-0 px-6 pb-8 overscroll-contain"
          style={{ 
            WebkitOverflowScrolling: 'touch',
            touchAction: 'pan-y'
          } as React.CSSProperties}
        >
          {/* Title Input */}
          <div className="flex items-center gap-3 p-3 bg-muted rounded-xl">
            <input
              type="text"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              onKeyDown={handleKeyDown}
              placeholder="Task title..."
              autoFocus
              className="flex-1 bg-transparent text-foreground placeholder:text-muted-foreground outline-none"
            />
            {title.trim() && (
              <button
                type="button"
                onClick={handleSubmit}
                className="p-2 rounded-lg bg-primary text-primary-foreground hover:bg-primary/90 transition-colors"
              >
                <ArrowRight className="w-5 h-5" />
              </button>
            )}
          </div>

          {/* Categories */}
          <div>
            <label className="text-xs font-medium text-muted-foreground mb-2 block">
              Categories
            </label>
            <div className="flex flex-wrap gap-2">
              {CATEGORIES.map((category) => (
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
          </div>

          {/* Priority */}
          <div>
            <label className="text-xs font-medium text-muted-foreground mb-2 block">
              Priority
            </label>
            <div className="flex gap-2">
              {(['high', 'medium', 'low', 'deferred'] as Priority[]).map((p) => (
                <button
                  key={p}
                  type="button"
                  onClick={() => setPriority(p)}
                  className={cn(
                    'flex-1 flex flex-col items-center gap-1 py-2.5 rounded-lg text-xs font-medium transition-all duration-200 tap-highlight active:scale-95',
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
        </div>
      </SheetContent>
    </Sheet>
  );
}
