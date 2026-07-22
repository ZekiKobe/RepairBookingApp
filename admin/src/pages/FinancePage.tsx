import { useEffect, useMemo, useState } from 'react';
import { Navigate } from 'react-router-dom';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { toast } from 'sonner';
import { Wallet } from 'lucide-react';
import { fetchLedger } from '@/api/admin.api';
import { refundPayment } from '@/api/payments.api';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { DataTable, PageHeader, type ColumnDef } from '@/components/data-table';
import { P } from '@/constants/permissions';
import { useAuthStore } from '@/state/authStore';

type LedgerRow = Record<string, unknown> & { _id: string };

export default function FinancePage() {
  const ok = useAuthStore((s) => s.hasPermission(P.FINANCE_READ));
  const canRefund = useAuthStore((s) => s.hasPermission(P.FINANCE_WRITE));
  const [page, setPage] = useState(1);
  const [pageSize, setPageSize] = useState(10);
  const [bookingId, setBookingId] = useState('');
  const qc = useQueryClient();

  useEffect(() => {
    setPage(1);
  }, [pageSize]);

  const q = useQuery({
    queryKey: ['ledger', page, pageSize],
    queryFn: () => fetchLedger({ page: String(page), limit: String(pageSize) }),
    enabled: ok,
  });

  const mRefund = useMutation({
    mutationFn: () => refundPayment({ bookingId: bookingId.trim() }),
    onSuccess: (d) => {
      if (d.success) {
        toast.success('Refund processed');
        void qc.invalidateQueries({ queryKey: ['ledger'] });
      } else toast.error('message' in d ? d.message : 'Refund failed');
    },
    onError: () => toast.error('Refund failed'),
  });

  const payload =
    q.data?.success && 'data' in q.data
      ? (q.data.data as { entries: LedgerRow[]; pages: number; total: number })
      : null;

  const rows = payload?.entries ?? [];

  const columns = useMemo(
    (): ColumnDef<LedgerRow>[] => [
      {
        id: 'type',
        header: 'Type',
        cell: (e) => (
          <Badge className="border border-border/60 bg-muted/40 font-medium capitalize">{String(e.type)}</Badge>
        ),
      },
      {
        id: 'amount',
        header: 'Amount',
        cell: (e) => <span className="font-semibold tabular-nums">{String(e.amount)}</span>,
      },
      {
        id: 'currency',
        header: 'Currency',
        cell: (e) => <span className="text-muted-foreground">{String(e.currency ?? 'ETB')}</span>,
      },
      {
        id: 'when',
        header: 'Date',
        cell: (e) => (
          <span className="whitespace-nowrap text-muted-foreground">
            {e.createdAt ? new Date(String(e.createdAt)).toLocaleString() : '—'}
          </span>
        ),
      },
    ],
    []
  );

  if (!ok) return <Navigate to="/forbidden" replace />;

  return (
    <div className="page-shell max-w-[1200px]">
      <PageHeader eyebrow="Revenue" title="Finance" description="Ledger entries and refund tools for paid bookings." />

      {canRefund && (
        <Card>
          <CardHeader>
            <CardTitle className="text-base">Process refund</CardTitle>
            <p className="text-sm text-muted-foreground">Refund a paid booking by ID. This action is recorded in the ledger.</p>
          </CardHeader>
          <CardContent className="flex flex-wrap items-end gap-3">
            <div className="min-w-[16rem] flex-1">
              <Label htmlFor="booking-id">Booking ID</Label>
              <Input id="booking-id" className="mt-1.5" value={bookingId} onChange={(e) => setBookingId(e.target.value)} placeholder="Paste booking ID…" />
            </div>
            <Button className="rounded-full" disabled={mRefund.isPending || !bookingId.trim()} onClick={() => mRefund.mutate()}>
              Refund payment
            </Button>
          </CardContent>
        </Card>
      )}

      <DataTable
        columns={columns}
        data={rows}
        rowKey={(r) => String(r._id)}
        isLoading={q.isLoading}
        minWidth="520px"
        emptyIcon={<Wallet className="size-6" />}
        emptyTitle="No ledger entries"
        emptyDescription="Financial activity will appear here as payments are processed."
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
