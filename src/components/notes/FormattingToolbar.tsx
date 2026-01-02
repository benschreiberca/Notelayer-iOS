import { useState, useEffect, useRef } from 'react';
import { cn } from '@/lib/utils';
import { LucideIcon } from 'lucide-react';
import { useIsMobile } from '@/hooks/use-mobile';

interface FormatButton {
  icon: LucideIcon;
  command: string;
  value?: string;
  label: string;
}

interface FormattingToolbarProps {
  contentRef: React.RefObject<HTMLDivElement>;
  isVisible: boolean;
  formatButtons: FormatButton[];
  execCommand: (command: string, value?: string) => void;
}

export function FormattingToolbar({
  contentRef,
  isVisible,
  formatButtons,
  execCommand,
}: FormattingToolbarProps) {
  const [selectionState, setSelectionState] = useState<Record<string, boolean>>({});
  const [keyboardHeight, setKeyboardHeight] = useState(0);
  const updateIntervalRef = useRef<NodeJS.Timeout | null>(null);
  const isMobile = useIsMobile();

  // Track keyboard visibility using visual viewport API
  useEffect(() => {
    if (!isVisible) {
      setKeyboardHeight(0);
      return;
    }

    const updateKeyboardHeight = () => {
      if (typeof window !== 'undefined' && 'visualViewport' in window && window.visualViewport) {
        const viewport = window.visualViewport;
        const windowHeight = window.innerHeight;
        const viewportHeight = viewport.height;
        const heightDiff = windowHeight - viewportHeight;
        
        // Only show toolbar if keyboard is visible (viewport height significantly reduced)
        if (heightDiff > 150) {
          setKeyboardHeight(heightDiff);
        } else {
          setKeyboardHeight(0);
        }
      } else {
        // Fallback: detect keyboard using resize events
        const initialHeight = window.innerHeight;
        const handleResize = () => {
          const currentHeight = window.innerHeight;
          const heightDiff = initialHeight - currentHeight;
          if (heightDiff > 150) {
            setKeyboardHeight(heightDiff);
          } else {
            setKeyboardHeight(0);
          }
        };
        window.addEventListener('resize', handleResize);
        return () => window.removeEventListener('resize', handleResize);
      }
    };

    updateKeyboardHeight();
    
    if ('visualViewport' in window && window.visualViewport) {
      window.visualViewport.addEventListener('resize', updateKeyboardHeight);
      window.visualViewport.addEventListener('scroll', updateKeyboardHeight);
      return () => {
        window.visualViewport?.removeEventListener('resize', updateKeyboardHeight);
        window.visualViewport?.removeEventListener('scroll', updateKeyboardHeight);
      };
    } else {
      window.addEventListener('resize', updateKeyboardHeight);
      return () => window.removeEventListener('resize', updateKeyboardHeight);
    }
  }, [isVisible]);

  // Update selection state periodically while focused
  useEffect(() => {
    if (!isVisible || !contentRef.current) {
      if (updateIntervalRef.current) {
        clearInterval(updateIntervalRef.current);
        updateIntervalRef.current = null;
      }
      return;
    }

    const updateSelectionState = () => {
      if (!contentRef.current) return;

      const state: Record<string, boolean> = {};
      
      formatButtons.forEach(({ command, value }) => {
        try {
          if (command === 'formatBlock') {
            // For formatBlock, check if current block is the target format
            const selection = window.getSelection();
            if (selection && selection.rangeCount > 0) {
              const range = selection.getRangeAt(0);
              const blockElement = range.commonAncestorContainer.nodeType === Node.TEXT_NODE
                ? (range.commonAncestorContainer.parentElement?.closest('h1, h2, h3, h4, h5, h6, p, div'))
                : (range.commonAncestorContainer as Element);
              
              if (blockElement && value) {
                state[command] = blockElement.tagName.toLowerCase() === value;
              }
            }
          } else {
            state[command] = document.queryCommandState(command);
          }
        } catch (e) {
          state[command] = false;
        }
      });

      setSelectionState(state);
    };

    // Update immediately
    updateSelectionState();

    // Update on selection change
    const handleSelectionChange = () => {
      updateSelectionState();
    };

    document.addEventListener('selectionchange', handleSelectionChange);

    // Also update periodically to catch any missed changes
    updateIntervalRef.current = setInterval(updateSelectionState, 100);

    return () => {
      document.removeEventListener('selectionchange', handleSelectionChange);
      if (updateIntervalRef.current) {
        clearInterval(updateIntervalRef.current);
        updateIntervalRef.current = null;
      }
    };
  }, [isVisible, formatButtons, contentRef]);

  const handleButtonClick = (command: string, value?: string) => {
    execCommand(command, value);
    // Force update selection state after command
    setTimeout(() => {
      const state: Record<string, boolean> = {};
      formatButtons.forEach(({ command: cmd, value: val }) => {
        try {
          if (cmd === 'formatBlock') {
            const selection = window.getSelection();
            if (selection && selection.rangeCount > 0) {
              const range = selection.getRangeAt(0);
              const blockElement = range.commonAncestorContainer.nodeType === Node.TEXT_NODE
                ? (range.commonAncestorContainer.parentElement?.closest('h1, h2, h3, h4, h5, h6, p, div'))
                : (range.commonAncestorContainer as Element);
              
              if (blockElement && val) {
                state[cmd] = blockElement.tagName.toLowerCase() === val;
              }
            }
          } else {
            state[cmd] = document.queryCommandState(cmd);
          }
        } catch (e) {
          state[cmd] = false;
        }
      });
      setSelectionState(state);
    }, 10);
  };

  // Show toolbar when content is focused
  // On mobile: only show when keyboard is visible (iOS-style inputAccessoryView)
  // On desktop: show when focused (positioned at bottom for consistency)
  const shouldShow = isVisible && (isMobile ? keyboardHeight > 0 : true);

  if (!shouldShow) {
    return null;
  }

  // Calculate bottom position: above keyboard on mobile, or at safe bottom on desktop
  const bottomPosition = keyboardHeight > 0 
    ? `${keyboardHeight}px` 
    : (isMobile ? '0px' : 'max(env(safe-area-inset-bottom, 0px), 0px)');

  return (
    <div
      className="fixed left-0 right-0 z-50 bg-background/95 backdrop-blur-md border-t border-border/50 shadow-lg transition-transform duration-200 safe-area-bottom"
      style={{
        bottom: bottomPosition,
        transform: 'translateY(0)',
      }}
    >
      <div className="flex items-center gap-1 px-2 py-2 overflow-x-auto hide-scrollbar max-w-full">
        {formatButtons.map(({ icon: Icon, command, value, label }) => {
          const isActive = selectionState[command] || false;
          return (
            <button
              key={`${command}-${value || ''}`}
              type="button"
              onClick={() => handleButtonClick(command, value)}
              className={cn(
                'p-3 rounded-xl text-muted-foreground hover:text-foreground transition-all tap-highlight flex-shrink-0 min-w-[44px] min-h-[44px] flex items-center justify-center',
                isActive
                  ? 'bg-primary text-primary-foreground'
                  : 'hover:bg-muted/50'
              )}
              title={label}
            >
              <Icon className="w-5 h-5" />
            </button>
          );
        })}
      </div>
    </div>
  );
}
