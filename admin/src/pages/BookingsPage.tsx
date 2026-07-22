import { useEffect, useMemo, useState } from 'react';
import { Link, Navigate } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import { CalendarDays } from 'lucide-react';
import { fetchBookingsAdmin } from '@/api/bookings.api';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { DataTable, PageHeader, type ColumnDef } from '@/components/data-table';
import { P } from '@/constants/permissions';
import { useAuthStore } from '@/state/authStore';
import { cn } from '@/lib/utils';

type BookingRow = Record<string, unknown> & { _id: string };

const statusStyles: Record<string, string> = {
  pending: 'bg-amber-500/10 text-amber-900 dark:text-amber-200 border-amber-500/25',
  accepted: 'bg-sky-500/10 text-sky-900 dark:text-sky-200 border-sky-500/25',
  on_the_way: 'bg-violet-500/10 text-violet-900 dark:text-violet-200 border-violet-500/25',
  in_progress: 'bg-primary/10 text-primary border-primary/25',
  completed: 'bg-emerald-500/10 text-emerald-900 dark:text-emerald-200 border-emerald-500/25',
  cancelled: 'bg-muted text-muted-foreground border-border',
};

export default function BookingsPage() {
  const ok = useAuthStore((s) => s.hasPermission(P.BOOKINGS_READ));
  const [page, setPage] = useState(1);
  const [pageSize, setPageSize] = useState(10);
  const [status, setStatus] = useState('');
  const [search, setSearch] = useState('');
  const [appliedStatus, setAppliedStatus] = useState('');
  const [appliedSearch, setAppliedSearch] = useState('');

  useEffect(() => {
    setPage(1);
  }, [appliedStatus, appliedSearch, pageSize]);

  const q = useQuery({
    queryKey: ['bookings', 'admin', page, pageSize, appliedStatus, appliedSearch],
    queryFn: () =>
      fetchBookingsAdmin({
        page: String(page),
        limit: String(pageSize),
        ...(appliedStatus ? { status: appliedStatus } : {}),
        ...(appliedSearch.trim() ? { search: appliedSearch.trim() } : {}),
      }),
    enabled: ok,
  });

  const payload =
    q.data?.success && 'data' in q.data
      ? (q.data.data as { bookings: BookingRow[]; total: number; pages: number })
      : null;

  const rows = (payload?.bookings ?? []) as BookingRow[];

  const columns = useMemo(
    (): ColumnDef<BookingRow>[] => [
      {
        id: 'customer',
        header: 'Customer',
        cell: (b) => {
          const u = b.user as Record<string, string> | undefined;
          return (
            <span className="font-medium">
              {u?.firstName} {u?.lastName}
            </span>
          );
        },
      },
      {
        id: 'technician',
        header: 'Technician',
        cell: (b) => {
          const tech = b.technician as { user?: Record<string, string> } | undefined;
          const name = tech?.user ? `${tech.user.firstName ?? ''} ${tech.user.lastName ?? ''}`.trim() : '—';
          return <span className="text-muted-foreground">{name || '—'}</span>;
        },
      },
      {
        id: 'service',
        header: 'Service',
        cell: (b) => {
          const svc = b.service as { name?: string } | undefined;
          return svc?.name ?? '—';
        },
      },
      {
        id: 'status',
        header: 'Status',
        cell: (b) => {
          const s = String(b.status);
          return (
            <Badge className={cn('border font-medium capitalize', statusStyles[s] ?? statusStyles.pending)}>
              {s.replaceAll('_', ' ')}
            </Badge>
          );
        },
      },
      {
        id: 'payment',
        header: 'Payment',
        cell: (b) => <span className="capitalize text-muted-foreground">{String(b.paymentStatus)}</span>,
      },
      {
        id: 'price',
        header: 'Price',
        cell: (b) => <span className="font-medium tabular-nums">{String(b.price ?? '—')}</span>,
      },
      {
        id: 'actions',
        header: '',
        align: 'right',
        cell: (b) => (
          <Button asChild variant="outline" size="sm" className="rounded-full">
            <Link to={`/bookings/${String(b._id)}`}>Open</Link>
          </Button>
        ),
      },
    ],
    []
  );

  if (!ok) return <Navigate to="/forbidden" replace />;

  function applyFilters() {
    setAppliedStatus(status);
    setAppliedSearch(search);
    setPage(1);
  }

  return (
    <div className="page-shell">
      <PageHeader eyebrow="Operations" title="Bookings" description="Monitor and manage repair bookings across the platform." />

      <div className="filter-bar">
        <div>
          <Label htmlFor="status">Status</Label>
          <select
            id="status"
            className="select-field"
            value={status}
            onChange={(e) => setStatus(e.target.value)}
          >
            <option value="">Any status</option>
            <option value="pending">Pending</option>
            <option value="accepted">Accepted</option>
            <option value="on_the_way">On the way</option>
            <option value="in_progress">In progress</option>
            <option value="completed">Completed</option>
            <option value="cancelled">Cancelled</option>
          </select>
        </div>
        <div className="min-w-[12rem] flex-1">
          <Label htmlFor="search">Search</Label>
          <Input id="search" className="mt-1.5" placeholder="Address or description…" value={search} onChange={(e) => setSearch(e.target.value)} onKeyDown={(e) => e.key === 'Enter' && applyFilters()} />
        </div>
        <Button className="rounded-full" onClick={applyFilters}>
          Apply filters
        </Button>
      </div>

      <DataTable
        columns={columns}
        data={rows}
        rowKey={(r) => String(r._id)}
        isLoading={q.isLoading}
        minWidth="900px"
        emptyIcon={<CalendarDays className="size-6" />}
        emptyTitle="No bookings found"
        emptyDescription="Adjust filters or wait for new bookings to come in."
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
