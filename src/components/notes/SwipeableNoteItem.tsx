import { useState, useRef, useCallback } from 'react';
import { FileText, ChevronRight, Pin, Trash2, Check } from 'lucide-react';
import { cn } from '@/lib/utils';
import { Note } from '@/types';
import { formatDistanceToNow } from 'date-fns';
import { GESTURE } from '@/lib/gestures';

interface SwipeableNoteItemProps {
  note: Note;
  onClick?: () => void;
  onPin?: () => void;
  onDelete?: () => void;
  isSelected?: boolean;
  isSelectMode?: boolean;
  onSelect?: () => void;
  className?: string;
}

export function SwipeableNoteItem({
  note,
  onClick,
  onPin,
  onDelete,
  isSelected = false,
  isSelectMode = false,
  onSelect,
  className,
}: SwipeableNoteItemProps) {
  const [offset, setOffset] = useState(0);
  const [isDragging, setIsDragging] = useState(false);

  const startXRef = useRef(0);
  const startYRef = useRef(0);
  const currentXRef = useRef(0);
  const hasDeterminedDirectionRef = useRef(false);

  const preview = note.plainText?.slice(0, 100) || '';
  const timeAgo = formatDistanceToNow(new Date(note.updatedAt), { addSuffix: true });

  const handleTouchStart = (e: React.TouchEvent) => {
    if (isSelectMode) return;

    startXRef.current = e.touches[0].clientX;
    startYRef.current = e.touches[0].clientY;
    currentXRef.current = e.touches[0].clientX;
    hasDeterminedDirectionRef.current = false;
    setIsDragging(true);
  };

  const handleTouchMove = (e: React.TouchEvent) => {
    if (!isDragging || isSelectMode) return;
    
    const currentX = e.touches[0].clientX;
    const currentY = e.touches[0].clientY;
    const deltaX = currentX - startXRef.current;
    const deltaY = currentY - startYRef.current;
    
    // Determine swipe direction early
    if (!hasDeterminedDirectionRef.current && (Math.abs(deltaX) > 10 || Math.abs(deltaY) > 10)) {
      hasDeterminedDirectionRef.current = true;
      
      // If horizontal swipe is detected, stop propagation to prevent tab navigation
      if (Math.abs(deltaX) > Math.abs(deltaY)) {
        e.stopPropagation();
      }
    }
    
    // Only handle horizontal swipes
    if (Math.abs(deltaX) > Math.abs(deltaY)) {
      e.stopPropagation();
      currentXRef.current = currentX;
      // Limit swipe distance
      const clampedDiff = Math.max(-120, Math.min(120, deltaX));
      setOffset(clampedDiff);
    }
  };

  const handleTouchEnd = (e: React.TouchEvent) => {
    if (!isDragging || isSelectMode) return;
    
    // Stop propagation to prevent tab navigation
    if (Math.abs(offset) > 10) {
      e.stopPropagation();
    }
    
    setIsDragging(false);

    if (offset > GESTURE.row.actionThresholdPx) onPin?.();
    else if (offset < -GESTURE.row.actionThresholdPx) onDelete?.();

    setOffset(0);
    hasDeterminedDirectionRef.current = false;
  };

  const handleClick = () => {
    if (isSelectMode) onSelect?.();
    else onClick?.();
  };

  return (
    <div className="relative overflow-hidden rounded-xl" data-swipeable="true">
      {/* Background actions */}
      <div className="absolute inset-0 flex">
        {/* Pin */}
        <div
          className={cn(
            'flex items-center justify-start pl-4 w-1/2 transition-opacity',
            note.isPinned ? 'bg-muted' : 'bg-primary',
            offset > GESTURE.row.revealHintPx ? 'opacity-100' : 'opacity-0'
          )}
        >
          <Pin
            className={cn(
              'w-6 h-6',
              note.isPinned ? 'text-muted-foreground' : 'text-primary-foreground'
            )}
          />
          <span
            className={cn(
              'ml-2 text-sm font-medium',
              note.isPinned ? 'text-muted-foreground' : 'text-primary-foreground'
            )}
          >
            {note.isPinned ? 'Unpin' : 'Pin'}
          </span>
        </div>

        {/* Delete */}
        <div
          className={cn(
            'flex items-center justify-end pr-4 w-1/2 ml-auto bg-destructive transition-opacity',
            offset < -GESTURE.row.revealHintPx ? 'opacity-100' : 'opacity-0'
          )}
        >
          <span className="mr-2 text-sm font-medium text-destructive-foreground">Delete</span>
          <Trash2 className="w-6 h-6 text-destructive-foreground" />
        </div>
      </div>

      {/* Main content */}
      <button
        type="button"
        onClick={handleClick}
        onTouchStart={handleTouchStart}
        onTouchMove={handleTouchMove}
        onTouchEnd={handleTouchEnd}
        className={cn(
          'w-full text-left bg-card border border-border/50 shadow-soft p-4 tap-highlight relative',
          'hover:shadow-card hover:border-border',
          isSelected && 'ring-2 ring-primary bg-primary/5',
          isDragging ? 'transition-none' : 'transition-transform duration-150',
          className
        )}
        style={{ 
          transform: `translateX(${offset}px)`,
          touchAction: 'pan-y' // Prioritize vertical scrolling, allow horizontal swipe handling
        }}
      >
        <div className="flex items-start gap-3">
          {isSelectMode ? (
            <div
              className={cn(
                'w-10 h-10 rounded-lg flex items-center justify-center flex-shrink-0 transition-colors',
                isSelected ? 'bg-primary' : 'bg-muted border-2 border-border'
              )}
            >
              {isSelected && <Check className="w-5 h-5 text-primary-foreground" />}
            </div>
          ) : (
            <div className="w-10 h-10 rounded-lg bg-accent/20 flex items-center justify-center flex-shrink-0 relative">
              <FileText className="w-5 h-5 text-accent" />
              {note.isPinned && (
                <Pin className="w-3 h-3 text-primary absolute -top-1 -right-1 fill-primary" />
              )}
            </div>
          )}

          <div className="flex-1 min-w-0">
            <h3 className="text-sm font-semibold text-foreground truncate flex items-center gap-2">
              {note.title || 'Untitled Note'}
              {note.isPinned && !isSelectMode && (
                <span className="text-[10px] text-primary font-medium">PINNED</span>
              )}
            </h3>

            {preview && (
              <p className="text-xs text-muted-foreground mt-1 line-clamp-2">{preview}</p>
            )}

            <p className="text-[10px] text-muted-foreground/70 mt-2">{timeAgo}</p>
          </div>

          {!isSelectMode && (
            <ChevronRight className="w-4 h-4 text-muted-foreground flex-shrink-0 mt-1" />
          )}
        </div>
      </button>
    </div>
  );
}
