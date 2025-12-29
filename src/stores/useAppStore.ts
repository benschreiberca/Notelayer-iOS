import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import { Task, Note } from '@/types';
import { supabase } from '@/integrations/supabase/client';

type GroupedView = 'priority' | 'categories' | 'chrono';

interface AppState {
  // Notes
  notes: Note[];
  activeNoteId: string | null;

  // Tasks
  tasks: Task[];
  activeTaskId: string | null;

  // UI
  showDoneTasks: boolean;
  groupedView: GroupedView;

  // Notes: Supabase
  loadNotesFromSupabase: () => Promise<void>;
  addNote: (note: Omit<Note, 'id' | 'createdAt' | 'updatedAt'>) => string;
  updateNote: (id: string, updates: Partial<Note>) => void;
  deleteNote: (id: string) => void;
  deleteNotes: (ids: string[]) => void;
  togglePinNote: (id: string) => void;
  setActiveNote: (id: string | null) => void;

  // Tasks: Supabase
  loadTasksFromSupabase: () => Promise<void>;
  addTask: (task: Omit<Task, 'id' | 'createdAt' | 'updatedAt'>) => string;
  updateTask: (id: string, updates: Partial<Task>) => void;
  deleteTask: (id: string) => void;
  completeTask: (id: string) => void;
  restoreTask: (id: string) => void;
  setActiveTask: (id: string | null) => void;
  reorderTasks: (taskIds: string[]) => void;

  // UI actions
  toggleShowDoneTasks: () => void;
  setGroupedView: (view: GroupedView) => void;
}

const generateId = () => Math.random().toString(36).slice(2, 11);

// ---- Date helpers (because Supabase JSON returns strings) ----
const isIsoDateString = (v: any) =>
  typeof v === 'string' &&
  /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d+)?Z$/.test(v);

const reviveDatesDeep = (obj: any): any => {
  if (Array.isArray(obj)) return obj.map(reviveDatesDeep);
  if (obj && typeof obj === 'object') {
    const out: any = {};
    for (const [k, v] of Object.entries(obj)) out[k] = reviveDatesDeep(v);
    return out;
  }
  if (isIsoDateString(obj)) return new Date(obj);
  return obj;
};

const serializeForJsonb = (obj: any) =>
  JSON.parse(
    JSON.stringify(obj, (_k, v) => (v instanceof Date ? v.toISOString() : v))
  );

// ---- Notes mapping ----
const rowToNote = (row: any): Note => {
  const base = row.data && Object.keys(row.data).length ? reviveDatesDeep(row.data) : {};
  return {
    id: row.id,
    title: row.title ?? base.title ?? '',
    content: row.content ?? base.content ?? '',
    plainText: row.plain_text ?? base.plainText ?? '',
    isPinned: row.is_pinned ?? base.isPinned ?? false,
    createdAt: row.created_at ? new Date(row.created_at) : base.createdAt ?? new Date(),
    updatedAt: row.updated_at ? new Date(row.updated_at) : base.updatedAt ?? new Date(),
  };
};

const noteToRow = (note: Note) => ({
  id: note.id,
  title: note.title,
  content: note.content,
  plain_text: note.plainText,
  is_pinned: !!note.isPinned,
  data: serializeForJsonb(note),
  created_at: note.createdAt.toISOString(),
  updated_at: note.updatedAt.toISOString(),
});

