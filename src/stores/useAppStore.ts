import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import { Task, Note, CategoryId, Priority } from '@/types';

interface AppState {
  // Notes
  notes: Note[];
  activeNoteId: string | null;
  
  // Tasks
  tasks: Task[];
  activeTaskId: string | null;
  
  // UI State
  showDoneTasks: boolean;
  groupedView: 'priority' | 'categories' | 'chrono';
  
  // Note Actions
  addNote: (note: Omit<Note, 'id' | 'createdAt' | 'updatedAt'>) => string;
  updateNote: (id: string, updates: Partial<Note>) => void;
  deleteNote: (id: string) => void;
  setActiveNote: (id: string | null) => void;
  
  // Task Actions
  addTask: (task: Omit<Task, 'id' | 'createdAt' | 'updatedAt'>) => string;
  updateTask: (id: string, updates: Partial<Task>) => void;
  deleteTask: (id: string) => void;
  completeTask: (id: string) => void;
  restoreTask: (id: string) => void;
  setActiveTask: (id: string | null) => void;
  reorderTasks: (taskIds: string[]) => void;
  
  // UI Actions
  toggleShowDoneTasks: () => void;
  setGroupedView: (view: 'priority' | 'categories' | 'chrono') => void;
}

const generateId = () => Math.random().toString(36).substr(2, 9);

export const useAppStore = create<AppState>()(
  persist(
    (set, get) => ({
      // Initial State
      notes: [],
      activeNoteId: null,
      tasks: [],
      activeTaskId: null,
      showDoneTasks: false,
      groupedView: 'priority',
      
      // Note Actions
      addNote: (noteData) => {
        const id = generateId();
        const now = new Date();
        const note: Note = {
          ...noteData,
          id,
          createdAt: now,
          updatedAt: now,
        };
        set((state) => ({ notes: [note, ...state.notes] }));
        return id;
      },
      
      updateNote: (id, updates) => {
        set((state) => ({
          notes: state.notes.map((note) =>
            note.id === id
              ? { ...note, ...updates, updatedAt: new Date() }
              : note
          ),
        }));
      },
      
      deleteNote: (id) => {
        set((state) => ({
          notes: state.notes.filter((note) => note.id !== id),
          activeNoteId: state.activeNoteId === id ? null : state.activeNoteId,
        }));
      },
      
      setActiveNote: (id) => set({ activeNoteId: id }),
      
      // Task Actions
      addTask: (taskData) => {
        const id = generateId();
        const now = new Date();
        const task: Task = {
          ...taskData,
          id,
          createdAt: now,
          updatedAt: now,
        };
        set((state) => ({ tasks: [task, ...state.tasks] }));
        return id;
      },
      
      updateTask: (id, updates) => {
        set((state) => ({
          tasks: state.tasks.map((task) =>
            task.id === id
              ? { ...task, ...updates, updatedAt: new Date() }
              : task
          ),
        }));
      },
      
      deleteTask: (id) => {
        set((state) => ({
          tasks: state.tasks.filter((task) => task.id !== id),
          activeTaskId: state.activeTaskId === id ? null : state.activeTaskId,
        }));
      },
      
      completeTask: (id) => {
        set((state) => ({
          tasks: state.tasks.map((task) =>
            task.id === id
              ? { ...task, completedAt: new Date(), updatedAt: new Date() }
              : task
          ),
        }));
      },
      
      restoreTask: (id) => {
        set((state) => ({
          tasks: state.tasks.map((task) =>
            task.id === id
              ? { ...task, completedAt: undefined, updatedAt: new Date() }
              : task
          ),
        }));
      },
      
      setActiveTask: (id) => set({ activeTaskId: id }),
      
      reorderTasks: (taskIds) => {
        const { tasks } = get();
        const taskMap = new Map(tasks.map((t) => [t.id, t]));
        const reordered = taskIds
          .map((id) => taskMap.get(id))
          .filter(Boolean) as Task[];
        const remaining = tasks.filter((t) => !taskIds.includes(t.id));
        set({ tasks: [...reordered, ...remaining] });
      },
      
      // UI Actions
      toggleShowDoneTasks: () =>
        set((state) => ({ showDoneTasks: !state.showDoneTasks })),
        
      setGroupedView: (view) => set({ groupedView: view }),
    }),
    {
      name: 'productivity-app-storage',
      partialize: (state) => ({
        notes: state.notes,
        tasks: state.tasks,
        groupedView: state.groupedView,
      }),
    }
  )
);
