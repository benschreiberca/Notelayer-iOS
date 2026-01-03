/**
 * Gesture constants for swipe interactions.
 * This file provides a structured GESTURE object used by swipeable components.
 */

import {
  SWIPE_DIRECTION_LOCK_THRESHOLD,
  HORIZONTAL_SWIPE_RATIO,
  ROW_SWIPE_MAX_OFFSET,
  ROW_SWIPE_THRESHOLD,
  SWIPE_ACTION_OPACITY_THRESHOLD,
} from './swipe-constants';

export const GESTURE = {
  directionLock: {
    /** Minimum movement in px before locking to horizontal or vertical */
    activationPx: SWIPE_DIRECTION_LOCK_THRESHOLD,
    /** Ratio of horizontal to vertical movement to consider it horizontal */
    horizontalToVerticalRatio: HORIZONTAL_SWIPE_RATIO,
  },
  row: {
    /** Maximum translation in px for row swipe */
    maxTranslatePx: ROW_SWIPE_MAX_OFFSET,
    /** Threshold in px to trigger an action (pin/delete) */
    actionThresholdPx: ROW_SWIPE_THRESHOLD,
    /** Threshold in px to show the action hint/background */
    revealHintPx: SWIPE_ACTION_OPACITY_THRESHOLD,
  },
} as const;
