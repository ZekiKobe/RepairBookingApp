import { useEffect, useMemo, useState } from 'react';
import { Navigate } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import { ScrollText } from 'lucide-react';
import { fetchAuditLogs } from '@/api/admin.api';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { DataTable, PageHeader, type ColumnDef } from '@/components/data-table';
import { P } from '@/constants/permissions';
import { useAuthStore } from '@/state/authStore';
import { displayName } from '@/lib/format';

type AuditRow = Record<string, unknown> & { _id: string };

export default function AuditPage() {
  const ok = useAuthStore((s) => s.hasPermission(P.AUDIT_READ));
  const [page, setPage] = useState(1);
  const [pageSize, setPageSize] = useState(20);
  const [action, setAction] = useState('');
  const [actionFilter, setActionFilter] = useState('');

  useEffect(() => {
    setPage(1);
  }, [actionFilter, pageSize]);

  const q = useQuery({
    queryKey: ['audit', page, pageSize, actionFilter],
    queryFn: () =>
      fetchAuditLogs({
        page: String(page),
        limit: String(pageSize),
        ...(actionFilter.trim() ? { action: actionFilter.trim() } : {}),
      }),
    enabled: ok,
  });

  const payload =
    q.data?.success && 'data' in q.data
      ? (q.data.data as { logs: AuditRow[]; pages: number; total: number })
      : null;

  const rows = payload?.logs ?? [];

  const columns = useMemo(
    (): ColumnDef<AuditRow>[] => [
      {
        id: 'when',
        header: 'When',
        cell: (log) => (
          <span className="whitespace-nowrap text-muted-foreground">
            {log.createdAt ? new Date(String(log.createdAt)).toLocaleString() : '—'}
          </span>
        ),
      },
      {
        id: 'action',
        header: 'Action',
        cell: (log) => <code className="rounded-md bg-muted px-2 py-0.5 text-xs font-medium">{String(log.action)}</code>,
      },
      {
        id: 'actor',
        header: 'Actor',
        cell: (log) => {
          const actor = log.actorUser as Record<string, string> | undefined;
          if (!actor) return <span className="text-muted-foreground">—</span>;
          return (
            <div>
              <p className="font-medium">{displayName(actor.firstName, actor.lastName)}</p>
              <p className="text-xs text-muted-foreground">{actor.phone}</p>
            </div>
          );
        },
      },
      {
        id: 'target',
        header: 'Target',
        cell: (log) => (
          <span className="text-muted-foreground">
            {String(log.targetType ?? '')}{' '}
            <span className="font-mono text-xs text-foreground/80">{String(log.targetId ?? '').slice(-8)}</span>
          </span>
        ),
      },
      {
        id: 'ip',
        header: 'IP',
        cell: (log) => <span className="font-mono text-xs text-muted-foreground">{String(log.ip ?? '—')}</span>,
      },
    ],
    []
  );

  if (!ok) return <Navigate to="/forbidden" replace />;

  return (
    <div className="page-shell">
      <PageHeader eyebrow="Compliance" title="Audit log" description="Immutable record of administrative actions on the platform." />

      <div className="filter-bar">
        <div className="min-w-[14rem] flex-1">
          <Label htmlFor="action">Action (exact match)</Label>
          <Input
            id="action"
            className="mt-1.5"
            value={action}
            onChange={(e) => setAction(e.target.value)}
            placeholder="e.g. user.suspend"
            onKeyDown={(e) => e.key === 'Enter' && setActionFilter(action)}
          />
        </div>
        <Button className="rounded-full" onClick={() => setActionFilter(action)}>
          Apply filter
        </Button>
        {actionFilter && (
          <Button variant="ghost" className="rounded-full" onClick={() => { setAction(''); setActionFilter(''); }}>
            Clear
          </Button>
        )}
      </div>

      <DataTable
        columns={columns}
        data={rows}
        rowKey={(r) => String(r._id)}
        isLoading={q.isLoading}
        minWidth="800px"
        emptyIcon={<ScrollText className="size-6" />}
        emptyTitle="No audit events"
        emptyDescription={actionFilter ? 'No events match this action. Try another filter.' : 'Administrative actions will be logged here.'}
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
