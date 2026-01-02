import { useState, ReactNode } from 'react';
import { ChevronDown } from 'lucide-react';
import { Collapsible, CollapsibleContent, CollapsibleTrigger } from '@/components/ui/collapsible';
import { cn } from '@/lib/utils';

interface CollapsibleSectionProps {
  /** Header icon element (emoji, Icon component, or colored dot) */
  icon?: ReactNode;
  /** Section title */
  title: string;
  /** Number of items in section */
  count: number;
  /** Additional text color class for the header */
  headerColorClass?: string;
  /** Content to render inside the section */
  children: ReactNode;
  /** Whether the section is expanded by default */
  defaultOpen?: boolean;
  /** Optional className for outer wrapper */
  className?: string;
}

export function CollapsibleSection({
  icon,
  title,
  count,
  headerColorClass,
  children,
  defaultOpen = true,
  className,
}: CollapsibleSectionProps) {
  const [isOpen, setIsOpen] = useState(defaultOpen);

  const isEmpty = count === 0;

  return (
    <Collapsible
      open={isOpen}
      onOpenChange={setIsOpen}
      className={cn('group', className)}
    >
      {/* iOS-like section header */}
      <CollapsibleTrigger asChild>
        <button
          type="button"
          className={cn(
            'w-full flex items-center gap-2 py-2 px-1 -mx-1 rounded-lg',
            'transition-colors duration-150 tap-highlight',
            'hover:bg-muted/50 active:bg-muted/70',
            // Condensed padding when empty and collapsed
            isEmpty && !isOpen && 'py-1'
          )}
        >
          {/* Icon */}
          {icon && <span className="flex-shrink-0">{icon}</span>}

          {/* Title */}
          <span
            className={cn(
              'text-xs font-semibold uppercase tracking-wide flex-1 text-left',
              headerColorClass || 'text-muted-foreground'
            )}
          >
            {title}
          </span>

          {/* Live count badge */}
          <span
            className={cn(
              'text-[10px] font-medium px-1.5 py-0.5 rounded-full min-w-[1.25rem] text-center',
              count > 0
                ? 'bg-primary/10 text-primary'
                : 'bg-muted text-muted-foreground'
            )}
          >
            {count}
          </span>

          {/* Chevron indicator */}
          <ChevronDown
            className={cn(
              'w-3.5 h-3.5 text-muted-foreground transition-transform duration-200',
              isOpen && 'rotate-180'
            )}
          />
        </button>
      </CollapsibleTrigger>

      {/* Collapsible content with animation */}
      <CollapsibleContent className="collapsible-content overflow-hidden">
        <div className={cn('pt-2', isEmpty && 'pt-1')}>
          {children}
        </div>
      </CollapsibleContent>

      {/* Subtle divider when collapsed and not empty */}
      {!isOpen && !isEmpty && (
        <div className="h-px bg-border/50 mt-1" />
      )}
    </Collapsible>
  );
}
