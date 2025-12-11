import { cn } from '@/lib/utils';
import { Priority, PRIORITY_CONFIG } from '@/types';
import { Flag } from 'lucide-react';

interface PriorityBadgeProps {
  priority: Priority;
  size?: 'sm' | 'md';
  showLabel?: boolean;
  onClick?: () => void;
}

export function PriorityBadge({
  priority,
  size = 'md',
  showLabel = true,
  onClick,
}: PriorityBadgeProps) {
  const config = PRIORITY_CONFIG[priority];

  return (
    <button
      type="button"
      onClick={onClick}
      className={cn(
        'inline-flex items-center gap-1.5 rounded-full font-medium transition-all duration-200 tap-highlight',
        size === 'sm' ? 'px-2 py-0.5 text-[10px]' : 'px-2.5 py-1 text-xs',
        config.color,
        onClick && 'cursor-pointer active:scale-95'
      )}
    >
      <Flag className={size === 'sm' ? 'w-2.5 h-2.5' : 'w-3 h-3'} />
      {showLabel && <span>{config.label}</span>}
    </button>
  );
}
