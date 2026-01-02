import { useEffect, useRef, useCallback } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { useAppStore } from '@/stores/useAppStore';
import {
  NAV_SWIPE_THRESHOLD,
  HORIZONTAL_SWIPE_RATIO,
  SWIPE_DIRECTION_LOCK_THRESHOLD,
  isSwipeableElement,
} from '@/lib/swipe-constants';

const routes = ['/notes', '/todos', '/grouped'];

interface SwipeNavigationOptions {
  onSwipeLeft?: () => boolean; // Return true if handled locally
  onSwipeRight?: () => boolean; // Return true if handled locally
}

/**
 * Hook for tab-level horizontal swipe navigation.
 * 
 * Gesture Priority:
 * - Row-level swipe actions (on elements with data-swipeable="true") take precedence
 * - Navigation swipes only trigger from non-swipeable areas (headers, empty space, etc.)
 * - Uses consistent thresholds and direction detection with row-level swipes
 */
export function useSwipeNavigation(options?: SwipeNavigationOptions) {
  const navigate = useNavigate();
  const location = useLocation();
  const { groupedView, setGroupedView, showDoneTasks, toggleShowDoneTasks } = useAppStore();
  
  const touchStartX = useRef(0);
  const touchStartY = useRef(0);
  const isSwiping = useRef(false);
  // Track if we've determined the swipe direction
  const directionLocked = useRef(false);
  // Track if this swipe started on a swipeable element
  const startedOnSwipeable = useRef(false);

  const handleSwipeLeft = useCallback(() => {
    // Check if local handler exists and handles it
    if (options?.onSwipeLeft?.()) return;

    const currentPath = location.pathname;
    
    // Handle local toggles first
    if (currentPath === '/todos') {
      if (!showDoneTasks) {
        toggleShowDoneTasks();
        return;
      }
    } else if (currentPath === '/grouped') {
      if (groupedView === 'priority') {
        setGroupedView('categories');
        return;
      } else if (groupedView === 'categories') {
        setGroupedView('chrono');
        return;
      }
    }
    
    // Navigate to next tab
    const currentIndex = routes.indexOf(currentPath);
    if (currentIndex < routes.length - 1) {
      navigate(routes[currentIndex + 1]);
    }
  }, [location.pathname, navigate, groupedView, setGroupedView, showDoneTasks, toggleShowDoneTasks, options]);

  const handleSwipeRight = useCallback(() => {
    // Check if local handler exists and handles it
    if (options?.onSwipeRight?.()) return;

    const currentPath = location.pathname;
    
    // Handle local toggles first
    if (currentPath === '/todos') {
      if (showDoneTasks) {
        toggleShowDoneTasks();
        return;
      }
    } else if (currentPath === '/grouped') {
      if (groupedView === 'chrono') {
        setGroupedView('categories');
        return;
      } else if (groupedView === 'categories') {
        setGroupedView('priority');
        return;
      }
    }
    
    // Navigate to previous tab
    const currentIndex = routes.indexOf(currentPath);
    if (currentIndex > 0) {
      navigate(routes[currentIndex - 1]);
    }
  }, [location.pathname, navigate, groupedView, setGroupedView, showDoneTasks, toggleShowDoneTasks, options]);

  useEffect(() => {
    let touchTarget: Element | null = null;

    const handleTouchStart = (e: TouchEvent) => {
      touchStartX.current = e.touches[0].clientX;
      touchStartY.current = e.touches[0].clientY;
      touchTarget = e.target instanceof Element ? e.target : null;
      isSwiping.current = false;
      directionLocked.current = false;
      
      // Check if touch started on a swipeable element
      // If so, row-level swipe actions take precedence
      startedOnSwipeable.current = isSwipeableElement(touchTarget);
    };

    const handleTouchMove = (e: TouchEvent) => {
      // Already handled this swipe
      if (isSwiping.current) return;
      
      const startX = touchStartX.current;
      const isGutter = startX < 20 || startX > window.innerWidth - 20;

      // Check if touch originated from a swipeable list item - let it handle swipe gestures
      // UNLESS we are in the gutter, where tab navigation takes precedence.
      if (!isGutter && touchTarget instanceof Element) {
        const swipeableParent = touchTarget.closest('[data-swipeable="true"]');
        if (swipeableParent) {
          // Don't interfere with row-level swipe actions
          return;
        }
      }
      
      const deltaX = e.touches[0].clientX - touchStartX.current;
      const deltaY = e.touches[0].clientY - touchStartY.current;
      
      // Wait until we have enough movement to determine direction
      if (!directionLocked.current) {
        if (Math.abs(deltaX) > SWIPE_DIRECTION_LOCK_THRESHOLD || 
            Math.abs(deltaY) > SWIPE_DIRECTION_LOCK_THRESHOLD) {
          directionLocked.current = true;
          
          // If this is primarily a vertical swipe, don't trigger navigation
          if (Math.abs(deltaY) > Math.abs(deltaX)) {
            return;
          }
        } else {
          // Not enough movement yet to determine direction
          return;
        }
      }
      
      // Only trigger horizontal swipe if it's clearly horizontal and exceeds threshold
      if (Math.abs(deltaX) > NAV_SWIPE_THRESHOLD && 
          Math.abs(deltaX) > Math.abs(deltaY) * HORIZONTAL_SWIPE_RATIO) {
        isSwiping.current = true;
        if (deltaX > 0) {
          handleSwipeRight();
        } else {
          handleSwipeLeft();
        }
      }
    };

    const handleTouchEnd = () => {
      // Reset state
      isSwiping.current = false;
      directionLocked.current = false;
      startedOnSwipeable.current = false;
    };

    document.addEventListener('touchstart', handleTouchStart, { passive: true });
    document.addEventListener('touchmove', handleTouchMove, { passive: true });
    document.addEventListener('touchend', handleTouchEnd, { passive: true });

    return () => {
      document.removeEventListener('touchstart', handleTouchStart);
      document.removeEventListener('touchmove', handleTouchMove);
      document.removeEventListener('touchend', handleTouchEnd);
    };
  }, [handleSwipeLeft, handleSwipeRight]);

  return { handleSwipeLeft, handleSwipeRight };
}
