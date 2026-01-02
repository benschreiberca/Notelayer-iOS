import { useEffect } from 'react';
import { useThemeStore, ThemeMode, Palette } from '@/stores/useThemeStore';

interface ThemeProviderProps {
  children: React.ReactNode;
}

export function ThemeProvider({ children }: ThemeProviderProps) {
  const { resolvedTheme, palette, loadFromSupabase } = useThemeStore();

  // Load user preferences from Supabase on mount
  useEffect(() => {
    loadFromSupabase();
  }, [loadFromSupabase]);

  // Apply theme class to document
  useEffect(() => {
    const root = window.document.documentElement;
    
    // Remove previous theme classes
    root.classList.remove('light', 'dark');
    
    // Add resolved theme class
    root.classList.add(resolvedTheme);
  }, [resolvedTheme]);

  // Apply palette as data attribute
  useEffect(() => {
    const root = window.document.documentElement;
    root.setAttribute('data-palette', palette);
  }, [palette]);

  return <>{children}</>;
}

// Hook to get theme display name
export function getThemeLabel(theme: ThemeMode): string {
  switch (theme) {
    case 'system':
      return 'System';
    case 'light':
      return 'Light';
    case 'dark':
      return 'Dark';
  }
}

// Hook to get palette display info
export function getPaletteInfo(palette: Palette): { name: string; description: string; colors: string[] } {
  switch (palette) {
    case 'default':
      return {
        name: 'Default',
        description: 'Warm paper-like aesthetic',
        colors: ['#4A5568', '#F5A623', '#68D391'],
      };
    case 'high-contrast':
      return {
        name: 'High Contrast',
        description: 'Maximum readability',
        colors: ['#000000', '#0066CC', '#FFFFFF'],
      };
    case 'warm':
      return {
        name: 'Warm',
        description: 'Cozy amber and orange tones',
        colors: ['#B7791F', '#DD6B20', '#F6AD55'],
      };
    case 'cool':
      return {
        name: 'Cool',
        description: 'Calm blue and teal tones',
        colors: ['#2B6CB0', '#319795', '#63B3ED'],
      };
    case 'neutral':
      return {
        name: 'Neutral',
        description: 'Clean grayscale aesthetic',
        colors: ['#4A5568', '#718096', '#A0AEC0'],
      };
  }
}

export const PALETTES: Palette[] = ['default', 'high-contrast', 'warm', 'cool', 'neutral'];
export const THEMES: ThemeMode[] = ['system', 'light', 'dark'];
