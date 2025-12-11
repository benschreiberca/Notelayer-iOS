import { useState } from 'react';
import { Plus } from 'lucide-react';
import { useAppStore } from '@/stores/useAppStore';
import { NoteItem } from '@/components/notes/NoteItem';
import { NoteEditor } from '@/components/notes/NoteEditor';
import { useSwipeNavigation } from '@/hooks/useSwipeNavigation';

export default function NotesPage() {
  const { notes } = useAppStore();
  const [editingNoteId, setEditingNoteId] = useState<string | null | 'new'>(null);

  // Enable swipe navigation
  useSwipeNavigation();

  if (editingNoteId !== null) {
    return (
      <NoteEditor
        noteId={editingNoteId === 'new' ? null : editingNoteId}
        onBack={() => setEditingNoteId(null)}
      />
    );
  }

  return (
    <div className="flex flex-col h-full bg-background">
      {/* Header */}
      <header className="px-4 pt-6 pb-4 safe-area-top">
        <h1 className="text-2xl font-bold text-foreground">Notes</h1>
        <p className="text-sm text-muted-foreground mt-1">
          {notes.length} {notes.length === 1 ? 'note' : 'notes'}
        </p>
      </header>

      {/* Notes List */}
      <div className="flex-1 overflow-y-auto px-4 pb-4 smooth-scroll">
        {notes.length === 0 ? (
          <div className="flex flex-col items-center justify-center py-16 text-center">
            <div className="w-20 h-20 rounded-2xl bg-accent/10 flex items-center justify-center mb-4">
              <span className="text-3xl">📝</span>
            </div>
            <h3 className="text-lg font-semibold text-foreground mb-2">No notes yet</h3>
            <p className="text-sm text-muted-foreground max-w-[200px]">
              Tap the + button to create your first note
            </p>
          </div>
        ) : (
          <div className="space-y-3">
            {notes
              .sort((a, b) => new Date(b.updatedAt).getTime() - new Date(a.updatedAt).getTime())
              .map((note, index) => (
                <div
                  key={note.id}
                  className="animate-slide-up"
                  style={{ animationDelay: `${index * 50}ms` }}
                >
                  <NoteItem
                    note={note}
                    onClick={() => setEditingNoteId(note.id)}
                  />
                </div>
              ))}
          </div>
        )}
      </div>

      {/* Floating Add Button */}
      <button
        type="button"
        onClick={() => setEditingNoteId('new')}
        className="fixed right-4 bottom-24 w-14 h-14 rounded-full bg-primary shadow-elevated flex items-center justify-center text-primary-foreground hover:bg-primary/90 transition-all duration-200 tap-highlight active:scale-95 z-40"
      >
        <Plus className="w-6 h-6" />
      </button>
    </div>
  );
}
