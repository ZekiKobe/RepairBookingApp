import { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuthStore } from '@/state/authStore';

export function AuthEvents() {
  const navigate = useNavigate();
  const clearSession = useAuthStore((s) => s.clearSession);

  useEffect(() => {
    const fn = () => {
      clearSession();
      navigate('/login', { replace: true });
    };
    window.addEventListener('admin:auth-expired', fn);
    return () => window.removeEventListener('admin:auth-expired', fn);
  }, [clearSession, navigate]);

  return null;
}
