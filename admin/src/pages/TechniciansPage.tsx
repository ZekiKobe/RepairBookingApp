import { useEffect, useMemo, useState } from 'react';
import { Navigate } from 'react-router-dom';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { toast } from 'sonner';
import { Star, UserRound } from 'lucide-react';
import { approveTechnician, fetchPendingTechnicians, fetchTechnicians, setTechnicianSuspended } from '@/api/technicians.api';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { DataTable, PageHeader, PersonCell, SegmentedTabs, type ColumnDef } from '@/components/data-table';
import { P } from '@/constants/permissions';
import { useAuthStore } from '@/state/authStore';
import { cn } from '@/lib/utils';

type TechnicianRow = Record<string, unknown> & {
  _id: string;
  user?: Record<string, string>;
  isApproved?: boolean;
  isSuspended?: boolean;
  rating?: number;
  totalJobs?: number;
};

function RatingCell({ value }: { value: number }) {
  const v = Number.isFinite(value) ? Math.min(5, Math.max(0, value)) : 0;
  const filled = Math.round(v);
  return (
    <div className="flex items-center gap-2">
      <div className="flex gap-0.5" aria-hidden>
        {Array.from({ length: 5 }, (_, i) => (
          <Star
            key={i}
            className={cn(
              'size-3.5 shrink-0',
              i < filled ? 'fill-amber-400 text-amber-500' : 'fill-transparent text-muted-foreground/35'
            )}
          />
        ))}
      </div>
      <span className="text-xs tabular-nums text-muted-foreground">{v.toFixed(1)}</span>
    </div>
  );
}

export default function TechniciansPage() {
  const ok = useAuthStore((s) => s.hasPermission(P.TECHNICIANS_READ));
  const canWrite = useAuthStore((s) => s.hasPermission(P.TECHNICIANS_WRITE));
  const [tab, setTab] = useState<'active' | 'pending'>('active');
  const [page, setPage] = useState(1);
  const [pageSize, setPageSize] = useState(10);
  const qc = useQueryClient();

  useEffect(() => {
    setPage(1);
  }, [tab, pageSize]);

  const qList = useQuery({
    queryKey: ['technicians', tab, page, pageSize],
    queryFn: () =>
      tab === 'pending'
        ? fetchPendingTechnicians({ page: String(page), limit: String(pageSize) })
        : fetchTechnicians({ page: String(page), limit: String(pageSize) }),
    enabled: ok,
  });

  const mApprove = useMutation({
    mutationFn: (id: string) => approveTechnician(id),
    onSuccess: () => {
      toast.success('Approved');
      void qc.invalidateQueries({ queryKey: ['technicians'] });
    },
    onError: () => toast.error('Approve failed'),
  });

  const mSuspend = useMutation({
    mutationFn: ({ id, suspended }: { id: string; suspended: boolean }) => setTechnicianSuspended(id, suspended),
    onSuccess: () => {
      toast.success('Updated');
      void qc.invalidateQueries({ queryKey: ['technicians'] });
    },
    onError: () => toast.error('Update failed'),
  });

  const payload =
    qList.data?.success && 'data' in qList.data
      ? (qList.data.data as { technicians: TechnicianRow[]; total: number; pages: number })
      : null;

  const rows = payload?.technicians ?? [];
  const total = payload?.total ?? 0;
  const pages = payload?.pages ?? 0;

  const columns = useMemo((): ColumnDef<TechnicianRow>[] => {
    const base: ColumnDef<TechnicianRow>[] = [
      {
        id: 'name',
        header: 'Technician',
        cell: (t) => {
          const u = t.user;
          const suspended = Boolean(t.isSuspended);
          return (
            <div>
              <PersonCell firstName={u?.firstName} lastName={u?.lastName} />
              {suspended && tab === 'active' && (
                <Badge className="ml-[3.25rem] mt-1 border-amber-500/30 bg-amber-500/10 text-amber-800 dark:text-amber-200">Suspended</Badge>
              )}
            </div>
          );
        },
      },
      {
        id: 'rating',
        header: 'Rating',
        cell: (t) => <RatingCell value={Number(t.rating)} />,
      },
      {
        id: 'jobs',
        header: 'Jobs',
        cell: (t) => <span className="tabular-nums text-muted-foreground">{Number(t.totalJobs ?? 0)}</span>,
      },
      {
        id: 'status',
        header: 'Status',
        cell: (t) =>
          t.isApproved ? (
            <Badge className="border-emerald-500/25 bg-emerald-500/10 font-medium text-emerald-800 dark:text-emerald-200">Approved</Badge>
          ) : (
            <Badge className="border border-border/70 bg-muted/50 font-medium text-muted-foreground">Pending</Badge>
          ),
      },
      {
        id: 'actions',
        header: 'Actions',
        align: 'right',
        cell: (t) => {
          const id = String(t._id);
          const suspended = Boolean(t.isSuspended);
          return (
            <div className="flex flex-wrap items-center justify-end gap-2">
              {tab === 'pending' && canWrite && (
                <Button size="sm" className="rounded-full px-4" disabled={mApprove.isPending} onClick={() => mApprove.mutate(id)}>
                  Approve
                </Button>
              )}
              {tab === 'active' && canWrite && t.isApproved && (
                <Button
                  size="sm"
                  variant={suspended ? 'default' : 'outline'}
                  className="rounded-full px-4"
                  disabled={mSuspend.isPending}
                  onClick={() => mSuspend.mutate({ id, suspended: !suspended })}
                >
                  {suspended ? 'Unsuspend' : 'Suspend'}
                </Button>
              )}
            </div>
          );
        },
      },
    ];
    return base;
  }, [tab, canWrite, mApprove.isPending, mSuspend.isPending]);

  if (!ok) return <Navigate to="/forbidden" replace />;

  return (
    <div className="page-shell max-w-[1200px]">
      <PageHeader
        eyebrow="Workforce"
        title="Technicians"
        description="Review pending sign-ups and manage who can accept jobs on the platform."
      />

      <SegmentedTabs
        tabs={[
          { id: 'active', label: 'Active directory' },
          { id: 'pending', label: 'Pending approval' },
        ]}
        value={tab}
        onChange={(v) => setTab(v)}
      />

      <DataTable
        columns={columns}
        data={rows}
        rowKey={(r) => String(r._id)}
        isLoading={qList.isLoading}
        minWidth="720px"
        emptyIcon={<UserRound className="size-6" />}
        emptyTitle={tab === 'pending' ? 'No pending technicians' : 'No technicians yet'}
        emptyDescription={
          tab === 'pending'
            ? 'New technician applications will appear here for review.'
            : 'Approved technicians will be listed in this directory.'
        }
        pagination={{
          page,
          pageSize,
          total,
          pages,
          onPageChange: setPage,
          onPageSizeChange: setPageSize,
          isLoading: qList.isLoading,
        }}
      />
    </div>
  );
}
