import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import { supabase } from '@/integrations/supabase/client';

export type ThemeMode = 'system' | 'light' | 'dark';
export type PaletteMode = 'default' | 'high-contrast' | 'warm' | 'cool' | 'neutral';

type AppearanceState = {
  theme: ThemeMode;
  palette: PaletteMode;
  hydrated: boolean;
  initFromSupabase: () => Promise<void>;
  setTheme: (theme: ThemeMode) => void;
  setPalette: (palette: PaletteMode) => void;
};

const APPEARANCE_TABLE = 'user_appearance';

let activeUserId: string | null = null;
let activeChannel: ReturnType<typeof supabase.channel> | null = null;

type UnknownRecord = Record<string, unknown>;
const isRecord = (v: unknown): v is UnknownRecord => !!v && typeof v === 'object';

async function getUserId(): Promise<string | null> {
  const { data, error } = await supabase.auth.getSession();
  if (error) {
    console.warn('getSession error:', error);
    return null;
  }
  return data.session?.user?.id ?? null;
}

async function fetchRemoteAppearance(userId: string): Promise<{
  theme?: ThemeMode | null;
  palette?: PaletteMode | null;
} | null> {
  const { data, error } = await supabase
    .from(APPEARANCE_TABLE)
    // keep it minimal; schema may differ across environments
    .select('theme, palette')
    .eq('user_id', userId)
    .maybeSingle();

  if (error) {
    // If the table doesn't exist yet in a dev env, just fall back to local.
    console.warn('fetchRemoteAppearance error:', error);
    return null;
  }

  if (!data) return null;
  if (!isRecord(data)) return null;
  return {
    theme: (data.theme as ThemeMode | null | undefined) ?? null,
    palette: (data.palette as PaletteMode | null | undefined) ?? null,
  };
}

async function upsertRemoteAppearance(userId: string, theme: ThemeMode, palette: PaletteMode) {
  const { error } = await supabase
    .from(APPEARANCE_TABLE)
    .upsert(
      {
        user_id: userId,
        theme,
        palette,
        updated_at: new Date().toISOString(),
      },
      { onConflict: 'user_id' }
    );

  if (error) console.warn('upsertRemoteAppearance error:', error);
}

function teardownRealtime() {
  if (activeChannel) {
    void supabase.removeChannel(activeChannel);
    activeChannel = null;
  }
  activeUserId = null;
}

function ensureRealtime(
  userId: string,
  onRemoteChange: (next: { theme?: ThemeMode; palette?: PaletteMode }) => void
) {
  if (activeUserId === userId && activeChannel) return;

  teardownRealtime();
  activeUserId = userId;

  activeChannel = supabase
    .channel(`user_appearance:${userId}`)
    .on(
      'postgres_changes',
      {
        event: '*',
        schema: 'public',
        table: APPEARANCE_TABLE,
        filter: `user_id=eq.${userId}`,
      },
      (payload) => {
        const p = payload as unknown;
        if (!isRecord(p)) return;
        const nextRow = (p.new ?? p.record) as unknown;
        if (!isRecord(nextRow)) return;
        onRemoteChange({
          theme: nextRow.theme as ThemeMode,
          palette: nextRow.palette as PaletteMode,
        });
      }
    )
    .subscribe();
}

export const useAppearanceStore = create<AppearanceState>()(
  persist(
    (set, get) => ({
      theme: 'system',
      palette: 'default',
      hydrated: false,

      initFromSupabase: async () => {
        const userId = await getUserId();

        if (!userId) {
          teardownRealtime();
          set({ hydrated: true });
          return;
        }

        ensureRealtime(userId, (next) => {
          const { theme, palette } = get();
          set({
            theme: next.theme ?? theme,
            palette: next.palette ?? palette,
          });
        });

        const remote = await fetchRemoteAppearance(userId);
        if (remote?.theme || remote?.palette) {
          set({
            theme: (remote.theme ?? get().theme) as ThemeMode,
            palette: (remote.palette ?? get().palette) as PaletteMode,
            hydrated: true,
          });
          return;
        }

        // First-time user: create a row with current local values.
        const local = get();
        await upsertRemoteAppearance(userId, local.theme, local.palette);
        set({ hydrated: true });
      },

      setTheme: (theme) => {
        set({ theme });
        if (activeUserId) void upsertRemoteAppearance(activeUserId, theme, get().palette);
      },

      setPalette: (palette) => {
        set({ palette });
        if (activeUserId) void upsertRemoteAppearance(activeUserId, get().theme, palette);
      },
    }),
    {
      name: 'productivity-app-appearance',
      partialize: (s) => ({ theme: s.theme, palette: s.palette }),
      onRehydrateStorage: () => () => {
        // Do not mark hydrated here; we still want initFromSupabase to run.
      },
    }
  )
);

