import { useState, useRef, useCallback } from 'react';

export const SWIPE_THRESHOLD = 80;
export const MAX_SWIPE_DISTANCE = 120;

interface UseSwipeableOptions {
  onSwipeLeft?: () => void;
  onSwipeRight?: () => void;
  disabled?: boolean;
}

export function useSwipeable({ onSwipeLeft, onSwipeRight, disabled }: UseSwipeableOptions = {}) {
  const [offset, setOffset] = useState(0);
  const [isDragging, setIsDragging] = useState(false);
  const startXRef = useRef(0);
  const currentXRef = useRef(0);
  const startYRef = useRef(0);

  const handleTouchStart = (e: React.TouchEvent) => {
    if (disabled) return;
    const clientX = e.touches[0].clientX;
    
    // Ignore gutter swipes (allow global navigation instead)
    if (clientX < 20 || clientX > window.innerWidth - 20) return;

    startXRef.current = clientX;
    startYRef.current = e.touches[0].clientY;
    currentXRef.current = clientX;
    setIsDragging(true);
  };

  const handleTouchMove = (e: React.TouchEvent) => {
    if (!isDragging || disabled) return;
    
    const touch = e.touches[0];
    const diffX = touch.clientX - startXRef.current;
    const diffY = touch.clientY - startYRef.current;

    // Determine if scrolling vertically
    if (Math.abs(diffY) > Math.abs(diffX) && Math.abs(diffY) > 10) {
        setIsDragging(false);
        setOffset(0);
        return;
    }

    currentXRef.current = touch.clientX;
    
    // Standardized clamping
    const clampedDiff = Math.max(-MAX_SWIPE_DISTANCE, Math.min(MAX_SWIPE_DISTANCE, diffX));
    setOffset(clampedDiff);
  };

  const handleTouchEnd = () => {
    if (!isDragging || disabled) return;
    setIsDragging(false);

    if (offset > SWIPE_THRESHOLD) {
      onSwipeRight?.();
    } else if (offset < -SWIPE_THRESHOLD) {
      onSwipeLeft?.();
    }
    setOffset(0);
  };

  return {
    offset,
    isDragging,
    handlers: {
      onTouchStart: handleTouchStart,
      onTouchMove: handleTouchMove,
      onTouchEnd: handleTouchEnd,
    },
  };
}
