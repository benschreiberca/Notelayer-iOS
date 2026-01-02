import { useEffect, useRef, useCallback } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { useAppStore } from '@/stores/useAppStore';

const routes = ['/notes', '/todos', '/grouped'];

interface SwipeNavigationOptions {
  onSwipeLeft?: () => boolean; // Return true if handled locally
  onSwipeRight?: () => boolean; // Return true if handled locally
}

export function useSwipeNavigation(options?: SwipeNavigationOptions) {
  const navigate = useNavigate();
  const location = useLocation();
  const { groupedView, setGroupedView, showDoneTasks, toggleShowDoneTasks } = useAppStore();
  
  const touchStartX = useRef(0);
  const touchStartY = useRef(0);
  const isSwiping = useRef(false);

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
    let touchTarget: EventTarget | null = null;

    const handleTouchStart = (e: TouchEvent) => {
      touchStartX.current = e.touches[0].clientX;
      touchStartY.current = e.touches[0].clientY;
      touchTarget = e.target;
      isSwiping.current = false;
    };

    const handleTouchMove = (e: TouchEvent) => {
      if (isSwiping.current) return;
      
      // Check if touch originated from a swipeable list item - let it handle swipe gestures
      if (touchTarget instanceof Element) {
        const swipeableParent = touchTarget.closest('[data-swipeable="true"]');
        if (swipeableParent) {
          // Don't interfere with row-level swipe actions
          return;
        }
      }
      
      const deltaX = e.touches[0].clientX - touchStartX.current;
      const deltaY = e.touches[0].clientY - touchStartY.current;
      
      // Only trigger horizontal swipe if it's more horizontal than vertical
      if (Math.abs(deltaX) > 50 && Math.abs(deltaX) > Math.abs(deltaY) * 1.5) {
        isSwiping.current = true;
        if (deltaX > 0) {
          handleSwipeRight();
        } else {
          handleSwipeLeft();
        }
      }
    };

    document.addEventListener('touchstart', handleTouchStart, { passive: true });
    document.addEventListener('touchmove', handleTouchMove, { passive: true });

    return () => {
      document.removeEventListener('touchstart', handleTouchStart);
      document.removeEventListener('touchmove', handleTouchMove);
    };
  }, [handleSwipeLeft, handleSwipeRight]);

  return { handleSwipeLeft, handleSwipeRight };
}
