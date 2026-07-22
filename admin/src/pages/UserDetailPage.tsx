import { Link, Navigate, useParams } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import { fetchBookingsAdmin } from '@/api/bookings.api';
import { fetchUser } from '@/api/users.api';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Skeleton } from '@/components/ui/skeleton';
import { P } from '@/constants/permissions';
import { useAuthStore } from '@/state/authStore';

export default function UserDetailPage() {
  const { id = '' } = useParams();
  const ok = useAuthStore((s) => s.hasPermission(P.USERS_READ));
  const qu = useQuery({ queryKey: ['user', id], queryFn: () => fetchUser(id), enabled: !!id && ok });
  const qb = useQuery({
    queryKey: ['bookings', 'by-user', id],
    queryFn: () => fetchBookingsAdmin({ userId: id, page: '1', limit: '10' }),
    enabled: !!id && ok,
  });

  if (!ok) return <Navigate to="/forbidden" replace />;

  const user = qu.data?.success && 'data' in qu.data ? ((qu.data.data as { user: Record<string, unknown> }).user ?? null) : null;

  return (
    <div className="space-y-4">
      <Button variant="ghost" asChild>
        <Link to="/users">← Users</Link>
      </Button>
      <h1 className="text-2xl font-semibold">User profile</h1>
      {!user ? (
        <Skeleton className="h-32 w-full" />
      ) : (
        <Card>
          <CardHeader>
            <CardTitle>
              {String(user.firstName)} {String(user.lastName)}
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-1 text-sm">
            <div>Phone: {String(user.phone)}</div>
            <div>Email: {String(user.email ?? '')}</div>
            <div>Role: {String(user.role)}</div>
            <div>Verified: {user.isVerified ? 'Yes' : 'No'}</div>
            <div>Active: {user.isActive ? 'Yes' : 'No'}</div>
          </CardContent>
        </Card>
      )}

      <Card>
        <CardHeader>
          <CardTitle>Recent bookings</CardTitle>
        </CardHeader>
        <CardContent className="text-sm">
          {(qb.data?.success && 'data' in qb.data
            ? ((qb.data.data as { bookings: Record<string, unknown>[] }).bookings ?? [])
            : []
          ).map((b) => (
            <div key={String(b._id)} className="flex justify-between border-b py-2">
              <span className="capitalize">{String(b.status)}</span>
              <Button asChild variant="link" size="sm">
                <Link to={`/bookings/${String(b._id)}`}>Open</Link>
              </Button>
            </div>
          ))}
          {qb.isLoading && <Skeleton className="h-20 w-full" />}
        </CardContent>
      </Card>
    </div>
  );
}
