import { Check, Moon, Sun, Monitor, Palette as PaletteIcon } from 'lucide-react';
import { cn } from '@/lib/utils';
import { useThemeStore, ThemeMode, Palette } from '@/stores/useThemeStore';
import { getThemeLabel, getPaletteInfo, PALETTES, THEMES } from '@/components/ThemeProvider';
import {
  Sheet,
  SheetContent,
  SheetHeader,
  SheetTitle,
  SheetDescription,
} from '@/components/ui/sheet';

interface AppearanceSheetProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
}

export function AppearanceSheet({ open, onOpenChange }: AppearanceSheetProps) {
  const { theme, palette, setTheme, setPalette } = useThemeStore();

  const handleThemeSelect = (newTheme: ThemeMode) => {
    setTheme(newTheme);
  };

  const handlePaletteSelect = (newPalette: Palette) => {
    setPalette(newPalette);
  };

  const getThemeIcon = (t: ThemeMode) => {
    switch (t) {
      case 'system':
        return Monitor;
      case 'light':
        return Sun;
      case 'dark':
        return Moon;
    }
  };

  return (
    <Sheet open={open} onOpenChange={onOpenChange}>
      <SheetContent side="bottom" className="max-h-[85vh]">
        <SheetHeader>
          <SheetTitle>Appearance</SheetTitle>
          <SheetDescription>Customize the look and feel of the app</SheetDescription>
        </SheetHeader>

        <div className="flex flex-col gap-6 py-4 overflow-y-auto">
          {/* Theme Selection */}
          <div>
            <h3 className="text-sm font-semibold text-foreground mb-3 flex items-center gap-2">
              <Sun className="w-4 h-4" />
              Theme
            </h3>
            <div className="grid grid-cols-3 gap-2">
              {THEMES.map((t) => {
                const Icon = getThemeIcon(t);
                const isSelected = theme === t;
                
                return (
                  <button
                    key={t}
                    type="button"
                    onClick={() => handleThemeSelect(t)}
                    className={cn(
                      'flex flex-col items-center gap-2 p-4 rounded-xl border-2 transition-all duration-200 tap-highlight',
                      isSelected
                        ? 'border-primary bg-primary/10'
                        : 'border-border bg-card hover:border-primary/50 hover:bg-muted/50'
                    )}
                  >
                    <div
                      className={cn(
                        'w-10 h-10 rounded-full flex items-center justify-center transition-colors',
                        isSelected ? 'bg-primary text-primary-foreground' : 'bg-muted text-muted-foreground'
                      )}
                    >
                      <Icon className="w-5 h-5" />
                    </div>
                    <span className={cn(
                      'text-sm font-medium',
                      isSelected ? 'text-primary' : 'text-foreground'
                    )}>
                      {getThemeLabel(t)}
                    </span>
                    {isSelected && (
                      <Check className="w-4 h-4 text-primary absolute top-2 right-2" />
                    )}
                  </button>
                );
              })}
            </div>
          </div>

          {/* Divider */}
          <div className="divider" />

          {/* Palette Selection */}
          <div>
            <h3 className="text-sm font-semibold text-foreground mb-3 flex items-center gap-2">
              <PaletteIcon className="w-4 h-4" />
              Color Palette
            </h3>
            <div className="flex flex-col gap-2">
              {PALETTES.map((p) => {
                const info = getPaletteInfo(p);
                const isSelected = palette === p;
                
                return (
                  <button
                    key={p}
                    type="button"
                    onClick={() => handlePaletteSelect(p)}
                    className={cn(
                      'flex items-center gap-3 p-3 rounded-xl border-2 transition-all duration-200 tap-highlight text-left',
                      isSelected
                        ? 'border-primary bg-primary/10'
                        : 'border-border bg-card hover:border-primary/50 hover:bg-muted/50'
                    )}
                  >
                    {/* Color Preview */}
                    <div className="flex -space-x-1">
                      {info.colors.map((color, idx) => (
                        <div
                          key={idx}
                          className="w-6 h-6 rounded-full border-2 border-card"
                          style={{ backgroundColor: color }}
                        />
                      ))}
                    </div>
                    
                    {/* Text */}
                    <div className="flex-1 min-w-0">
                      <p className={cn(
                        'text-sm font-medium',
                        isSelected ? 'text-primary' : 'text-foreground'
                      )}>
                        {info.name}
                      </p>
                      <p className="text-xs text-muted-foreground truncate">
                        {info.description}
                      </p>
                    </div>
                    
                    {/* Check */}
                    {isSelected && (
                      <Check className="w-5 h-5 text-primary flex-shrink-0" />
                    )}
                  </button>
                );
              })}
            </div>
          </div>
        </div>
      </SheetContent>
    </Sheet>
  );
}
