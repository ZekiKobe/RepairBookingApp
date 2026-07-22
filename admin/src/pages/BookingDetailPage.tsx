import { useMemo, useState } from 'react';
import { Link, Navigate, useParams } from 'react-router-dom';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { toast } from 'sonner';
import {
  assignBookingTechnicianAdmin,
  cancelBooking,
  fetchBooking,
  fetchBookingInvoiceHtml,
  fetchBookingMessages,
  updateBookingNotesAdmin,
  updateBookingStatus,
} from '@/api/bookings.api';
import { fetchTechnicianSuggestions } from '@/api/admin.api';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Skeleton } from '@/components/ui/skeleton';
import { P } from '@/constants/permissions';
import { useAuthStore } from '@/state/authStore';

export default function BookingDetailPage() {
  const { id = '' } = useParams();
  const ok = useAuthStore((s) => s.hasPermission(P.BOOKINGS_READ));
  const canWrite = useAuthStore((s) => s.hasPermission(P.BOOKINGS_WRITE));
  const qc = useQueryClient();
  const [notes, setNotes] = useState('');
  const [techId, setTechId] = useState('');

  const qb = useQuery({ queryKey: ['booking', id], queryFn: () => fetchBooking(id), enabled: !!id && ok });
  const qm = useQuery({ queryKey: ['booking', id, 'messages'], queryFn: () => fetchBookingMessages(id), enabled: !!id && ok });

  const mStatus = useMutation({
    mutationFn: (status: string) => updateBookingStatus(id, status),
    onSuccess: () => {
      toast.success('Status updated');
      void qc.invalidateQueries({ queryKey: ['booking', id] });
    },
    onError: () => toast.error('Update failed'),
  });

  const mNotes = useMutation({
    mutationFn: () => updateBookingNotesAdmin(id, notes),
    onSuccess: () => {
      toast.success('Notes saved');
      void qc.invalidateQueries({ queryKey: ['booking', id] });
    },
    onError: () => toast.error('Save failed'),
  });

  const mAssign = useMutation({
    mutationFn: () => assignBookingTechnicianAdmin(id, techId),
    onSuccess: () => {
      toast.success('Technician updated');
      void qc.invalidateQueries({ queryKey: ['booking', id] });
    },
    onError: () => toast.error('Assign failed'),
  });

  const mCancel = useMutation({
    mutationFn: () => cancelBooking(id, 'Admin cancellation'),
    onSuccess: () => {
      toast.success('Booking cancelled');
      void qc.invalidateQueries({ queryKey: ['booking', id] });
    },
    onError: () => toast.error('Cancel failed'),
  });

  const booking = useMemo(() => {
    if (!qb.data?.success || !('data' in qb.data)) return null;
    return (qb.data.data as { booking: Record<string, unknown> }).booking ?? null;
  }, [qb.data]);

  const serviceId = useMemo(() => {
    if (!booking) return '';
    const svc = booking.service as { _id?: string } | undefined;
    return svc?._id ? String(svc._id) : '';
  }, [booking]);

  const qs = useQuery({
    queryKey: ['tech-suggestions', serviceId],
    queryFn: () => fetchTechnicianSuggestions(serviceId || undefined),
    enabled: !!serviceId && canWrite,
  });

  if (!ok) return <Navigate to="/forbidden" replace />;

  if (qb.isError) {
    return (
      <p className="text-destructive">
        Could not load booking. <Link to="/bookings" className="underline">Back</Link>
      </p>
    );
  }

  return (
    <div className="space-y-4">
      <div className="flex flex-wrap items-center gap-2">
        <Button variant="ghost" asChild>
          <Link to="/bookings">← Bookings</Link>
        </Button>
        <h1 className="text-2xl font-semibold">Booking {id}</h1>
      </div>

      {!booking ? (
        <Skeleton className="h-48 w-full" />
      ) : (
        <div className="grid gap-4 lg:grid-cols-2">
          <Card>
            <CardHeader>
              <CardTitle>Summary</CardTitle>
            </CardHeader>
            <CardContent className="space-y-2 text-sm">
              <div>
                <span className="text-muted-foreground">Status:</span> <span className="capitalize">{String(booking.status)}</span>
              </div>
              <div>
                <span className="text-muted-foreground">Payment:</span> {String(booking.paymentStatus)}
              </div>
              <div>
                <span className="text-muted-foreground">Price:</span> {String(booking.price)}
              </div>
              <div>
                <span className="text-muted-foreground">Address:</span> {String(booking.address ?? '')}
              </div>
              <div>
                <span className="text-muted-foreground">Description:</span> {String(booking.description ?? '')}
              </div>
              <div className="pt-2">
                <Button
                  type="button"
                  variant="link"
                  className="h-auto p-0"
                  onClick={async () => {
                    try {
                      const blob = await fetchBookingInvoiceHtml(id);
                      const url = URL.createObjectURL(blob);
                      window.open(url, '_blank', 'noopener,noreferrer');
                    } catch {
                      toast.error('Could not load invoice');
                    }
                  }}
                >
                  Open invoice (HTML)
                </Button>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Messages</CardTitle>
            </CardHeader>
            <CardContent className="max-h-64 space-y-2 overflow-y-auto text-sm">
              {(qm.data?.success && 'data' in qm.data
                ? ((qm.data.data as { messages?: unknown[] }).messages ?? [])
                : []
              ).map((m: unknown) => {
                const msg = m as Record<string, unknown>;
                const sender = msg.sender as Record<string, string> | undefined;
                return (
                  <div key={String(msg._id)} className="rounded border p-2">
                    <div className="text-xs text-muted-foreground">
                      {sender?.firstName} {sender?.lastName}
                    </div>
                    <div>{String(msg.content)}</div>
                  </div>
                );
              })}
              {qm.isLoading && <Skeleton className="h-16 w-full" />}
            </CardContent>
          </Card>

          {canWrite && (
            <Card className="lg:col-span-2">
              <CardHeader>
                <CardTitle>Admin actions</CardTitle>
              </CardHeader>
              <CardContent className="grid gap-4 md:grid-cols-2">
                <div className="space-y-2">
                  <Label>Workflow status</Label>
                  <div className="flex flex-wrap gap-2">
                    {['pending', 'accepted', 'on_the_way', 'in_progress', 'completed', 'cancelled'].map((s) => (
                      <Button key={s} size="sm" variant="outline" disabled={mStatus.isPending} onClick={() => mStatus.mutate(s)}>
                        {s.replaceAll('_', ' ')}
                      </Button>
                    ))}
                  </div>
                </div>
                <div className="space-y-2">
                  <Label htmlFor="notes">Internal notes</Label>
                  <Input id="notes" value={notes} onChange={(e) => setNotes(e.target.value)} placeholder={String(booking.notes ?? '')} />
                  <Button size="sm" disabled={mNotes.isPending} onClick={() => mNotes.mutate()}>
                    Save notes
                  </Button>
                </div>
                <div className="space-y-2 md:col-span-2">
                  <Label>Reassign technician (profile ID)</Label>
                  <div className="flex flex-wrap gap-2">
                    <Input className="max-w-md" value={techId} onChange={(e) => setTechId(e.target.value)} placeholder="Technician Mongo id" />
                    <Button size="sm" disabled={mAssign.isPending} onClick={() => mAssign.mutate()}>
                      Assign
                    </Button>
                  </div>
                  <div className="text-xs text-muted-foreground">Suggestions (by service)</div>
                  <div className="flex flex-wrap gap-2">
                    {qs.data?.success &&
                      'data' in qs.data &&
                      ((qs.data.data as { technicians?: { _id: string }[] }).technicians ?? []).map((t) => (
                        <Button key={t._id} type="button" size="sm" variant="secondary" onClick={() => setTechId(t._id)}>
                          {t._id.slice(-6)}
                        </Button>
                      ))}
                  </div>
                </div>
                <div>
                  <Button variant="destructive" disabled={mCancel.isPending} onClick={() => mCancel.mutate()}>
                    Cancel booking
                  </Button>
                </div>
              </CardContent>
            </Card>
          )}
        </div>
      )}
    </div>
  );
}
