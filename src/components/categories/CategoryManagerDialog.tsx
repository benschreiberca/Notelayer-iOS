import { useMemo, useState } from 'react';
import { GripVertical, Pencil } from 'lucide-react';
import { useAppStore } from '@/stores/useAppStore';
import { Category, CategoryId, DEFAULT_CATEGORIES } from '@/types';
import { cn } from '@/lib/utils';
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { toast } from '@/hooks/use-toast';

interface CategoryManagerDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
}

type FormMode = 'add' | 'edit' | null;

export function CategoryManagerDialog({ open, onOpenChange }: CategoryManagerDialogProps) {
  const categories = useAppStore((state) => state.categories);
  const addCategory = useAppStore((state) => state.addCategory);
  const updateCategory = useAppStore((state) => state.updateCategory);
  const reorderCategories = useAppStore((state) => state.reorderCategories);

  const [draggedId, setDraggedId] = useState<CategoryId | null>(null);
  const [dragOverId, setDragOverId] = useState<CategoryId | null>(null);

  const [formMode, setFormMode] = useState<FormMode>(null);
  const [formValues, setFormValues] = useState({
    id: '' as CategoryId,
    name: '',
    icon: '',
    color: '',
  });

  const colorOptions = useMemo(() => {
    const colors = [
      ...DEFAULT_CATEGORIES.map((category) => category.color),
      ...categories.map((category) => category.color),
    ];
    return Array.from(new Set(colors));
  }, [categories]);

  const resetForm = () => {
    setFormMode(null);
    setFormValues({ id: '', name: '', icon: '', color: '' });
  };

  const handleAddClick = () => {
    setFormMode('add');
    setFormValues({
      id: '',
      name: '',
      icon: '🏷️',
      color: colorOptions[0] ?? DEFAULT_CATEGORIES[0]?.color ?? 'category-house',
    });
  };

  const handleEditClick = (category: Category) => {
    setFormMode('edit');
    setFormValues({
      id: category.id,
      name: category.name,
      icon: category.icon,
      color: category.color,
    });
  };

  const handleSave = () => {
    const trimmedName = formValues.name.trim();
    if (!trimmedName) {
      toast({ title: 'Name required', description: 'Category name cannot be empty.' });
      return;
    }

    const duplicate = categories.some(
      (category) =>
        category.name.trim().toLowerCase() === trimmedName.toLowerCase() &&
        category.id !== formValues.id
    );

    if (duplicate) {
      toast({
        title: 'Duplicate category',
        description: 'Category names must be unique.',
        variant: 'destructive',
      });
      return;
    }

    const payload = {
      name: trimmedName,
      icon: formValues.icon.trim() || '🏷️',
      color: formValues.color || colorOptions[0] || DEFAULT_CATEGORIES[0]?.color || 'category-house',
    };

    if (formMode === 'edit' && formValues.id) {
      updateCategory(formValues.id, payload);
    } else {
      addCategory(payload);
    }

    resetForm();
  };

  const handleDragStart = (event: React.DragEvent, categoryId: CategoryId) => {
    setDraggedId(categoryId);
    event.dataTransfer.effectAllowed = 'move';
    event.dataTransfer.setData('text/plain', categoryId);
  };

  const handleDragOver = (event: React.DragEvent, categoryId: CategoryId) => {
    event.preventDefault();
    if (categoryId !== draggedId) {
      setDragOverId(categoryId);
    }
  };

  const handleDrop = (event: React.DragEvent, targetId: CategoryId) => {
    event.preventDefault();
    if (!draggedId || draggedId === targetId) {
      setDraggedId(null);
      setDragOverId(null);
      return;
    }

    const current = [...categories];
    const fromIndex = current.findIndex((category) => category.id === draggedId);
    const toIndex = current.findIndex((category) => category.id === targetId);

    if (fromIndex === -1 || toIndex === -1) {
      setDraggedId(null);
      setDragOverId(null);
      return;
    }

    const next = [...current];
    const [moved] = next.splice(fromIndex, 1);
    next.splice(toIndex, 0, moved);
    reorderCategories(next.map((category) => category.id));

    setDraggedId(null);
    setDragOverId(null);
  };

  const handleDragEnd = () => {
    setDraggedId(null);
    setDragOverId(null);
  };

  return (
    <Dialog
      open={open}
      onOpenChange={(nextOpen) => {
        onOpenChange(nextOpen);
        if (!nextOpen) resetForm();
      }}
    >
      <DialogContent className="w-[95vw] max-w-2xl max-h-[85vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle>Manage Categories</DialogTitle>
        </DialogHeader>

        <div className="space-y-4">
          <div className="flex items-center justify-between gap-3">
            <p className="text-sm text-muted-foreground">
              Drag categories to reorder. Tap a category to edit.
            </p>
            <Button size="sm" onClick={handleAddClick}>
              Add Category
            </Button>
          </div>

          {formMode && (
            <div className="rounded-xl border border-border/60 bg-muted/30 p-4 space-y-3">
              <div className="flex items-center gap-3">
                <div className="flex-1">
                  <label className="text-xs text-muted-foreground">Name</label>
                  <Input
                    value={formValues.name}
                    onChange={(event) =>
                      setFormValues((prev) => ({ ...prev, name: event.target.value }))
                    }
                    placeholder="Category name"
                    className="mt-1"
                  />
                </div>
                <div className="w-24">
                  <label className="text-xs text-muted-foreground">Icon</label>
                  <Input
                    value={formValues.icon}
                    onChange={(event) =>
                      setFormValues((prev) => ({ ...prev, icon: event.target.value }))
                    }
                    placeholder="🏷️"
                    className="mt-1 text-center"
                  />
                </div>
              </div>

              <div>
                <label className="text-xs text-muted-foreground">Color</label>
                <div className="flex flex-wrap gap-2 mt-2">
                  {colorOptions.map((color) => (
                    <button
                      key={color}
                      type="button"
                      onClick={() => setFormValues((prev) => ({ ...prev, color }))}
                      className={cn(
                        'w-8 h-8 rounded-full border-2 flex items-center justify-center text-xs transition',
                        color,
                        formValues.color === color ? 'ring-2 ring-primary/40 border-primary' : 'border-transparent'
                      )}
                      aria-label={`Select ${color}`}
                    >
                      {formValues.color === color ? '✓' : ''}
                    </button>
                  ))}
                </div>
              </div>

              <div className="flex justify-end gap-2">
                <Button variant="ghost" size="sm" onClick={resetForm}>
                  Cancel
                </Button>
                <Button size="sm" onClick={handleSave}>
                  {formMode === 'edit' ? 'Save Changes' : 'Add Category'}
                </Button>
              </div>
            </div>
          )}

          <div className="space-y-2">
            {categories.map((category) => (
              <div
                key={category.id}
                draggable
                onDragStart={(event) => handleDragStart(event, category.id)}
                onDragOver={(event) => handleDragOver(event, category.id)}
                onDrop={(event) => handleDrop(event, category.id)}
                onDragEnd={handleDragEnd}
                onClick={() => handleEditClick(category)}
                className={cn(
                  'flex items-center justify-between gap-3 rounded-xl border border-border/60 bg-card px-3 py-2 transition',
                  dragOverId === category.id && 'ring-2 ring-primary/30'
                )}
              >
                <div className="flex items-center gap-3">
                  <GripVertical className="h-4 w-4 text-muted-foreground" />
                  <div
                    className={cn(
                      'flex h-8 w-8 items-center justify-center rounded-full text-sm',
                      category.color
                    )}
                  >
                    {category.icon}
                  </div>
                  <div>
                    <p className="text-sm font-medium">{category.name}</p>
                    <p className="text-xs text-muted-foreground">{category.id}</p>
                  </div>
                </div>
                <Button
                  type="button"
                  variant="ghost"
                  size="icon"
                  onClick={(event) => {
                    event.stopPropagation();
                    handleEditClick(category);
                  }}
                  aria-label={`Edit ${category.name}`}
                >
                  <Pencil className="h-4 w-4" />
                </Button>
              </div>
            ))}
          </div>
        </div>
      </DialogContent>
    </Dialog>
  );
}
