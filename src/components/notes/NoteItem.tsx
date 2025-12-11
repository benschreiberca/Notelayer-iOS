import { FileText, ChevronRight } from 'lucide-react';
import { cn } from '@/lib/utils';
import { Note } from '@/types';
import { formatDistanceToNow } from 'date-fns';

interface NoteItemProps {
  note: Note;
  onClick?: () => void;
  className?: string;
}

export function NoteItem({ note, onClick, className }: NoteItemProps) {
  const preview = note.plainText?.slice(0, 100) || '';
  const timeAgo = formatDistanceToNow(new Date(note.updatedAt), { addSuffix: true });

  return (
    <button
      type="button"
      onClick={onClick}
      className={cn(
        'w-full text-left bg-card rounded-xl border border-border/50 shadow-soft p-4 transition-all duration-200 tap-highlight',
        'hover:shadow-card hover:border-border active:scale-[0.98]',
        className
      )}
    >
      <div className="flex items-start gap-3">
        <div className="w-10 h-10 rounded-lg bg-accent/20 flex items-center justify-center flex-shrink-0">
          <FileText className="w-5 h-5 text-accent" />
        </div>

        <div className="flex-1 min-w-0">
          <h3 className="text-sm font-semibold text-foreground truncate">
            {note.title || 'Untitled Note'}
          </h3>
          
          {preview && (
            <p className="text-xs text-muted-foreground mt-1 line-clamp-2">
              {preview}
            </p>
          )}
          
          <p className="text-[10px] text-muted-foreground/70 mt-2">
            {timeAgo}
          </p>
        </div>

        <ChevronRight className="w-4 h-4 text-muted-foreground flex-shrink-0 mt-1" />
      </div>
    </button>
  );
}
