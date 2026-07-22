import { useEffect, useState } from 'react';
import { Navigate, Outlet } from 'react-router-dom';
import { fetchMe } from '@/api/auth.api';
import { getStoredTokens } from '@/lib/axios';
import { useAuthStore } from '@/state/authStore';

export function RequireAuth() {
  const user = useAuthStore((s) => s.user);
  const hydrated = useAuthStore((s) => s.hydrated);
  const setUser = useAuthStore((s) => s.setUser);
  const clearSession = useAuthStore((s) => s.clearSession);
  const markHydrated = useAuthStore((s) => s.markHydrated);
  const [ready, setReady] = useState(false);

  useEffect(() => {
    let cancelled = false;
    async function boot() {
      const tok = getStoredTokens();
      if (!tok) {
        markHydrated();
        setReady(true);
        return;
      }
      try {
        const d = await fetchMe();
        if (cancelled) return;
        if (d.success && 'data' in d) {
          if (d.data.user.role !== 'admin') {
            clearSession();
          } else {
            setUser(d.data.user);
          }
        } else {
          clearSession();
        }
      } catch {
        if (!cancelled) clearSession();
      } finally {
        if (!cancelled) {
          markHydrated();
          setReady(true);
        }
      }
    }
    void boot();
    return () => {
      cancelled = true;
    };
  }, [clearSession, markHydrated, setUser]);

  if (!ready || !hydrated) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-background text-muted-foreground">
        Loading session…
      </div>
    );
  }
  if (!user) return <Navigate to="/login" replace />;
  return <Outlet />;
}
