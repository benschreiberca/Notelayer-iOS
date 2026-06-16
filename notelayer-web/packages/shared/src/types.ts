export type Priority = "high" | "medium" | "low" | "deferred" | null;

export interface Task {
  id: string;
  title: string;
  categories: string[];
  priority: Priority;
  isCompleted: boolean;
  dueDate: string | null;
  taskNotes: string | null;
  orderIndex: number;
  parentTaskId: string | null;
  createdAt: string;
  updatedAt: string;
  createdFrom?: string;
}

export interface Note {
  id: string;
  text: string;
  title?: string;
  isPinned: boolean;
  createdAt: string;
  updatedAt: string;
  createdFrom?: string;
}

export interface Category {
  id: string;
  name: string;
  icon: string;
  color: string;
  orderIndex: number;
}

export const DEFAULT_CATEGORIES: Omit<Category, "id">[] = [
  { name: "House & Repairs", icon: "🏠", color: "#4F8EF7", orderIndex: 0 },
  { name: "Garage & Workshop", icon: "🔧", color: "#FF9500", orderIndex: 1 },
  { name: "3D Printing", icon: "🖨️", color: "#BF5AF2", orderIndex: 2 },
  { name: "Vehicle & Motorcycle", icon: "🏍️", color: "#FF3B30", orderIndex: 3 },
  { name: "Tech & Apps", icon: "💻", color: "#64D2FF", orderIndex: 4 },
  { name: "Finance & Admin", icon: "💰", color: "#34C759", orderIndex: 5 },
  { name: "Shopping & Errands", icon: "🛒", color: "#FF6B6B", orderIndex: 6 },
  { name: "Travel & Health", icon: "✈️", color: "#30D158", orderIndex: 7 },
];
