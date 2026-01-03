import { useState, useCallback, useEffect } from 'react';
import {
  Calendar,
  Trash2,
  FileText,
  Link as LinkIcon,
  CalendarPlus,
  Share2,
  X,
} from 'lucide-react';
import { format, addDays, endOfWeek, endOfMonth } from 'date-fns';
import { cn } from '@/lib/utils';
import { Task, CATEGORIES, CategoryId, Priority, PRIORITY_CONFIG } from '@/types';
import { useAppStore } from '@/stores/useAppStore';
import { toast } from '@/hooks/use-toast';
import { Sheet, SheetContent, SheetHeader, SheetTitle } from '@/components/ui/sheet';
import { Calendar as CalendarComponent } from '@/components/ui/calendar';
import { Popover, PopoverContent, PopoverTrigger } from '@/components/ui/popover';
import { Button } from '@/components/ui/button';
import { Textarea } from '@/components/ui/textarea';
import { PriorityIcon } from '@/components/common/PriorityIcon';

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

  const handleSave = useCallback(() => {
    if (!task || !title.trim()) return;

    updateTask(task.id, {
      title: title.trim(),
      categories: selectedCategories,
      priority,
      dueDate,
      taskNotes: taskNotes.trim() || undefined,
    });

    onOpenChange(false);
  }, [task, title, selectedCategories, priority, dueDate, taskNotes, updateTask, onOpenChange]);

  const handleDelete = useCallback(() => {
    if (!task) return;
    deleteTask(task.id);
    onOpenChange(false);
    toast({
      title: 'Task deleted',
      description: 'The task has been permanently deleted.',
    });
  }, [task, deleteTask, onOpenChange]);

  /**
   * Add to Google Calendar
   * - Ensures it is NOT all-day by always providing a start+end datetime.
   * - Default: 9:00 AM local, 15 minutes duration.
   * - Uses UTC-formatted timestamps for `dates=` and includes `ctz=` for correct display.
   */
  const handleAddToCalendar = useCallback(() => {
    if (!task) return;

    const DEFAULT_START_HOUR = 9; // 9:00 AM local
    const DEFAULT_START_MIN = 0;
    const DEFAULT_DURATION_MIN = 15;

    // Base date: dueDate (if set) otherwise today
    const base = dueDate ? new Date(dueDate) : new Date();

    // Force a concrete local time
    const startLocal = new Date(base);
    startLocal.setHours(DEFAULT_START_HOUR, DEFAULT_START_MIN, 0, 0);

    const endLocal = new Date(startLocal.getTime() + DEFAULT_DURATION_MIN * 60 * 1000);

    // Google expects UTC strings like 20260103T140000Z
    const toGcalUtc = (d: Date) => {
      const pad = (n: number) => String(n).padStart(2, '0');
      return (
        d.getUTCFullYear().toString() +
        pad(d.getUTCMonth() + 1) +
        pad(d.getUTCDate()) +
        'T' +
        pad(d.getUTCHours()) +
        pad(d.getUTCMinutes()) +
        pad(d.getUTCSeconds()) +
        'Z'
      );
    };

    const eventTitle = encodeURIComponent(task.title);
    const eventDetails = encodeURIComponent(taskNotes || '');
    const dates = `${toGcalUtc(startLocal)}/${toGcalUtc(endLocal)}`;

    const timezone = Intl.DateTimeFormat().resolvedOptions().timeZone || 'America/Toronto';

    const googleCalUrl =
      `https://calendar.google.com/calendar/render` +
      `?action=TEMPLATE` +
      `&text=${eventTitle}` +
      `&dates=${dates}` +
      `&details=${eventDetails}` +
      `&ctz=${encodeURIComponent(timezone)}`;

    window.open(googleCalUrl, '_blank', 'noopener,noreferrer');

    toast({
      title: 'Opening calendar',
      description: 'Add this task to your calendar.',
    });
  }, [task, dueDate, taskNotes]);

  const handleShare = useCallback(async () => {
    if (!task) return;

    const shareData = {
      title: task.title,
      text: `Task: ${task.title}${dueDate ? `\nDue: ${format(dueDate, 'PPP')}` : ''}${
        taskNotes ? `\n\n${taskNotes}` : ''
      }`,
    };

    if (navigator.share) {
      try {
        await navigator.share(shareData);
      } catch (err) {
        if ((err as Error).name !== 'AbortError') {
          toast({
            title: 'Share failed',
            description: 'Could not share the task.',
            variant: 'destructive',
          });
        }
      }
    } else {
      try {
        await navigator.clipboard.writeText(shareData.text);
        toast({
          title: 'Copied to clipboard',
          description: 'Task details copied to clipboard.',
        });
      } catch {
        toast({
          title: 'Share not available',
          description: 'Sharing is not supported on this device.',
          variant: 'destructive',
        });
      }
    }
  }, [task, dueDate, taskNotes]);

  const toggleCategory = (categoryId: CategoryId) => {
    setSelectedCategories((prev) =>
      prev.includes(categoryId) ? prev.filter((c) => c !== categoryId) : [...prev, categoryId],
    );
  };

  const handleQuickDate = (getValue: () => Date | undefined) => {
    setDueDate(getValue());
  };

  const handleTitleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSave();
    }
  };

  if (!task) return null;

  return (
    <Sheet open={open} onOpenChange={onOpenChange}>
      <SheetContent side="bottom" className="h-[85vh] rounded-t-3xl flex flex-col p-0 [&>button]:hidden">
        <SheetHeader className="px-6 pt-6 pb-4 flex-shrink-0">
          <div className="flex items-center justify-between">
            <SheetTitle>Edit Task</SheetTitle>
            <div className="flex items-center gap-4">
              <Button
                variant="ghost"
                size="icon"
                onClick={handleAddToCalendar}
                className="text-muted-foreground hover:text-foreground h-10 w-10"
                title="Add to Calendar"
              >
                <CalendarPlus className="w-5 h-5" />
              </Button>

              <Button
                variant="ghost"
                size="icon"
                onClick={handleShare}
                className="text-muted-foreground hover:text-foreground h-10 w-10"
                title="Share"
              >
                <Share2 className="w-5 h-5" />
              </Button>

              <Button
                variant="ghost"
                size="icon"
                onClick={handleSave}
                className="text-primary h-10 w-10"
                title="Save & Close"
              >
                <X className="w-5 h-5" />
              </Button>
            </div>
          </div>
        </SheetHeader>

        <div className="flex flex-col gap-6 overflow-y-auto pb-8 px-6 flex-1 min-h-0">
          <div>
            <label className="text-sm font-medium text-muted-foreground mb-2 block">Title</label>
            <input
              type="text"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              onKeyDown={handleTitleKeyDown}
              className="w-full px-4 py-3 rounded-xl bg-muted border border-border/50 text-foreground placeholder:text-muted-foreground outline-none focus:ring-2 focus:ring-primary/20 transition-all"
              placeholder="Task title..."
            />
          </div>

          <div>
            <label className="text-sm font-medium text-muted-foreground mb-3 block">Categories</label>
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
                      : 'bg-secondary text-secondary-foreground hover:bg-secondary/80',
                  )}
                >
                  <span>{category.icon}</span>
                  <span>{category.name}</span>
                </button>
              ))}
            </div>
          </div>

          <div>
            <label className="text-sm font-medium text-muted-foreground mb-3 block">Priority</label>
            <div className="flex gap-2">
              {(['high', 'medium', 'low', 'deferred'] as Priority[]).map((p) => (
                <button
                  key={p}
                  type="button"
                  onClick={() => setPriority(p)}
                  className={cn(
                    'flex-1 flex flex-col items-center gap-1.5 py-3 rounded-xl text-sm font-medium transition-all duration-200 tap-highlight active:scale-95',
                    priority === p ? `priority-${p}` : 'bg-secondary text-secondary-foreground hover:bg-secondary/80',
                  )}
                >
                  <PriorityIcon priority={p} size="sm" className={priority === p ? 'text-white' : ''} />
                  <span>{PRIORITY_CONFIG[p].label}</span>
                </button>
              ))}
            </div>
          </div>

          <div>
            <label className="text-sm font-medium text-muted-foreground mb-3 block">Due Date</label>

            <div className="flex flex-wrap gap-2 mb-3">
              {quickDateOptions.map((option) => (
                <button
                  key={option.label}
                  type="button"
                  onClick={() => handleQuickDate(option.getValue)}
                  className={cn(
                    'px-4 py-2 rounded-xl text-sm font-medium transition-all duration-200 tap-highlight active:scale-95',
                    (option.label === 'No Date' && !dueDate) ||
                      (option.label === 'Today' &&
                        dueDate &&
                        format(dueDate, 'yyyy-MM-dd') === format(new Date(), 'yyyy-MM-dd')) ||
                      (option.label === 'Tomorrow' &&
                        dueDate &&
                        format(dueDate, 'yyyy-MM-dd') === format(addDays(new Date(), 1), 'yyyy-MM-dd'))
                      ? 'bg-primary text-primary-foreground'
                      : 'bg-secondary text-secondary-foreground hover:bg-secondary/80',
                  )}
                >
                  {option.label}
                </button>
              ))}
            </div>

            <Popover open={showCustomDate} onOpenChange={setShowCustomDate}>
              <PopoverTrigger asChild>
                <button
                  type="button"
                  className={cn(
                    'w-full flex items-center gap-3 px-4 py-3 rounded-xl text-sm transition-all duration-200',
                    'bg-secondary text-secondary-foreground hover:bg-secondary/80',
                  )}
                >
                  <Calendar className="w-5 h-5 text-muted-foreground" />
                  <span>{dueDate ? format(dueDate, 'EEEE, MMMM d, yyyy') : 'Select custom date...'}</span>
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

          <div>
            <label className="text-sm font-medium text-muted-foreground mb-3 block">Notes & Details</label>
            <Textarea
              value={taskNotes}
              onChange={(e) => setTaskNotes(e.target.value)}
              placeholder="Add references, additional details, links..."
              className="min-h-[100px] resize-none rounded-xl bg-muted border-border/50"
            />
          </div>

          {linkedNote && (
            <div>
              <label className="text-sm font-medium text-muted-foreground mb-3 block">Linked Note</label>
              <div className="flex items-center gap-3 px-4 py-3 rounded-xl bg-primary/10 border border-primary/20">
                <FileText className="w-5 h-5 text-primary" />
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-medium text-foreground truncate">{linkedNote.title}</p>
                  <p className="text-xs text-muted-foreground truncate">
                    {linkedNote.plainText?.substring(0, 50) || 'No content'}...
                  </p>
                </div>
                <LinkIcon className="w-4 h-4 text-primary" />
              </div>
            </div>
          )}

          <div className="flex-1 min-h-[20px]" />

          <div className="pt-4 border-t border-border/50">
            <Button
              variant="ghost"
              onClick={handleDelete}
              className="w-full justify-center text-destructive hover:text-destructive hover:bg-destructive/10 py-3"
            >
              <Trash2 className="w-5 h-5 mr-2" />
              Delete Task
            </Button>
          </div>
        </div>
      </SheetContent>
    </Sheet>
  );
}
