import { useState, useEffect, useRef } from 'react';
import { ArrowLeft, Bold, Italic, Underline, List, ListOrdered, Heading1, Minus, MoreHorizontal, ListPlus } from 'lucide-react';
import { cn } from '@/lib/utils';
import { Note } from '@/types';
import { useAppStore } from '@/stores/useAppStore';
import { QuickTaskSheet } from './QuickTaskSheet';
import { useLongPress } from '@/hooks/useLongPress';

interface NoteEditorProps {
  noteId: string | null;
  onBack: () => void;
}

export function NoteEditor({ noteId, onBack }: NoteEditorProps) {
  const { notes, addNote, updateNote } = useAppStore();
  const note = notes.find((n) => n.id === noteId);
  
  const [title, setTitle] = useState(note?.title || '');
  const [content, setContent] = useState(note?.content || '');
  const [currentNoteId, setCurrentNoteId] = useState<string | null>(noteId);
  const contentRef = useRef<HTMLDivElement>(null);
  const titleRef = useRef<HTMLInputElement>(null);
  const isNewNote = !currentNoteId;

  // Quick task sheet state
  const [showQuickTask, setShowQuickTask] = useState(false);
  const [selectedText, setSelectedText] = useState('');

  // Track if we've initialized this note to avoid resetting innerHTML on our own updates
  const hasInitializedRef = useRef(false);
  const lastNoteIdRef = useRef<string | null>(null);

  // Reset initialization flag when noteId changes
  if (noteId !== lastNoteIdRef.current) {
    hasInitializedRef.current = false;
    lastNoteIdRef.current = noteId;
  }

  useEffect(() => {
    // Only set innerHTML once when the note is first loaded
    // Skip if we've already initialized this note (prevents re-setting on our own edits)
    if (note && !hasInitializedRef.current) {
      setTitle(note.title);
      setContent(note.content);
      if (contentRef.current) {
        contentRef.current.innerHTML = note.content;
      }
      hasInitializedRef.current = true;
    }
  }, [note]);

  useEffect(() => {
    if (isNewNote && titleRef.current) {
      titleRef.current.focus();
    }
  }, [isNewNote]);

  const handleSave = () => {
    const plainText = contentRef.current?.textContent || '';
    
    if (currentNoteId) {
      updateNote(currentNoteId, {
        title: title || 'Untitled Note',
        content: contentRef.current?.innerHTML || '',
        plainText,
      });
    } else if (title || plainText) {
      // For new notes, only save on explicit back action
      // This prevents duplicate notes from being created on every input
    }
  };

  const handleSaveNewNote = () => {
    const plainText = contentRef.current?.textContent || '';
    if (title || plainText) {
      const newId = addNote({
        title: title || 'Untitled Note',
        content: contentRef.current?.innerHTML || '',
        plainText,
      });
      setCurrentNoteId(newId);
    }
  };

  const handleBack = () => {
    if (isNewNote) {
      handleSaveNewNote();
    } else {
      handleSave();
    }
    onBack();
  };

  const execCommand = (command: string, value?: string) => {
    document.execCommand(command, false, value);
    contentRef.current?.focus();
  };

  // Handle automatic list formatting
  const handleKeyDown = (e: React.KeyboardEvent<HTMLDivElement>) => {
    if (e.key === 'Enter') {
      const selection = window.getSelection();
      if (!selection || selection.rangeCount === 0) return;

      const range = selection.getRangeAt(0);
      const currentNode = range.startContainer;
      
      // Check if we're in a list item
      const listItem = currentNode.parentElement?.closest('li');
      if (listItem) {
        const textContent = listItem.textContent || '';
        // If list item is empty, exit the list
        if (textContent.trim() === '') {
          e.preventDefault();
          const list = listItem.closest('ul, ol');
          if (list) {
            // Create a new paragraph after the list
            const p = document.createElement('p');
            p.innerHTML = '<br>';
            list.parentNode?.insertBefore(p, list.nextSibling);
            // Remove empty list item
            listItem.remove();
            // If list is now empty, remove it
            if (list.children.length === 0) {
              list.remove();
            }
            // Move cursor to the new paragraph
            const newRange = document.createRange();
            newRange.setStart(p, 0);
            newRange.collapse(true);
            selection.removeAllRanges();
            selection.addRange(newRange);
          }
        }
        // Otherwise, default Enter behavior will continue the list
      }
    }
  };

  const handleInput = () => {
    // Only auto-save for existing notes, not new ones
    if (currentNoteId) {
      handleSave();
    }
    
    const selection = window.getSelection();
    if (!selection || selection.rangeCount === 0) return;

    const range = selection.getRangeAt(0);
    const currentNode = range.startContainer;
    
    // Only process if we're in a text node
    if (currentNode.nodeType !== Node.TEXT_NODE) return;
    
    const textContent = currentNode.textContent || '';
    const cursorPosition = range.startOffset;
    
    // Check if we're at the start of a line (not inside a list already)
    const parentElement = currentNode.parentElement;
    if (parentElement?.closest('li')) return; // Already in a list
    
    // Check for bullet list trigger: "- " at start
    if (textContent.startsWith('- ') && cursorPosition >= 2) {
      // Remove the "- " and convert to bullet list
      const remainingText = textContent.substring(2);
      
      // Clear the current text
      currentNode.textContent = remainingText;
      
      // Execute bullet list command
      document.execCommand('insertUnorderedList', false);
      
      // Move cursor to end of the text
      setTimeout(() => {
        const newSelection = window.getSelection();
        if (newSelection && contentRef.current) {
          const li = contentRef.current.querySelector('li:last-of-type');
          if (li && li.firstChild) {
            const newRange = document.createRange();
            newRange.setStartAfter(li.firstChild);
            newRange.collapse(true);
            newSelection.removeAllRanges();
            newSelection.addRange(newRange);
          }
        }
      }, 0);
      return;
    }
    
    // Check for numbered list trigger: "1. " or any "N. " at start
    const numberedMatch = textContent.match(/^(\d+)\.\s/);
    if (numberedMatch && cursorPosition >= numberedMatch[0].length) {
      // Remove the "N. " and convert to numbered list
      const remainingText = textContent.substring(numberedMatch[0].length);
      
      // Clear the current text
      currentNode.textContent = remainingText;
      
      // Execute numbered list command
      document.execCommand('insertOrderedList', false);
      
      // Move cursor to end of the text
      setTimeout(() => {
        const newSelection = window.getSelection();
        if (newSelection && contentRef.current) {
          const li = contentRef.current.querySelector('ol li:last-of-type');
          if (li && li.firstChild) {
            const newRange = document.createRange();
            newRange.setStartAfter(li.firstChild);
            newRange.collapse(true);
            newSelection.removeAllRanges();
            newSelection.addRange(newRange);
          }
        }
      }, 0);
    }
  };

  const handleCreateTaskFromSelection = () => {
    const selection = window.getSelection();
    if (selection && selection.toString().trim()) {
      setSelectedText(selection.toString().trim());
      setShowQuickTask(true);
    } else {
      // If no selection, use placeholder or current line
      setSelectedText('');
      setShowQuickTask(true);
    }
  };

  const formatButtons = [
    { icon: Bold, command: 'bold', label: 'Bold' },
    { icon: Italic, command: 'italic', label: 'Italic' },
    { icon: Underline, command: 'underline', label: 'Underline' },
    { icon: Heading1, command: 'formatBlock', value: 'h2', label: 'Heading' },
    { icon: List, command: 'insertUnorderedList', label: 'Bullet List' },
    { icon: ListOrdered, command: 'insertOrderedList', label: 'Numbered List' },
    { icon: Minus, command: 'insertHorizontalRule', label: 'Divider' },
  ];

  // Long press handler for content area
  const contentLongPress = useLongPress({
    delay: 600,
    onLongPress: handleCreateTaskFromSelection,
  });

  return (
    <div className="flex flex-col h-full bg-background">
      {/* Header */}
      <header className="flex items-center gap-3 px-4 py-3 border-b border-border/50 bg-card/80 backdrop-blur-sm sticky top-0 z-10">
        <button
          type="button"
          onClick={handleBack}
          className="p-2 -ml-2 rounded-lg text-muted-foreground hover:text-foreground hover:bg-muted/50 transition-colors tap-highlight"
        >
          <ArrowLeft className="w-5 h-5" />
        </button>
        
        <div className="flex-1" />
        
        {/* Add Task Button */}
        <button
          type="button"
          onClick={handleCreateTaskFromSelection}
          className="p-2 rounded-lg text-primary hover:bg-primary/10 transition-colors"
          title="Create task from note"
        >
          <ListPlus className="w-5 h-5" />
        </button>
        
        <button
          type="button"
          className="p-2 rounded-lg text-muted-foreground hover:text-foreground hover:bg-muted/50 transition-colors"
        >
          <MoreHorizontal className="w-5 h-5" />
        </button>
      </header>

      {/* Formatting Toolbar */}
      <div className="flex items-center gap-1 px-4 py-2 border-b border-border/30 overflow-x-auto hide-scrollbar">
        {formatButtons.map(({ icon: Icon, command, value, label }) => (
          <button
            key={command}
            type="button"
            onClick={() => execCommand(command, value)}
            className="p-2.5 rounded-lg text-muted-foreground hover:text-foreground hover:bg-muted/50 transition-colors tap-highlight flex-shrink-0"
            title={label}
          >
            <Icon className="w-4 h-4" />
          </button>
        ))}
      </div>

      {/* Editor */}
      <div className="flex-1 overflow-y-auto px-4 py-4">
        <input
          ref={titleRef}
          type="text"
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          placeholder="Title"
          className="w-full bg-transparent text-xl font-bold text-foreground placeholder:text-muted-foreground/50 outline-none mb-4"
        />
        
        <div
          ref={contentRef}
          contentEditable
          {...contentLongPress}
          onKeyDown={handleKeyDown}
          onInput={handleInput}
          className={cn(
            'min-h-[200px] outline-none text-foreground leading-relaxed select-text',
            '[&>h1]:text-2xl [&>h1]:font-bold [&>h1]:mt-6 [&>h1]:mb-3',
            '[&>h2]:text-xl [&>h2]:font-semibold [&>h2]:mt-5 [&>h2]:mb-2',
            '[&>h3]:text-lg [&>h3]:font-medium [&>h3]:mt-4 [&>h3]:mb-2',
            '[&>ul]:list-disc [&>ul]:pl-5 [&>ul]:my-2',
            '[&>ol]:list-decimal [&>ol]:pl-5 [&>ol]:my-2',
            '[&>li]:my-1',
            '[&>hr]:my-4 [&>hr]:border-border',
            'empty:before:content-[attr(data-placeholder)] empty:before:text-muted-foreground/50'
          )}
          data-placeholder="Start typing... (long-press to create task)"
          suppressContentEditableWarning
        />
      </div>

      {/* Quick Task Sheet */}
      <QuickTaskSheet
        open={showQuickTask}
        onOpenChange={setShowQuickTask}
        initialTitle={selectedText}
        noteId={noteId || undefined}
      />
    </div>
  );
}
