import { useState } from 'react';
import { Navigate } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import { Download, FileSpreadsheet, RefreshCw } from 'lucide-react';
import { fetchBookingsAdmin } from '@/api/bookings.api';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Label } from '@/components/ui/label';
import { PageHeader } from '@/components/data-table';
import { P } from '@/constants/permissions';
import { useAuthStore } from '@/state/authStore';

function downloadCsv(filename: string, rows: string[][]) {
  const esc = (c: string) => `"${c.replaceAll('"', '""')}"`;
  const csv = rows.map((r) => r.map(esc).join(',')).join('\n');
  const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = filename;
  a.click();
  URL.revokeObjectURL(url);
}

export default function ReportsPage() {
  const ok = useAuthStore((s) => s.hasPermission(P.REPORTS_READ));
  const [status, setStatus] = useState('');

  const q = useQuery({
    queryKey: ['report', 'bookings', status],
    queryFn: () => fetchBookingsAdmin({ page: '1', limit: '500', ...(status ? { status } : {}) }),
    enabled: ok,
  });

  if (!ok) return <Navigate to="/forbidden" replace />;

  const payload = q.data?.success && 'data' in q.data ? (q.data.data as { bookings: Record<string, unknown>[]; total?: number }) : null;
  const count = payload?.bookings?.length ?? 0;

  function exportBookingsCsv() {
    const bookings = payload?.bookings ?? [];
    const rows: string[][] = [['id', 'status', 'paymentStatus', 'price', 'address']];
    for (const b of bookings) {
      rows.push([String(b._id), String(b.status), String(b.paymentStatus), String(b.price), String(b.address ?? '')]);
    }
    downloadCsv(`bookings-${status || 'all'}.csv`, rows);
  }

  return (
    <div className="page-shell max-w-3xl">
      <PageHeader
        eyebrow="Insights"
        title="Reports"
        description="Export operational data for accounting, audits, and offline analysis."
      />

      <Card>
        <CardHeader>
          <div className="flex size-11 items-center justify-center rounded-xl bg-primary/10 text-primary">
            <FileSpreadsheet className="size-5" />
          </div>
          <CardTitle className="mt-3">Booking export</CardTitle>
          <CardDescription>
            Download up to 500 bookings as CSV. Filter by status before exporting.
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-5">
          <div className="grid gap-4 sm:grid-cols-[1fr_auto_auto] sm:items-end">
            <div>
              <Label htmlFor="report-status">Status filter</Label>
              <select
                id="report-status"
                className="select-field"
                value={status}
                onChange={(e) => setStatus(e.target.value)}
              >
                <option value="">All statuses</option>
                <option value="completed">Completed</option>
                <option value="cancelled">Cancelled</option>
                <option value="pending">Pending</option>
                <option value="accepted">Accepted</option>
                <option value="in_progress">In progress</option>
              </select>
            </div>
            <Button variant="outline" className="rounded-full" onClick={() => void q.refetch()} disabled={q.isFetching}>
              <RefreshCw className={`size-3.5 ${q.isFetching ? 'animate-spin' : ''}`} />
              Refresh
            </Button>
            <Button className="rounded-full" onClick={exportBookingsCsv} disabled={!q.data?.success || count === 0}>
              <Download className="size-3.5" />
              Download CSV
            </Button>
          </div>
          <p className="text-sm text-muted-foreground">
            {q.isLoading ? 'Loading…' : `${count.toLocaleString()} booking${count === 1 ? '' : 's'} ready to export.`}
          </p>
        </CardContent>
      </Card>
    </div>
  );
}
