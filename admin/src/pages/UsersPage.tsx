import { useEffect, useMemo, useState } from 'react';
import { Link, Navigate } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import { Users } from 'lucide-react';
import { searchUsers } from '@/api/users.api';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { DataTable, PageHeader, PersonCell, type ColumnDef } from '@/components/data-table';
import { P } from '@/constants/permissions';
import { useAuthStore } from '@/state/authStore';

type UserRow = Record<string, unknown> & {
  _id: string;
  firstName?: string;
  lastName?: string;
  phone?: string;
  role?: string;
  isActive?: boolean;
};

export default function UsersPage() {
  const ok = useAuthStore((s) => s.hasPermission(P.USERS_READ));
  const [page, setPage] = useState(1);
  const [pageSize, setPageSize] = useState(10);
  const [phone, setPhone] = useState('');
  const [phoneFilter, setPhoneFilter] = useState('');

  useEffect(() => {
    setPage(1);
  }, [phoneFilter, pageSize]);

  const q = useQuery({
    queryKey: ['users', 'search', page, pageSize, phoneFilter],
    queryFn: () =>
      searchUsers({
        page: String(page),
        limit: String(pageSize),
        ...(phoneFilter.trim() ? { phone: phoneFilter.trim() } : {}),
      }),
    enabled: ok,
  });

  const payload =
    q.data?.success && 'data' in q.data
      ? (q.data.data as { users: UserRow[]; total: number; pages: number })
      : null;

  const rows = payload?.users ?? [];

  const columns = useMemo(
    (): ColumnDef<UserRow>[] => [
      {
        id: 'name',
        header: 'User',
        cell: (u) => <PersonCell firstName={String(u.firstName)} lastName={String(u.lastName)} subtitle={String(u.phone)} />,
      },
      {
        id: 'role',
        header: 'Role',
        cell: (u) => (
          <Badge className="border border-border/60 bg-muted/40 font-medium capitalize text-foreground">{String(u.role)}</Badge>
        ),
      },
      {
        id: 'active',
        header: 'Status',
        cell: (u) =>
          u.isActive ? (
            <Badge className="border-emerald-500/25 bg-emerald-500/10 font-medium text-emerald-800 dark:text-emerald-200">Active</Badge>
          ) : (
            <Badge className="border border-border/70 bg-muted/50 font-medium text-muted-foreground">Inactive</Badge>
          ),
      },
      {
        id: 'actions',
        header: '',
        align: 'right',
        cell: (u) => (
          <Button asChild variant="outline" size="sm" className="rounded-full">
            <Link to={`/users/${String(u._id)}`}>View profile</Link>
          </Button>
        ),
      },
    ],
    []
  );

  if (!ok) return <Navigate to="/forbidden" replace />;

  return (
    <div className="page-shell max-w-[1200px]">
      <PageHeader eyebrow="Directory" title="Users" description="Search and manage customer, technician, and admin accounts." />

      <div className="filter-bar">
        <div className="flex flex-1 flex-wrap items-end gap-3">
          <div className="min-w-[200px] flex-1">
            <Label htmlFor="phone-filter">Phone number</Label>
            <Input
              id="phone-filter"
              className="mt-1.5"
              value={phone}
              onChange={(e) => setPhone(e.target.value)}
              placeholder="Filter by phone…"
              onKeyDown={(e) => e.key === 'Enter' && setPhoneFilter(phone)}
            />
          </div>
          <Button className="rounded-full" onClick={() => setPhoneFilter(phone)}>
            Apply filter
          </Button>
          {phoneFilter && (
            <Button variant="ghost" className="rounded-full" onClick={() => { setPhone(''); setPhoneFilter(''); }}>
              Clear
            </Button>
          )}
        </div>
      </div>

      <DataTable
        columns={columns}
        data={rows}
        rowKey={(r) => String(r._id)}
        isLoading={q.isLoading}
        minWidth="560px"
        emptyIcon={<Users className="size-6" />}
        emptyTitle="No users found"
        emptyDescription={phoneFilter ? 'Try a different phone number or clear the filter.' : 'Users will appear here once they register.'}
        pagination={{
          page,
          pageSize,
          total: payload?.total ?? 0,
          pages: payload?.pages ?? 0,
          onPageChange: setPage,
          onPageSizeChange: setPageSize,
          isLoading: q.isLoading,
        }}
      />
    </div>
  );
}
