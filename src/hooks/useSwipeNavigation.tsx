import { useEffect, useCallback, useRef } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import {
  NAV_SWIPE_THRESHOLD,
  HORIZONTAL_SWIPE_RATIO,
  SWIPE_DIRECTION_LOCK_THRESHOLD,
  isSwipeableElement,
} from '@/lib/swipe-constants';

const routes = ['/notes', '/todos'];

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

    // Navigate to next tab
    const currentIndex = routes.indexOf(currentPath);
    if (currentIndex < routes.length - 1) {
      navigate(routes[currentIndex + 1]);
    }
  }, [location.pathname, navigate, options]);

  const handleSwipeRight = useCallback(() => {
    // Check if local handler exists and handles it
    if (options?.onSwipeRight?.()) return;

    const currentPath = location.pathname;

    // Navigate to previous tab
    const currentIndex = routes.indexOf(currentPath);
    if (currentIndex > 0) {
      navigate(routes[currentIndex - 1]);
    }
  }, [location.pathname, navigate, options]);

  useEffect(() => {
    let touchTarget: Element | null = null;

    const handleTouchStart = (e: TouchEvent) => {
      // Check if touch started on a swipeable element (note item or task item)
      const target = e.target as HTMLElement;
      const swipeableElement = target.closest('[data-swipeable="true"]');
      
      // If touch started on a swipeable element, ignore it for navigation
      if (swipeableElement) {
        return;
      }
      
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
      
      // Check if touch is on a swipeable element
      const target = e.target as HTMLElement;
      const swipeableElement = target.closest('[data-swipeable="true"]');
      
      // If touch is on a swipeable element, ignore it for navigation
      if (swipeableElement) {
        return;
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
