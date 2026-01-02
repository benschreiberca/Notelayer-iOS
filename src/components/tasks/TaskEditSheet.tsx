import { useState, useEffect } from 'react';
import { Calendar, Trash2, Check, FileText, Link as LinkIcon } from 'lucide-react';
import { format, addDays, endOfWeek, endOfMonth } from 'date-fns';
import { cn } from '@/lib/utils';
import { Task, CATEGORIES, CategoryId, Priority, PRIORITY_CONFIG } from '@/types';
import { useAppStore } from '@/stores/useAppStore';
import { Sheet, SheetContent, SheetHeader, SheetTitle } from '@/components/ui/sheet';
import { Calendar as CalendarComponent } from '@/components/ui/calendar';
import { Popover, PopoverContent, PopoverTrigger } from '@/components/ui/popover';
import { Button } from '@/components/ui/button';
import { Textarea } from '@/components/ui/textarea';

interface TaskEditSheetProps {
  task: Task | null;
  open: boolean;
  onOpenChange: (open: boolean) => void;
}

const quickDateOptions = [
  { label: 'Today', getValue: () => new Date() },
  { label: 'Tomorrow', getValue: () => addDays(new Date(), 1) },
  { label: 'This Week', getValue: () => endOfWeek(new Date()) },
  { label: 'This Month', getValue: () => endOfMonth(new Date()) },
  { label: 'No Date', getValue: () => undefined },
];

