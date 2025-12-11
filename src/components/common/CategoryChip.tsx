import { cn } from '@/lib/utils';
import { CATEGORIES, CategoryId } from '@/types';

interface CategoryChipProps {
  categoryId: CategoryId;
  selected?: boolean;
  size?: 'sm' | 'md';
  onClick?: () => void;
}

export function CategoryChip({
  categoryId,
  selected = false,
  size = 'md',
  onClick,
}: CategoryChipProps) {
  const category = CATEGORIES.find((c) => c.id === categoryId);
  if (!category) return null;

  return (
    <button
      type="button"
      onClick={onClick}
      className={cn(
        'inline-flex items-center gap-1.5 rounded-full font-medium transition-all duration-200 tap-highlight',
        size === 'sm' ? 'px-2 py-1 text-[10px]' : 'px-3 py-1.5 text-xs',
        selected
          ? category.color
          : 'bg-secondary text-secondary-foreground hover:bg-secondary/80',
        onClick && 'cursor-pointer active:scale-95'
      )}
    >
      <span className={size === 'sm' ? 'text-xs' : 'text-sm'}>{category.icon}</span>
      <span className="whitespace-nowrap">{category.name}</span>
    </button>
  );
}

interface CategoryChipListProps {
  categories: CategoryId[];
  selectedCategories?: CategoryId[];
  onToggle?: (categoryId: CategoryId) => void;
  size?: 'sm' | 'md';
  className?: string;
}

export function CategoryChipList({
  categories,
  selectedCategories = [],
  onToggle,
  size = 'md',
  className,
}: CategoryChipListProps) {
  return (
    <div className={cn('flex flex-wrap gap-2', className)}>
      {categories.map((categoryId) => (
        <CategoryChip
          key={categoryId}
          categoryId={categoryId}
          selected={selectedCategories.includes(categoryId)}
          size={size}
          onClick={onToggle ? () => onToggle(categoryId) : undefined}
        />
      ))}
    </div>
  );
}
