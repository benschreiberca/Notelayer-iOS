import { ThemeProvider, useTheme } from 'next-themes';
import { useEffect } from 'react';
import { supabase } from '@/integrations/supabase/client';
import { useAppearanceStore } from '@/stores/useAppearanceStore';

function AppearanceSync() {
  const themeMode = useAppearanceStore((s) => s.theme);
  const palette = useAppearanceStore((s) => s.palette);
  const initFromSupabase = useAppearanceStore((s) => s.initFromSupabase);
  const { setTheme } = useTheme();

  // Bootstrap: load per-user preferences (and re-run on auth changes).
  useEffect(() => {
    void initFromSupabase();
    const { data } = supabase.auth.onAuthStateChange(() => {
      void initFromSupabase();
    });
    return () => {
      data.subscription.unsubscribe();
    };
  }, [initFromSupabase]);

  // Theme: controlled by our store.
  useEffect(() => {
    setTheme(themeMode);
  }, [setTheme, themeMode]);

  // Palette: stored as a design-token switch on the root element.
  useEffect(() => {
    document.documentElement.dataset.palette = palette;
  }, [palette]);

  return null;
}

export function AppearanceProvider({ children }: { children: React.ReactNode }) {
  return (
    <ThemeProvider
      attribute="class"
      defaultTheme="system"
      enableSystem
      // reduce flashing when switching theme/palette
      disableTransitionOnChange
      // keep it separate from any legacy theme key
      storageKey="productivity-app-theme"
    >
      <AppearanceSync />
      {children}
    </ThemeProvider>
  );
}

