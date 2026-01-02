import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import { supabase } from '@/integrations/supabase/client';

export type ThemeMode = 'system' | 'light' | 'dark';
export type Palette = 'default' | 'high-contrast' | 'warm' | 'cool' | 'neutral';

interface ThemeState {
  // Theme settings
  theme: ThemeMode;
  palette: Palette;
  
  // Resolved theme (actual light/dark based on system preference if theme is 'system')
  resolvedTheme: 'light' | 'dark';
  
  // Actions
  setTheme: (theme: ThemeMode) => void;
  setPalette: (palette: Palette) => void;
  setResolvedTheme: (resolved: 'light' | 'dark') => void;
  
  // Supabase sync
  loadFromSupabase: () => Promise<void>;
  saveToSupabase: () => Promise<void>;
}

// Helper to get system preference
const getSystemTheme = (): 'light' | 'dark' => {
  if (typeof window !== 'undefined') {
    return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
  }
  return 'light';
};

export const useThemeStore = create<ThemeState>()(
  persist(
    (set, get) => ({
      theme: 'system',
      palette: 'default',
      resolvedTheme: getSystemTheme(),

      setTheme: (theme) => {
        const resolved = theme === 'system' ? getSystemTheme() : theme;
        set({ theme, resolvedTheme: resolved });
        // Save to Supabase after state update
        setTimeout(() => get().saveToSupabase(), 0);
      },

      setPalette: (palette) => {
        set({ palette });
        // Save to Supabase after state update
        setTimeout(() => get().saveToSupabase(), 0);
      },

      setResolvedTheme: (resolved) => set({ resolvedTheme: resolved }),

      loadFromSupabase: async () => {
        try {
          const { data: { user } } = await supabase.auth.getUser();
          if (!user) return;

          const { data, error } = await supabase
            .from('user_preferences')
            .select('theme, palette')
            .eq('user_id', user.id)
            .single();

          if (error) {
            // If no preferences exist yet, that's fine
            if (error.code !== 'PGRST116') {
              console.error('loadFromSupabase error:', error);
            }
            return;
          }

          if (data) {
            const theme = (data.theme as ThemeMode) || 'system';
            const palette = (data.palette as Palette) || 'default';
            const resolved = theme === 'system' ? getSystemTheme() : theme;
            set({ theme, palette, resolvedTheme: resolved });
          }
        } catch (err) {
          console.error('loadFromSupabase error:', err);
        }
      },

      saveToSupabase: async () => {
        try {
          const { data: { user } } = await supabase.auth.getUser();
          if (!user) return;

          const { theme, palette } = get();
          
          const { error } = await supabase
            .from('user_preferences')
            .upsert({
              user_id: user.id,
              theme,
              palette,
              updated_at: new Date().toISOString(),
            }, {
              onConflict: 'user_id'
            });

          if (error) {
            console.error('saveToSupabase error:', error);
          }
        } catch (err) {
          console.error('saveToSupabase error:', err);
        }
      },
    }),
    {
      name: 'theme-storage',
      // Keep all theme settings in local storage for immediate load
      partialize: (state) => ({
        theme: state.theme,
        palette: state.palette,
        resolvedTheme: state.resolvedTheme,
      }),
    }
  )
);

// Initialize system theme listener
if (typeof window !== 'undefined') {
  const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)');
  
  const handleChange = (e: MediaQueryListEvent) => {
    const state = useThemeStore.getState();
    if (state.theme === 'system') {
      state.setResolvedTheme(e.matches ? 'dark' : 'light');
    }
  };
  
  mediaQuery.addEventListener('change', handleChange);
}
