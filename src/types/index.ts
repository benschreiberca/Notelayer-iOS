export type Priority = 'high' | 'medium' | 'low' | 'deferred';

export type CategoryId = 
  | 'house'
  | 'garage'
  | 'printing'
  | 'vehicle'
  | 'tech'
  | 'finance'
  | 'shopping'
  | 'travel';

export interface Category {
  id: CategoryId;
  name: string;
  icon: string;
  color: string;
}

export interface Attachment {
  id: string;
  type: 'file' | 'link' | 'image' | 'document';
  name: string;
  url?: string;
  filePath?: string;
  metadata?: Record<string, unknown>;
  createdAt: Date;
}

export interface Task {
  id: string;
  title: string;
  categories: CategoryId[];
  priority: Priority;
  dueDate?: Date;
  completedAt?: Date;
  parentTaskId?: string;
  attachments: Attachment[];
  noteId?: string;
  noteLine?: number;
  taskNotes?: string; // Additional notes/details for the task
  createdAt: Date;
  updatedAt: Date;
  inputMethod: 'text' | 'voice' | 'continuation';
}

export interface Note {
  id: string;
  title: string;
  content: string;
  plainText: string;
  createdAt: Date;
  updatedAt: Date;
}

export const CATEGORIES: Category[] = [
  { id: 'house', name: 'House & Repairs', icon: '🏠', color: 'category-house' },
  { id: 'garage', name: 'Garage & Workshop', icon: '🔧', color: 'category-garage' },
  { id: 'printing', name: '3D Printing', icon: '🖨️', color: 'category-printing' },
  { id: 'vehicle', name: 'Vehicle & Motorcycle', icon: '🏍️', color: 'category-vehicle' },
  { id: 'tech', name: 'Tech & Apps', icon: '💻', color: 'category-tech' },
  { id: 'finance', name: 'Finance & Admin', icon: '📊', color: 'category-finance' },
  { id: 'shopping', name: 'Shopping & Errands', icon: '🛒', color: 'category-shopping' },
  { id: 'travel', name: 'Travel & Health', icon: '✈️', color: 'category-travel' },
];

export const PRIORITY_CONFIG: Record<Priority, { label: string; color: string }> = {
  high: { label: 'High', color: 'priority-high' },
  medium: { label: 'Medium', color: 'priority-medium' },
  low: { label: 'Low', color: 'priority-low' },
  deferred: { label: 'Deferred', color: 'priority-deferred' },
};
