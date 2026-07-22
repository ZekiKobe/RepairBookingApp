import { useState } from 'react';
import { Navigate } from 'react-router-dom';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { toast } from 'sonner';
import { Bell, Megaphone, Trash2 } from 'lucide-react';
import {
  broadcastNotification,
  createNotificationTemplate,
  deleteNotificationTemplate,
  fetchNotificationTemplates,
} from '@/api/admin.api';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { PageHeader } from '@/components/data-table';
import { P } from '@/constants/permissions';
import { useAuthStore } from '@/state/authStore';

export default function NotificationsPage() {
  const read = useAuthStore((s) => s.hasPermission(P.NOTIFICATIONS_READ));
  const write = useAuthStore((s) => s.hasPermission(P.NOTIFICATIONS_WRITE));
  const qc = useQueryClient();
  const [name, setName] = useState('');
  const [title, setTitle] = useState('');
  const [body, setBody] = useState('');
  const [bTitle, setBTitle] = useState('');
  const [bBody, setBBody] = useState('');
  const [audience, setAudience] = useState<'all' | 'users' | 'technicians'>('all');

  const q = useQuery({
    queryKey: ['notification-templates'],
    queryFn: fetchNotificationTemplates,
    enabled: read,
  });

  const mCreate = useMutation({
    mutationFn: () => createNotificationTemplate({ name, title, body, channel: 'in_app' }),
    onSuccess: (d) => {
      if (d.success) {
        toast.success('Template saved');
        setName('');
        setTitle('');
        setBody('');
        void qc.invalidateQueries({ queryKey: ['notification-templates'] });
      } else toast.error('message' in d ? d.message : 'Failed');
    },
  });

  const mDel = useMutation({
    mutationFn: (id: string) => deleteNotificationTemplate(id),
    onSuccess: () => {
      toast.success('Deleted');
      void qc.invalidateQueries({ queryKey: ['notification-templates'] });
    },
  });

  const mBroadcast = useMutation({
    mutationFn: () => broadcastNotification({ title: bTitle, body: bBody, audience }),
    onSuccess: (d) => {
      if (d.success && 'data' in d) toast.success(`Queued ${(d.data as { sent?: number }).sent ?? 0} notifications`);
      else toast.error('message' in d ? d.message : 'Broadcast failed');
    },
  });

  if (!read) return <Navigate to="/forbidden" replace />;

  const templates =
    q.data?.success && 'data' in q.data
      ? ((q.data.data as { templates: { _id: string; name: string; title: string }[] }).templates ?? [])
      : [];

  return (
    <div className="page-shell max-w-4xl">
      <PageHeader
        eyebrow="Engagement"
        title="Notifications"
        description="Manage reusable templates and send in-app broadcasts to customers or technicians."
      />

      <div className="grid gap-5 lg:grid-cols-2">
        <Card className="lg:col-span-2">
          <CardHeader>
            <div className="flex items-center gap-3">
              <span className="flex size-10 items-center justify-center rounded-xl bg-primary/10 text-primary">
                <Bell className="size-4" />
              </span>
              <div>
                <CardTitle>Templates</CardTitle>
                <CardDescription>Saved message templates for consistent communication.</CardDescription>
              </div>
            </div>
          </CardHeader>
          <CardContent>
            {templates.length === 0 && !q.isLoading ? (
              <p className="rounded-xl bg-muted/25 px-4 py-10 text-center text-sm text-muted-foreground">
                No templates yet. Create one below.
              </p>
            ) : (
              <ul className="overflow-hidden rounded-lg bg-muted/30">
                {templates.map((t) => (
                  <li
                    key={t._id}
                    className="flex items-center justify-between gap-3 border-b border-black/[0.04] px-4 py-3 text-sm last:border-0 dark:border-white/[0.05]"
                  >
                    <div className="min-w-0">
                      <p className="truncate font-semibold">{t.name}</p>
                      <p className="truncate text-muted-foreground">{t.title}</p>
                    </div>
                    {write && (
                      <Button
                        size="sm"
                        variant="ghost"
                        className="shrink-0 text-destructive hover:bg-destructive/10 hover:text-destructive"
                        onClick={() => mDel.mutate(t._id)}
                      >
                        <Trash2 className="size-3.5" />
                        Delete
                      </Button>
                    )}
                  </li>
                ))}
              </ul>
            )}
          </CardContent>
        </Card>

        {write && (
          <>
            <Card>
              <CardHeader>
                <CardTitle>New template</CardTitle>
                <CardDescription>Create a reusable in-app notification template.</CardDescription>
              </CardHeader>
              <CardContent className="grid gap-3">
                <div>
                  <Label htmlFor="tpl-name">Name (unique)</Label>
                  <Input id="tpl-name" className="mt-1.5" value={name} onChange={(e) => setName(e.target.value)} />
                </div>
                <div>
                  <Label htmlFor="tpl-title">Title</Label>
                  <Input id="tpl-title" className="mt-1.5" value={title} onChange={(e) => setTitle(e.target.value)} />
                </div>
                <div>
                  <Label htmlFor="tpl-body">Body</Label>
                  <Input id="tpl-body" className="mt-1.5" value={body} onChange={(e) => setBody(e.target.value)} />
                </div>
                <Button className="mt-1 rounded-full" disabled={mCreate.isPending || !name.trim()} onClick={() => mCreate.mutate()}>
                  Save template
                </Button>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <div className="flex items-center gap-3">
                  <span className="flex size-10 items-center justify-center rounded-xl bg-amber-500/10 text-amber-700 dark:text-amber-300">
                    <Megaphone className="size-4" />
                  </span>
                  <div>
                    <CardTitle>Broadcast</CardTitle>
                    <CardDescription>Push an in-app message to a selected audience.</CardDescription>
                  </div>
                </div>
              </CardHeader>
              <CardContent className="grid gap-3">
                <div>
                  <Label htmlFor="audience">Audience</Label>
                  <select
                    id="audience"
                    className="select-field"
                    value={audience}
                    onChange={(e) => setAudience(e.target.value as typeof audience)}
                  >
                    <option value="all">All customers & technicians</option>
                    <option value="users">Customers only</option>
                    <option value="technicians">Technicians only</option>
                  </select>
                </div>
                <div>
                  <Label htmlFor="b-title">Title</Label>
                  <Input id="b-title" className="mt-1.5" value={bTitle} onChange={(e) => setBTitle(e.target.value)} />
                </div>
                <div>
                  <Label htmlFor="b-body">Body</Label>
                  <Input id="b-body" className="mt-1.5" value={bBody} onChange={(e) => setBBody(e.target.value)} />
                </div>
                <Button
                  className="mt-1 rounded-full"
                  disabled={mBroadcast.isPending || !bTitle.trim() || !bBody.trim()}
                  onClick={() => mBroadcast.mutate()}
                >
                  Send broadcast
                </Button>
              </CardContent>
            </Card>
          </>
        )}
      </div>
    </div>
  );
}
