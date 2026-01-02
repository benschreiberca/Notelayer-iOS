import { useState, useMemo, useEffect } from 'react';
import { Plus, MoreVertical, CheckSquare, Trash2, X, Palette } from 'lucide-react';
import { useAppStore } from '@/stores/useAppStore';
import { SwipeableNoteItem } from '@/components/notes/SwipeableNoteItem';
import { NoteEditor } from '@/components/notes/NoteEditor';
import { useSwipeNavigation } from '@/hooks/useSwipeNavigation';
import { AppearanceSheet } from '@/components/AppearanceSheet';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from '@/components/ui/alert-dialog';
import { toast } from '@/hooks/use-toast';

export default function NotesPage() {
  const { notes, deleteNote, deleteNotes, togglePinNote, loadNotesFromSupabase } = useAppStore();
  const [editingNoteId, setEditingNoteId] = useState<string | null | 'new'>(null);
  const [isSelectMode, setIsSelectMode] = useState(false);
  const [selectedNotes, setSelectedNotes] = useState<Set<string>>(new Set());
  const [showDeleteDialog, setShowDeleteDialog] = useState(false);
  const [noteToDelete, setNoteToDelete] = useState<string | null>(null);
  const [showAppearanceSheet, setShowAppearanceSheet] = useState(false);

  // Enable swipe navigation
  useSwipeNavigation();

  // Load notes from Supabase on first mount
  useEffect(() => {
    loadNotesFromSupabase();
  }, [loadNotesFromSupabase]);

  // Sort notes: pinned first, then by update time
  const sortedNotes = useMemo(() => {
    return [...notes].sort((a, b) => {
      // Pinned notes first
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      // Then by update time
      return new Date(b.updatedAt).getTime() - new Date(a.updatedAt).getTime();
    });
  }, [notes]);

  const pinnedNotes = sortedNotes.filter((n) => n.isPinned);
  const unpinnedNotes = sortedNotes.filter((n) => !n.isPinned);

  const toggleSelect = (id: string) => {
    setSelectedNotes((prev) => {
      const next = new Set(prev);
      if (next.has(id)) {
        next.delete(id);
      } else {
        next.add(id);
      }
      return next;
    });
  };

  const selectAll = () => {
    setSelectedNotes(new Set(notes.map((n) => n.id)));
  };

  const clearSelection = () => {
    setSelectedNotes(new Set());
    setIsSelectMode(false);
  };

  const handleDeleteSelected = () => {
    if (selectedNotes.size === 0) return;
    setShowDeleteDialog(true);
  };

  const confirmDeleteSelected = () => {
    deleteNotes(Array.from(selectedNotes));
    toast({
      title: 'Notes deleted',
      description: `${selectedNotes.size} note${selectedNotes.size > 1 ? 's' : ''} deleted`,
    });
    clearSelection();
    setShowDeleteDialog(false);
  };

  const handleSingleDelete = (id: string) => {
    setNoteToDelete(id);
    setShowDeleteDialog(true);
  };

  const confirmSingleDelete = () => {
    if (noteToDelete) {
      deleteNote(noteToDelete);
      toast({
        title: 'Note deleted',
        description: 'Note has been deleted',
      });
    }
    setNoteToDelete(null);
    setShowDeleteDialog(false);
  };

  const handlePin = (id: string) => {
    togglePinNote(id);
    const note = notes.find((n) => n.id === id);
    toast({
      title: note?.isPinned ? 'Note unpinned' : 'Note pinned',
      description: note?.isPinned ? 'Note removed from pinned' : 'Note added to pinned',
    });
  };

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
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold text-foreground">Notes</h1>
            <p className="text-sm text-muted-foreground mt-1">
              {notes.length} {notes.length === 1 ? 'note' : 'notes'}
            </p>
          </div>

          {isSelectMode ? (
            <div className="flex items-center gap-2">
              <span className="text-sm text-muted-foreground">{selectedNotes.size} selected</span>
              <button
                type="button"
                onClick={handleDeleteSelected}
                disabled={selectedNotes.size === 0}
                className="p-2 rounded-lg text-destructive hover:bg-destructive/10 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
              >
                <Trash2 className="w-5 h-5" />
              </button>
              <button
                type="button"
                onClick={clearSelection}
                className="p-2 rounded-lg text-muted-foreground hover:bg-muted transition-colors"
              >
                <X className="w-5 h-5" />
              </button>
            </div>
          ) : (
            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <button
                  type="button"
                  className="p-2 rounded-lg text-muted-foreground hover:bg-muted transition-colors"
                >
                  <MoreVertical className="w-5 h-5" />
                </button>
              </DropdownMenuTrigger>
              <DropdownMenuContent align="end" className="w-48 bg-popover z-50">
                <DropdownMenuItem
                  onClick={() => setIsSelectMode(true)}
                  className="flex items-center gap-2"
                >
                  <CheckSquare className="w-4 h-4" />
                  Select Notes
                </DropdownMenuItem>
                <DropdownMenuItem onClick={selectAll} className="flex items-center gap-2">
                  <CheckSquare className="w-4 h-4" />
                  Select All
                </DropdownMenuItem>
                <DropdownMenuSeparator />
                <DropdownMenuItem
                  onClick={() => setShowAppearanceSheet(true)}
                  className="flex items-center gap-2"
                >
                  <Palette className="w-4 h-4" />
                  Appearance
                </DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>
          )}
        </div>
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
            {/* Pinned Section */}
            {pinnedNotes.length > 0 && (
              <>
                <p className="text-xs font-medium text-muted-foreground uppercase tracking-wide px-1">
                  Pinned
                </p>
                {pinnedNotes.map((note, index) => (
                  <div
                    key={note.id}
                    className="animate-slide-up"
                    style={{ animationDelay: `${index * 50}ms` }}
                  >
                    <SwipeableNoteItem
                      note={note}
                      onClick={() => setEditingNoteId(note.id)}
                      onPin={() => handlePin(note.id)}
                      onDelete={() => handleSingleDelete(note.id)}
                      isSelectMode={isSelectMode}
                      isSelected={selectedNotes.has(note.id)}
                      onSelect={() => toggleSelect(note.id)}
                    />
                  </div>
                ))}
              </>
            )}

            {/* Regular Notes */}
            {unpinnedNotes.length > 0 && pinnedNotes.length > 0 && (
              <p className="text-xs font-medium text-muted-foreground uppercase tracking-wide px-1 pt-2">
                Notes
              </p>
            )}
            {unpinnedNotes.map((note, index) => (
              <div
                key={note.id}
                className="animate-slide-up"
                style={{ animationDelay: `${(pinnedNotes.length + index) * 50}ms` }}
              >
                <SwipeableNoteItem
                  note={note}
                  onClick={() => setEditingNoteId(note.id)}
                  onPin={() => handlePin(note.id)}
                  onDelete={() => handleSingleDelete(note.id)}
                  isSelectMode={isSelectMode}
                  isSelected={selectedNotes.has(note.id)}
                  onSelect={() => toggleSelect(note.id)}
                />
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Floating Add Button */}
      {!isSelectMode && (
        <button
          type="button"
          onClick={() => setEditingNoteId('new')}
          className="fixed right-4 bottom-24 w-14 h-14 rounded-full bg-primary shadow-elevated flex items-center justify-center text-primary-foreground hover:bg-primary/90 transition-all duration-200 tap-highlight active:scale-95 z-40"
        >
          <Plus className="w-6 h-6" />
        </button>
      )}

      {/* Delete Confirmation Dialog */}
      <AlertDialog open={showDeleteDialog} onOpenChange={setShowDeleteDialog}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Delete {noteToDelete ? 'Note' : 'Notes'}?</AlertDialogTitle>
            <AlertDialogDescription>
              {noteToDelete
                ? 'This action cannot be undone. This note will be permanently deleted.'
                : `This action cannot be undone. ${selectedNotes.size} note${
                    selectedNotes.size > 1 ? 's' : ''
                  } will be permanently deleted.`}
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel onClick={() => setNoteToDelete(null)}>Cancel</AlertDialogCancel>
            <AlertDialogAction
              onClick={noteToDelete ? confirmSingleDelete : confirmDeleteSelected}
              className="bg-destructive text-destructive-foreground hover:bg-destructive/90"
            >
              Delete
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>

      {/* Appearance Sheet */}
      <AppearanceSheet open={showAppearanceSheet} onOpenChange={setShowAppearanceSheet} />
    </div>
  );
}
