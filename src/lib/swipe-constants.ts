/**
 * Shared swipe gesture constants for consistent behavior across the app.
 * 
 * Gesture Hierarchy:
 * 1. Row-level swipe actions (pin/delete on notes, etc.) take precedence
 *    when the swipe starts on a list item marked with data-swipeable="true"
 * 2. Tab-level horizontal navigation only triggers from non-row areas
 *    (headers, empty space, or when vertical movement is detected first)
 * 
 * Long-Press-to-Drag:
 * - Tasks use long-press to enter drag mode (no dedicated drag handle)
 * - Fast activation (150ms) with movement threshold to prevent accidental drags
 * - Visual feedback on activation (scale + shadow)
 */

// ============================================================================
// LONG-PRESS-TO-DRAG CONSTANTS
// ============================================================================

// Delay in ms before long-press activates drag mode
// Tuned for iOS-like feel: fast but not accidental (120-180ms range)
export const LONG_PRESS_DELAY = 150;

// Movement threshold (px) during long-press delay
// If finger moves more than this, cancel drag and treat as scroll
export const LONG_PRESS_MOVEMENT_THRESHOLD = 8;

// Visual feedback scale when drag is activated
export const DRAG_ACTIVE_SCALE = 1.03;

// Shadow/elevation class when dragging
export const DRAG_ACTIVE_SHADOW = 'shadow-xl';

// ============================================================================
// SWIPE GESTURE CONSTANTS
// ============================================================================

// Minimum horizontal distance (px) to trigger a row-level swipe action
export const ROW_SWIPE_THRESHOLD = 80;

// Minimum horizontal distance (px) to trigger tab/page navigation
export const NAV_SWIPE_THRESHOLD = 50;

// Maximum offset (px) for row swipe visual feedback
export const ROW_SWIPE_MAX_OFFSET = 120;

// Ratio of horizontal to vertical movement to consider it a horizontal swipe
// A value of 1.5 means horizontal must be 1.5x the vertical distance
export const HORIZONTAL_SWIPE_RATIO = 1.5;

// Minimum horizontal movement (px) to start claiming a swipe gesture
export const SWIPE_DIRECTION_LOCK_THRESHOLD = 10;

// Opacity threshold for showing swipe action backgrounds
export const SWIPE_ACTION_OPACITY_THRESHOLD = 20;

// Animation duration for swipe reset (ms)
export const SWIPE_RESET_DURATION = 200;

// Data attribute used to mark swipeable list items
export const SWIPEABLE_ATTR = 'data-swipeable';
export const SWIPEABLE_SELECTOR = '[data-swipeable="true"]';

// Data attribute to mark areas that should only trigger navigation
export const NAV_SWIPE_AREA_ATTR = 'data-nav-swipe-area';
export const NAV_SWIPE_AREA_SELECTOR = '[data-nav-swipe-area="true"]';

/**
 * Check if an element or its ancestors is a swipeable list item
 */
export function isSwipeableElement(element: Element | null): boolean {
  if (!element) return false;
  return !!element.closest(SWIPEABLE_SELECTOR);
}

/**
 * Check if an element is in a navigation-only swipe area
 */
export function isNavSwipeArea(element: Element | null): boolean {
  if (!element) return false;
  return !!element.closest(NAV_SWIPE_AREA_SELECTOR);
}

/**
 * Determine if a swipe is primarily horizontal based on delta values
 */
export function isHorizontalSwipe(deltaX: number, deltaY: number): boolean {
  return Math.abs(deltaX) > Math.abs(deltaY) * HORIZONTAL_SWIPE_RATIO;
}

/**
 * Clamp a swipe offset to the maximum allowed range
 */
export function clampSwipeOffset(offset: number, max: number = ROW_SWIPE_MAX_OFFSET): number {
  return Math.max(-max, Math.min(max, offset));
}
