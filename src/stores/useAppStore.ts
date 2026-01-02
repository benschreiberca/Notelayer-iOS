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
type UnknownRecord = Record<string, unknown>;
const isRecord = (v: unknown): v is UnknownRecord => !!v && typeof v === 'object' && !Array.isArray(v);

const isIsoDateString = (v: unknown): v is string =>
  typeof v === 'string' && /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d+)?Z$/.test(v);

const reviveDatesDeep = (obj: unknown): unknown => {
  if (Array.isArray(obj)) return obj.map(reviveDatesDeep);
  if (isRecord(obj)) {
    const out: UnknownRecord = {};
    for (const [k, v] of Object.entries(obj)) out[k] = reviveDatesDeep(v);
    return out;
  }
  if (isIsoDateString(obj)) return new Date(obj);
  return obj;
};

const serializeForJsonb = <T,>(obj: T): unknown =>
  JSON.parse(JSON.stringify(obj, (_k: string, v: unknown) => (v instanceof Date ? v.toISOString() : v)));

// ---- Notes mapping ----
type NoteRow = {
  id: string;
  title?: string | null;
  content?: string | null;
  plain_text?: string | null;
  is_pinned?: boolean | null;
  created_at?: string | null;
  updated_at?: string | null;
  data?: unknown;
};

type TaskRow = {
  id: string;
  title?: string | null;
  completed_at?: string | null;
  order_index?: number | null;
  created_at?: string | null;
  updated_at?: string | null;
  data?: unknown;
};

type TaskWithOrderIndex = Task & { orderIndex?: number };

const rowToNote = (row: NoteRow): Note => {
  const base =
    row.data && isRecord(row.data) && Object.keys(row.data).length
      ? (reviveDatesDeep(row.data) as Partial<Note> & { isPinned?: boolean; plainText?: string })
      : {};
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
const rowToTask = (row: TaskRow): TaskWithOrderIndex => {
  const base =
    row.data && isRecord(row.data) && Object.keys(row.data).length
      ? (reviveDatesDeep(row.data) as Partial<TaskWithOrderIndex>)
      : {};

  const task: TaskWithOrderIndex = {
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

  // not in the Task TS type, but used to sort/reorder in DB
  task.orderIndex = row.order_index ?? base.orderIndex ?? Date.now();

  return task;
};

const taskToRow = (task: TaskWithOrderIndex) => ({
  id: task.id,
  title: task.title,
  completed_at: task.completedAt ? task.completedAt.toISOString() : null,
  order_index: task.orderIndex ?? Date.now(),
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
          id,
          title: noteData.title ?? '',
          content: noteData.content ?? '',
          plainText: noteData.plainText ?? '',
          isPinned: noteData.isPinned ?? false,
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
            n.id === id ? { ...n, ...updates, updatedAt: new Date() } : n
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
        get().updateNote(id, { isPinned: !note.isPinned });
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

        const task: TaskWithOrderIndex = {
          id,
          title: taskData.title,
          categories: taskData.categories ?? [],
          priority: taskData.priority ?? 'medium',
          dueDate: taskData.dueDate,
          completedAt: taskData.completedAt,
          parentTaskId: taskData.parentTaskId,
          attachments: taskData.attachments ?? [],
          noteId: taskData.noteId,
          noteLine: taskData.noteLine,
          taskNotes: taskData.taskNotes,
          createdAt: now,
          updatedAt: now,
          inputMethod: taskData.inputMethod ?? 'text',
          orderIndex: Date.now(),
        };

        // optimistic UI
        set((state) => ({ tasks: [task, ...state.tasks] }));

        void supabase.from('tasks').insert([taskToRow(task)]).then(({ error }) => {
          if (error) console.error('addTask supabase error:', error);
        });

        return id;
      },

      updateTask: (id, updates) => {
        set((state) => ({
          tasks: state.tasks.map((t) =>
            t.id === id ? ({ ...(t as TaskWithOrderIndex), ...updates, updatedAt: new Date() } as TaskWithOrderIndex) : t
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
        get().updateTask(id, { completedAt: new Date() });
      },

      restoreTask: (id) => {
        get().updateTask(id, { completedAt: undefined });
      },

      setActiveTask: (id) => set({ activeTaskId: id }),

      reorderTasks: (taskIds) => {
        const { tasks } = get();
        const taskMap = new Map(tasks.map((t) => [t.id, t]));
        const reordered = taskIds.map((id) => taskMap.get(id)).filter((t): t is TaskWithOrderIndex => !!t);
        const remaining = tasks.filter((t) => !taskIds.includes(t.id));

        const nowBase = Date.now();
        const reorderedWithOrder: TaskWithOrderIndex[] = reordered.map((t, idx) => ({
          ...(t as TaskWithOrderIndex),
          orderIndex: nowBase - idx,
          updatedAt: new Date(),
        }));

        set({ tasks: [...reorderedWithOrder, ...remaining] });

        void Promise.all(
          reorderedWithOrder.map((t) =>
            supabase
              .from('tasks')
              .update({
                order_index: t.orderIndex ?? Date.now(),
                updated_at: new Date().toISOString(),
                data: serializeForJsonb(t),
                title: t.title,
                completed_at: t.completedAt
                  ? new Date(t.completedAt).toISOString()
                  : null,
              })
              .eq('id', t.id)
          )
        ).then((results) => {
          const firstErr = results.find((r) => !!r.error)?.error;
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