// ---- Tasks mapping ----
const rowToTask = (row: any): Task => {
  const base = row.data && Object.keys(row.data).length ? reviveDatesDeep(row.data) : {};

  const task: Task = {
    id: row.id,
    title: row.title ?? base.title ?? '',
    categories: base.categories ?? [],
    priority: base.priority ?? 'medium',
    dueDate: base.dueDate ?? undefined,
    completedAt: row.completed_at ? new Date(row.completed_at) : base.completedAt ?? undefined,
    parentTaskId: base.parentTaskId ?? undefined,
    attachments: base.attachments ?? [],
    noteId: base.noteId ?? undefined,
    noteLine: base.noteLine ?? undefined,
    taskNotes: base.taskNotes ?? undefined,
    createdAt: row.created_at ? new Date(row.created_at) : base.createdAt ?? new Date(),
    updatedAt: row.updated_at ? new Date(row.updated_at) : base.updatedAt ?? new Date(),
    inputMethod: base.inputMethod ?? 'text',
  };

  // not in your TS type, but used to sort/reorder in DB
  (task as any).orderIndex = row.order_index ?? base.orderIndex ?? Date.now();

  return task;
};

const taskToRow = (task: Task) => ({
  id: task.id,
  title: task.title,
  completed_at: task.completedAt ? task.completedAt.toISOString() : null,
  order_index: (task as any).orderIndex ?? Date.now(),
  data: serializeForJsonb(task),
  created_at: task.createdAt.toISOString(),
  updated_at: task.updatedAt.toISOString(),
});

