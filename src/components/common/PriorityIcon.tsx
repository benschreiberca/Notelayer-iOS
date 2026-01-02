import { cn } from '@/lib/utils';
import { Priority } from '@/types';

interface PriorityIconProps {
  priority: Priority;
  size?: 'xs' | 'sm' | 'md' | 'lg';
  className?: string;
  showBackground?: boolean;
}

/**
 * Atlassian-style priority icons with distinct graphical representations:
 * - High: Double chevron up (⏫) - Urgent/Critical
 * - Medium: Single line/dash (—) - Standard
 * - Low: Single chevron down (⏬) - Low priority
 * - Deferred: Pause bars (⏸) - On hold
 * 
 * Icons are designed to be distinguishable without relying solely on color,
 * making them accessible and readable at small sizes.
 */
export function PriorityIcon({ 
  priority, 
  size = 'md', 
  className,
  showBackground = false 
}: PriorityIconProps) {
  const sizeClasses = {
    xs: 'w-3 h-3',
    sm: 'w-4 h-4',
    md: 'w-5 h-5',
    lg: 'w-6 h-6',
  };

  const strokeWidth = size === 'xs' ? 2.5 : size === 'sm' ? 2.5 : 2;
  
  const bgClasses = {
    high: 'bg-priority-high/15 dark:bg-priority-high/25',
    medium: 'bg-priority-medium/15 dark:bg-priority-medium/25',
    low: 'bg-priority-low/15 dark:bg-priority-low/25',
    deferred: 'bg-priority-deferred/15 dark:bg-priority-deferred/25',
  };

  const iconColors = {
    high: 'text-priority-high',
    medium: 'text-priority-medium',
    low: 'text-priority-low',
    deferred: 'text-priority-deferred',
  };

  const renderIcon = () => {
    switch (priority) {
      case 'high':
        // Double chevron up - Critical/Urgent
        return (
          <svg
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            strokeWidth={strokeWidth}
            strokeLinecap="round"
            strokeLinejoin="round"
            className={cn(sizeClasses[size], iconColors[priority], className)}
          >
            <polyline points="17 11 12 6 7 11" />
            <polyline points="17 18 12 13 7 18" />
          </svg>
        );
      
      case 'medium':
        // Equals/Horizontal line - Medium/Standard
        return (
          <svg
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            strokeWidth={strokeWidth}
            strokeLinecap="round"
            strokeLinejoin="round"
            className={cn(sizeClasses[size], iconColors[priority], className)}
          >
            <line x1="5" y1="12" x2="19" y2="12" />
          </svg>
        );
      
      case 'low':
        // Single chevron down - Low priority
        return (
          <svg
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            strokeWidth={strokeWidth}
            strokeLinecap="round"
            strokeLinejoin="round"
            className={cn(sizeClasses[size], iconColors[priority], className)}
          >
            <polyline points="6 9 12 15 18 9" />
          </svg>
        );
      
      case 'deferred':
        // Pause bars - On hold/Deferred
        return (
          <svg
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            strokeWidth={strokeWidth}
            strokeLinecap="round"
            strokeLinejoin="round"
            className={cn(sizeClasses[size], iconColors[priority], className)}
          >
            <line x1="10" y1="6" x2="10" y2="18" />
            <line x1="14" y1="6" x2="14" y2="18" />
          </svg>
        );
    }
  };

  if (showBackground) {
    const bgSizeClasses = {
      xs: 'w-5 h-5',
      sm: 'w-6 h-6',
      md: 'w-8 h-8',
      lg: 'w-10 h-10',
    };
    
    return (
      <div className={cn(
        'flex items-center justify-center rounded-md',
        bgSizeClasses[size],
        bgClasses[priority]
      )}>
        {renderIcon()}
      </div>
    );
  }

  return renderIcon();
}

/**
 * Get the label and icon description for a priority
 */
export function getPriorityLabel(priority: Priority): string {
  switch (priority) {
    case 'high':
      return 'High';
    case 'medium':
      return 'Medium';
    case 'low':
      return 'Low';
    case 'deferred':
      return 'Deferred';
  }
}

/**
 * Get accessibility description for priority
 */
export function getPriorityDescription(priority: Priority): string {
  switch (priority) {
    case 'high':
      return 'High priority - urgent task';
    case 'medium':
      return 'Medium priority - standard task';
    case 'low':
      return 'Low priority - can wait';
    case 'deferred':
      return 'Deferred - on hold';
  }
}
