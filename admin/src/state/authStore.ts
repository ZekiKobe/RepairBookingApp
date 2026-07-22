import { create } from 'zustand';
import type { AuthUser, AuthTokens } from '@/types/api';
import { setStoredTokens } from '@/lib/axios';

type AuthState = {
  user: AuthUser | null;
  hydrated: boolean;
  setSession: (user: AuthUser, tokens: AuthTokens) => void;
  clearSession: () => void;
  setUser: (user: AuthUser | null) => void;
  markHydrated: () => void;
  hasPermission: (key: string) => boolean;
};

export const useAuthStore = create<AuthState>((set, get) => ({
  user: null,
  hydrated: false,

  setSession: (user, tokens) => {
    setStoredTokens(tokens);
    set({ user });
  },

  clearSession: () => {
    setStoredTokens(null);
    set({ user: null });
  },

  setUser: (user) => set({ user }),

  markHydrated: () => set({ hydrated: true }),

  hasPermission: (key: string) => {
    const u = get().user;
    if (!u || u.role !== 'admin') return false;
    const list = u.permissions ?? [];
    return list.includes(key);
  },
}));
