import { Navigate, Outlet } from 'react-router-dom';
import { useAuthStore } from '@/state/authStore';

export function RequirePermission({ permission }: { permission: string }) {
  const hasPermission = useAuthStore((s) => s.hasPermission);
  if (!hasPermission(permission)) return <Navigate to="/forbidden" replace />;
  return <Outlet />;
}
