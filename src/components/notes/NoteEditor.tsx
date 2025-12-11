import { useState, useEffect, useRef } from 'react';
import { ArrowLeft, Bold, Italic, Underline, List, ListOrdered, Heading1, CheckSquare, Minus, MoreHorizontal } from 'lucide-react';
import { cn } from '@/lib/utils';
import { Note } from '@/types';
import { useAppStore } from '@/stores/useAppStore';

interface NoteEditorProps {
  noteId: string | null;
  onBack: () => void;
}

export function NoteEditor({ noteId, onBack }: NoteEditorProps) {
  const { notes, addNote, updateNote } = useAppStore();
  const note = notes.find((n) => n.id === noteId);
  
  const [title, setTitle] = useState(note?.title || '');
  const [content, setContent] = useState(note?.content || '');
  const contentRef = useRef<HTMLDivElement>(null);
  const titleRef = useRef<HTMLInputElement>(null);
  const isNewNote = !noteId;

  useEffect(() => {
    if (note) {
      setTitle(note.title);
      setContent(note.content);
      if (contentRef.current) {
        contentRef.current.innerHTML = note.content;
      }
    }
  }, [note]);

  useEffect(() => {
    if (isNewNote && titleRef.current) {
      titleRef.current.focus();
    }
  }, [isNewNote]);

  const handleSave = () => {
    const plainText = contentRef.current?.textContent || '';
    
    if (noteId) {
      updateNote(noteId, {
        title: title || 'Untitled Note',
        content: contentRef.current?.innerHTML || '',
        plainText,
      });
    } else if (title || plainText) {
      addNote({
        title: title || 'Untitled Note',
        content: contentRef.current?.innerHTML || '',
        plainText,
      });
    }
  };

  const handleBack = () => {
    handleSave();
    onBack();
  };

  const execCommand = (command: string, value?: string) => {
    document.execCommand(command, false, value);
    contentRef.current?.focus();
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
          className={cn(
            'min-h-[200px] outline-none text-foreground leading-relaxed',
            '[&>h1]:text-2xl [&>h1]:font-bold [&>h1]:mt-6 [&>h1]:mb-3',
            '[&>h2]:text-xl [&>h2]:font-semibold [&>h2]:mt-5 [&>h2]:mb-2',
            '[&>h3]:text-lg [&>h3]:font-medium [&>h3]:mt-4 [&>h3]:mb-2',
            '[&>ul]:list-disc [&>ul]:pl-5 [&>ul]:my-2',
            '[&>ol]:list-decimal [&>ol]:pl-5 [&>ol]:my-2',
            '[&>li]:my-1',
            '[&>hr]:my-4 [&>hr]:border-border',
            'empty:before:content-[attr(data-placeholder)] empty:before:text-muted-foreground/50'
          )}
          data-placeholder="Start typing..."
          onInput={() => {
            // Auto-save on input
            handleSave();
          }}
          suppressContentEditableWarning
        />
      </div>
    </div>
  );
}
