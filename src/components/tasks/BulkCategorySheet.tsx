import { useEffect, useState } from 'react';
import { CategoryId } from '@/types';
import { useAppStore } from '@/stores/useAppStore';
import { Sheet, SheetContent, SheetHeader, SheetTitle } from '@/components/ui/sheet';
import { Button } from '@/components/ui/button';
import { CategoryChip } from '@/components/common/CategoryChip';
import { cn } from '@/lib/utils';
import { toast } from '@/hooks/use-toast';

interface BulkCategorySheetProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  selectedTaskIds: string[];
}

type BulkMode = 'add' | 'remove';

export function BulkCategorySheet({ open, onOpenChange, selectedTaskIds }: BulkCategorySheetProps) {
  const categories = useAppStore((state) => state.categories);
  const bulkUpdateTaskCategories = useAppStore((state) => state.bulkUpdateTaskCategories);
  const [mode, setMode] = useState<BulkMode>('add');
  const [selectedCategories, setSelectedCategories] = useState<CategoryId[]>([]);
  const [isSaving, setIsSaving] = useState(false);

  useEffect(() => {
    if (!open) {
      setSelectedCategories([]);
      setMode('add');
      setIsSaving(false);
    }
  }, [open]);

  useEffect(() => {
    setSelectedCategories([]);
  }, [mode]);

  const toggleCategory = (categoryId: CategoryId) => {
    setSelectedCategories((prev) =>
      prev.includes(categoryId) ? prev.filter((id) => id !== categoryId) : [...prev, categoryId]
    );
  };

  const handleApply = async () => {
    if (selectedCategories.length === 0) {
      toast({
        title: 'Select categories',
        description: `Choose categories to ${mode === 'add' ? 'add' : 'remove'}.`,
      });
      return;
    }

    setIsSaving(true);
    const success = await bulkUpdateTaskCategories(selectedTaskIds, {
      add: mode === 'add' ? selectedCategories : [],
      remove: mode === 'remove' ? selectedCategories : [],
    });
    setIsSaving(false);

    if (!success) {
      toast({
        title: 'Update failed',
        description: 'Categories were not updated. Please try again.',
        variant: 'destructive',
      });
      return;
    }

    onOpenChange(false);
  };

  return (
    <Sheet open={open} onOpenChange={onOpenChange}>
      <SheetContent side="bottom" className="h-[70vh] rounded-t-3xl flex flex-col p-0">
        <SheetHeader className="px-6 pt-6 pb-4">
          <SheetTitle>Edit Categories</SheetTitle>
          <p className="text-xs text-muted-foreground">
            {selectedTaskIds.length} selected
          </p>
        </SheetHeader>

        <div className="flex-1 overflow-y-auto px-6 pb-6 space-y-4">
          <div className="flex items-center gap-2">
            {(['add', 'remove'] as BulkMode[]).map((option) => (
              <button
                key={option}
                type="button"
                onClick={() => setMode(option)}
                className={cn(
                  'flex-1 px-3 py-2 rounded-lg text-sm font-medium transition-all',
                  mode === option
                    ? 'bg-primary text-primary-foreground'
                    : 'bg-muted text-muted-foreground hover:text-foreground'
                )}
              >
                {option === 'add' ? 'Add' : 'Remove'}
              </button>
            ))}
          </div>

          <div>
            <p className="text-xs text-muted-foreground mb-2">
              {mode === 'add' ? 'Add categories to selected tasks:' : 'Remove categories from selected tasks:'}
            </p>
            <div className="flex flex-wrap gap-2">
              {categories.map((category) => (
                <CategoryChip
                  key={category.id}
                  categoryId={category.id}
                  selected={selectedCategories.includes(category.id)}
                  onClick={() => toggleCategory(category.id)}
                />
              ))}
            </div>
          </div>
        </div>

        <div className="px-6 pb-6 pt-2 flex gap-3">
          <Button variant="ghost" className="flex-1" onClick={() => onOpenChange(false)}>
            Cancel
          </Button>
          <Button className="flex-1" onClick={handleApply} disabled={isSaving}>
            {isSaving ? 'Saving...' : mode === 'add' ? 'Add Categories' : 'Remove Categories'}
          </Button>
        </div>
      </SheetContent>
    </Sheet>
  );
}
