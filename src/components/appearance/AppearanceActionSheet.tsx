import { Check } from 'lucide-react';
import { cn } from '@/lib/utils';
import { Drawer, DrawerClose, DrawerContent } from '@/components/ui/drawer';
import { Separator } from '@/components/ui/separator';
import { useAppearanceStore, type PaletteMode, type ThemeMode } from '@/stores/useAppearanceStore';

const THEME_OPTIONS: { value: ThemeMode; label: string }[] = [
  { value: 'system', label: 'System' },
  { value: 'light', label: 'Light' },
  { value: 'dark', label: 'Dark' },
];

const PALETTE_OPTIONS: { value: PaletteMode; label: string }[] = [
  { value: 'default', label: 'Default' },
  { value: 'high-contrast', label: 'High Contrast' },
  { value: 'warm', label: 'Warm' },
  { value: 'cool', label: 'Cool' },
  { value: 'neutral', label: 'Neutral' },
];

function ActionRow({
  label,
  selected,
  onClick,
}: {
  label: string;
  selected: boolean;
  onClick: () => void;
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      className={cn(
        'w-full px-4 py-3 text-left text-sm',
        'flex items-center justify-between',
        'text-foreground',
        'active:bg-muted/60 transition-colors'
      )}
    >
      <span className="font-medium">{label}</span>
      <Check className={cn('h-4 w-4', selected ? 'opacity-100 text-primary' : 'opacity-0')} />
    </button>
  );
}

export function AppearanceActionSheet({
  open,
  onOpenChange,
}: {
  open: boolean;
  onOpenChange: (open: boolean) => void;
}) {
  const theme = useAppearanceStore((s) => s.theme);
  const palette = useAppearanceStore((s) => s.palette);
  const setTheme = useAppearanceStore((s) => s.setTheme);
  const setPalette = useAppearanceStore((s) => s.setPalette);

  return (
    <Drawer open={open} onOpenChange={onOpenChange}>
      <DrawerContent className="pb-4">
        <div className="pb-2">
          <p className="text-center text-sm font-semibold text-foreground">Appearance</p>
          <p className="text-center text-xs text-muted-foreground mt-1">
            Changes apply instantly across the app
          </p>
        </div>

        <div className="mt-3 space-y-3 pb-2">
          {/* Theme group */}
          <div className="rounded-2xl overflow-hidden border border-border/50 bg-card">
            <div className="px-4 py-2 text-[11px] font-medium tracking-wide text-muted-foreground uppercase">
              Theme
            </div>
            <Separator className="bg-border/50" />
            {THEME_OPTIONS.map((opt, idx) => (
              <div key={opt.value}>
                <ActionRow label={opt.label} selected={theme === opt.value} onClick={() => setTheme(opt.value)} />
                {idx !== THEME_OPTIONS.length - 1 && <Separator className="bg-border/50" />}
              </div>
            ))}
          </div>

          {/* Palette group */}
          <div className="rounded-2xl overflow-hidden border border-border/50 bg-card">
            <div className="px-4 py-2 text-[11px] font-medium tracking-wide text-muted-foreground uppercase">
              Palette
            </div>
            <Separator className="bg-border/50" />
            {PALETTE_OPTIONS.map((opt, idx) => (
              <div key={opt.value}>
                <ActionRow
                  label={opt.label}
                  selected={palette === opt.value}
                  onClick={() => setPalette(opt.value)}
                />
                {idx !== PALETTE_OPTIONS.length - 1 && <Separator className="bg-border/50" />}
              </div>
            ))}
          </div>

          {/* Cancel button (separate group, iOS style) */}
          <div className="rounded-2xl overflow-hidden border border-border/50 bg-card">
            <DrawerClose asChild>
              <button
                type="button"
                className={cn(
                  'w-full px-4 py-3 text-center text-sm font-semibold',
                  'text-foreground active:bg-muted/60 transition-colors'
                )}
              >
                Cancel
              </button>
            </DrawerClose>
          </div>
        </div>
      </DrawerContent>
    </Drawer>
  );
}