export function TaskEditSheet({ task, open, onOpenChange }: TaskEditSheetProps) {
  const { updateTask, deleteTask, notes } = useAppStore();
  
  const [title, setTitle] = useState('');
  const [selectedCategories, setSelectedCategories] = useState<CategoryId[]>([]);
  const [priority, setPriority] = useState<Priority>('medium');
  const [dueDate, setDueDate] = useState<Date | undefined>();
  const [showCustomDate, setShowCustomDate] = useState(false);
  const [taskNotes, setTaskNotes] = useState('');

  // Get linked note if exists
  const linkedNote = task?.noteId ? notes.find((n) => n.id === task.noteId) : null;

  useEffect(() => {
    if (task) {
      setTitle(task.title);
      setSelectedCategories(task.categories);
      setPriority(task.priority);
      setDueDate(task.dueDate ? new Date(task.dueDate) : undefined);
      setTaskNotes(task.taskNotes || '');
    }
  }, [task]);

  const handleSave = () => {
    if (!task || !title.trim()) return;
    
    updateTask(task.id, {
      title: title.trim(),
      categories: selectedCategories,
      priority,
      dueDate,
      taskNotes: taskNotes.trim() || undefined,
    });
    
    onOpenChange(false);
  };

  const handleDelete = () => {
    if (!task) return;
    deleteTask(task.id);
    onOpenChange(false);
  };

  const toggleCategory = (categoryId: CategoryId) => {
    setSelectedCategories((prev) =>
      prev.includes(categoryId)
        ? prev.filter((c) => c !== categoryId)
        : [...prev, categoryId]
    );
  };

  const handleQuickDate = (getValue: () => Date | undefined) => {
    setDueDate(getValue());
  };

  if (!task) return null;

  return (
    <Sheet open={open} onOpenChange={onOpenChange}>
      <SheetContent side="bottom" className="h-[85vh] max-h-[85vh]" hideCloseButton>
        {/* iOS-style header with actions */}
        <SheetHeader>
          <div className="flex items-center justify-between">
            <SheetTitle className="text-lg font-semibold">Edit Task</SheetTitle>
            <div className="flex items-center gap-1">
              <Button
                variant="ghost"
                size="icon"
                onClick={handleDelete}
                className="w-11 h-11 rounded-full text-destructive hover:text-destructive hover:bg-destructive/10"
              >
                <Trash2 className="w-5 h-5" />
              </Button>
              <Button
                variant="ghost"
                size="icon"
                onClick={handleSave}
                className="w-11 h-11 rounded-full text-primary hover:bg-primary/10"
              >
                <Check className="w-5 h-5" />
              </Button>
            </div>
          </div>
        </SheetHeader>

        {/* Scrollable content area */}
        <div className="flex flex-col gap-6 flex-1 min-h-0 overflow-y-auto -mx-5 px-5 pb-4 overscroll-contain">
          {/* Title */}
          <div>
            <label className="text-sm font-medium text-muted-foreground mb-2 block">
              Title
            </label>
            <input
              type="text"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              className="w-full px-4 py-3 rounded-xl bg-muted border border-border/50 text-foreground placeholder:text-muted-foreground outline-none focus:ring-2 focus:ring-primary/20 transition-all"
              placeholder="Task title..."
            />
          </div>

          {/* Categories */}
          <div>
            <label className="text-sm font-medium text-muted-foreground mb-3 block">
              Categories
            </label>
            <div className="flex flex-wrap gap-2">
              {CATEGORIES.map((category) => (
                <button
                  key={category.id}
                  type="button"
                  onClick={() => toggleCategory(category.id)}
                  className={cn(
                    'inline-flex items-center gap-1.5 px-3 py-2 rounded-xl text-sm font-medium transition-all duration-200 tap-highlight active:scale-95',
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
            <label className="text-sm font-medium text-muted-foreground mb-3 block">
              Priority
            </label>
            <div className="flex gap-2">
              {(['high', 'medium', 'low', 'deferred'] as Priority[]).map((p) => (
                <button
                  key={p}
                  type="button"
                  onClick={() => setPriority(p)}
                  className={cn(
                    'flex-1 py-2.5 rounded-xl text-sm font-medium transition-all duration-200 capitalize tap-highlight active:scale-95',
                    priority === p
                      ? `priority-${p}`
                      : 'bg-secondary text-secondary-foreground hover:bg-secondary/80'
                  )}
                >
                  {PRIORITY_CONFIG[p].label}
                </button>
              ))}
            </div>
          </div>

          {/* Due Date */}
          <div>
            <label className="text-sm font-medium text-muted-foreground mb-3 block">
              Due Date
            </label>
            
            {/* Quick Date Options */}
            <div className="flex flex-wrap gap-2 mb-3">
              {quickDateOptions.map((option) => (
                <button
                  key={option.label}
                  type="button"
                  onClick={() => handleQuickDate(option.getValue)}
                  className={cn(
                    'px-4 py-2 rounded-xl text-sm font-medium transition-all duration-200 tap-highlight active:scale-95',
                    (option.label === 'No Date' && !dueDate) ||
                    (option.label === 'Today' && dueDate && format(dueDate, 'yyyy-MM-dd') === format(new Date(), 'yyyy-MM-dd')) ||
                    (option.label === 'Tomorrow' && dueDate && format(dueDate, 'yyyy-MM-dd') === format(addDays(new Date(), 1), 'yyyy-MM-dd'))
                      ? 'bg-primary text-primary-foreground'
                      : 'bg-secondary text-secondary-foreground hover:bg-secondary/80'
                  )}
                >
                  {option.label}
                </button>
              ))}
            </div>

            {/* Custom Date Picker */}
            <Popover open={showCustomDate} onOpenChange={setShowCustomDate}>
              <PopoverTrigger asChild>
                <button
                  type="button"
                  className={cn(
                    'w-full flex items-center gap-3 px-4 py-3 rounded-xl text-sm transition-all duration-200',
                    'bg-secondary text-secondary-foreground hover:bg-secondary/80'
                  )}
                >
                  <Calendar className="w-5 h-5 text-muted-foreground" />
                  <span>
                    {dueDate 
                      ? format(dueDate, 'EEEE, MMMM d, yyyy')
                      : 'Select custom date...'
                    }
                  </span>
                </button>
              </PopoverTrigger>
              <PopoverContent className="w-auto p-0" align="center">
                <CalendarComponent
                  mode="single"
                  selected={dueDate}
                  onSelect={(date) => {
                    setDueDate(date);
                    setShowCustomDate(false);
                  }}
                  initialFocus
                  className="p-3 pointer-events-auto"
                />
              </PopoverContent>
            </Popover>
          </div>

          {/* Notes / Details */}
          <div>
            <label className="text-sm font-medium text-muted-foreground mb-3 block">
              Notes & Details
            </label>
            <Textarea
              value={taskNotes}
              onChange={(e) => setTaskNotes(e.target.value)}
              placeholder="Add references, additional details, links..."
              className="min-h-[100px] resize-none rounded-xl bg-muted border-border/50"
            />
          </div>

          {/* Linked Note */}
          {linkedNote && (
            <div>
              <label className="text-sm font-medium text-muted-foreground mb-3 block">
                Linked Note
              </label>
              <div className="flex items-center gap-3 px-4 py-3 rounded-xl bg-primary/10 border border-primary/20">
                <FileText className="w-5 h-5 text-primary" />
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-medium text-foreground truncate">
                    {linkedNote.title}
                  </p>
                  <p className="text-xs text-muted-foreground truncate">
                    {linkedNote.plainText?.substring(0, 50) || 'No content'}...
                  </p>
                </div>
                <LinkIcon className="w-4 h-4 text-primary" />
              </div>
            </div>
          )}
        </div>
      </SheetContent>
    </Sheet>
  );
}