export const useAppStore = create<AppState>()(
  persist(
    (set, get) => ({
      // Initial state
      notes: [],
      activeNoteId: null,

      tasks: [],
      activeTaskId: null,

      showDoneTasks: false,
      groupedView: 'priority',

      // ----------------------
      // NOTES (Supabase)
      // ----------------------
      loadNotesFromSupabase: async () => {
        const { data, error } = await supabase
          .from('notes')
          .select('*')
          .order('is_pinned', { ascending: false })
          .order('updated_at', { ascending: false });

        if (error) {
          console.error('loadNotesFromSupabase error:', error);
          return;
        }

        set({ notes: (data ?? []).map(rowToNote) });
      },

      addNote: (noteData) => {
        const id = generateId();
        const now = new Date();

        const note: Note = {
          ...(noteData as any),
          id,
          isPinned: (noteData as any).isPinned ?? false,
          plainText: (noteData as any).plainText ?? '',
          createdAt: now,
          updatedAt: now,
        };

        // optimistic UI
        set((state) => ({ notes: [note, ...state.notes] }));

        void supabase.from('notes').insert([noteToRow(note)]).then(({ error }) => {
          if (error) console.error('addNote supabase error:', error);
        });

        return id;
      },

      updateNote: (id, updates) => {
        set((state) => ({
          notes: state.notes.map((n) =>
            n.id === id ? ({ ...(n as any), ...(updates as any), updatedAt: new Date() } as any) : n
          ),
        }));

        const note = get().notes.find((n) => n.id === id);
        if (!note) return;

        void supabase.from('notes').update(noteToRow(note)).eq('id', id).then(({ error }) => {
          if (error) console.error('updateNote supabase error:', error);
        });
      },

      deleteNote: (id) => {
        set((state) => ({
          notes: state.notes.filter((n) => n.id !== id),
          activeNoteId: state.activeNoteId === id ? null : state.activeNoteId,
        }));

        void supabase.from('notes').delete().eq('id', id).then(({ error }) => {
          if (error) console.error('deleteNote supabase error:', error);
        });
      },

      deleteNotes: (ids) => {
        set((state) => ({
          notes: state.notes.filter((n) => !ids.includes(n.id)),
          activeNoteId: ids.includes(state.activeNoteId || '') ? null : state.activeNoteId,
        }));

        void supabase.from('notes').delete().in('id', ids).then(({ error }) => {
          if (error) console.error('deleteNotes supabase error:', error);
        });
      },

      togglePinNote: (id) => {
        const note = get().notes.find((n) => n.id === id);
        if (!note) return;
        get().updateNote(id, { isPinned: !note.isPinned } as any);
      },

      setActiveNote: (id) => set({ activeNoteId: id }),

      // ----------------------
      // TASKS (Supabase)
      // ----------------------
      loadTasksFromSupabase: async () => {
        const { data, error } = await supabase
          .from('tasks')
          .select('*')
          .order('order_index', { ascending: false })
          .order('created_at', { ascending: false });

        if (error) {
          console.error('loadTasksFromSupabase error:', error);
          return;
        }

        set({ tasks: (data ?? []).map(rowToTask) });
      },

      addTask: (taskData) => {
        const id = generateId();
        const now = new Date();

        const task: any = {
          ...(taskData as any),
          id,
          createdAt: now,
          updatedAt: now,
          // required defaults (safety)
          categories: (taskData as any).categories ?? [],
          priority: (taskData as any).priority ?? 'medium',
          attachments: (taskData as any).attachments ?? [],
          inputMethod: (taskData as any).inputMethod ?? 'text',
          orderIndex: Date.now(),
        };

        // optimistic UI
        set((state) => ({ tasks: [task as Task, ...state.tasks] }));

        void supabase.from('tasks').insert([taskToRow(task as Task)]).then(({ error }) => {
          if (error) console.error('addTask supabase error:', error);
        });

        return id;
      },

      updateTask: (id, updates) => {
        set((state) => ({
          tasks: state.tasks.map((t) =>
            t.id === id ? ({ ...(t as any), ...(updates as any), updatedAt: new Date() } as any) : t
          ),
        }));

        const task = get().tasks.find((t) => t.id === id);
        if (!task) return;

        void supabase.from('tasks').update(taskToRow(task)).eq('id', id).then(({ error }) => {
          if (error) console.error('updateTask supabase error:', error);
        });
      },

      deleteTask: (id) => {
        set((state) => ({
          tasks: state.tasks.filter((t) => t.id !== id),
          activeTaskId: state.activeTaskId === id ? null : state.activeTaskId,
        }));

        void supabase.from('tasks').delete().eq('id', id).then(({ error }) => {
          if (error) console.error('deleteTask supabase error:', error);
        });
      },

      completeTask: (id) => {
        get().updateTask(id, { completedAt: new Date() } as any);
      },

      restoreTask: (id) => {
        get().updateTask(id, { completedAt: undefined } as any);
      },

      setActiveTask: (id) => set({ activeTaskId: id }),

      reorderTasks: (taskIds) => {
        const { tasks } = get();
        const taskMap = new Map(tasks.map((t) => [t.id, t]));
        const reordered = taskIds.map((id) => taskMap.get(id)).filter(Boolean) as Task[];
        const remaining = tasks.filter((t) => !taskIds.includes(t.id));

        const nowBase = Date.now();
        const reorderedWithOrder: any[] = reordered.map((t, idx) => ({
          ...(t as any),
          orderIndex: nowBase - idx,
          updatedAt: new Date(),
        }));

        set({ tasks: [...(reorderedWithOrder as Task[]), ...remaining] });

        void Promise.all(
          reorderedWithOrder.map((t) =>
            supabase
              .from('tasks')
              .update({
                order_index: (t as any).orderIndex,
                updated_at: new Date().toISOString(),
                data: serializeForJsonb(t),
                title: (t as any).title,
                completed_at: (t as any).completedAt
                  ? new Date((t as any).completedAt).toISOString()
                  : null,
              })
              .eq('id', (t as any).id)
          )
        ).then((results) => {
          const firstErr = (results as any[]).find((r) => r?.error)?.error;
          if (firstErr) console.error('reorderTasks supabase error:', firstErr);
        });
      },

      // ----------------------
      // UI
      // ----------------------
      toggleShowDoneTasks: () => set((state) => ({ showDoneTasks: !state.showDoneTasks })),
      setGroupedView: (view) => set({ groupedView: view }),
    }),
    {
      name: 'productivity-app-storage',
      // Supabase is source of truth for notes/tasks; keep only UI prefs locally
      partialize: (state) => ({
        groupedView: state.groupedView,
        showDoneTasks: state.showDoneTasks,
      }),
    }
  )
);
