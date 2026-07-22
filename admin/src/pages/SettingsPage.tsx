import { useState } from 'react';
import { Navigate } from 'react-router-dom';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { toast } from 'sonner';
import { fetchSettings, saveSettings } from '@/api/admin.api';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { PageHeader } from '@/components/data-table';
import { P } from '@/constants/permissions';
import { useAuthStore } from '@/state/authStore';

type SettingsPayload = {
  general: { companyName: string; supportEmail: string; timezone: string };
  security: { sessionTimeoutMinutes: number; minPasswordLength: number };
};

function SettingsForm({ payload, canWrite }: { payload: SettingsPayload; canWrite: boolean }) {
  const qc = useQueryClient();
  const [general, setGeneral] = useState(payload.general);
  const [security, setSecurity] = useState(payload.security);

  const m = useMutation({
    mutationFn: () => saveSettings({ general, security }),
    onSuccess: (d) => {
      if (d.success) {
        toast.success('Saved');
        void qc.invalidateQueries({ queryKey: ['platform-settings'] });
      } else toast.error('message' in d ? d.message : 'Save failed');
    },
  });

  const fieldClass = 'flex flex-col gap-2';

  return (
    <div className="flex flex-col gap-6">
      <Card>
        <CardHeader>
          <CardTitle>General</CardTitle>
          <CardDescription>Branding and defaults shown across the platform.</CardDescription>
        </CardHeader>
        <CardContent className="flex flex-col gap-6">
          <div className={fieldClass}>
            <Label htmlFor="company">Company name</Label>
            <Input
              id="company"
              value={general.companyName}
              onChange={(e) => setGeneral({ ...general, companyName: e.target.value })}
              autoComplete="organization"
            />
          </div>
          <div className={fieldClass}>
            <Label htmlFor="support-email">Support email</Label>
            <Input
              id="support-email"
              type="email"
              value={general.supportEmail}
              onChange={(e) => setGeneral({ ...general, supportEmail: e.target.value })}
              placeholder="support@yourcompany.com"
              autoComplete="email"
            />
          </div>
          <div className={fieldClass}>
            <Label htmlFor="tz">Timezone</Label>
            <Input
              id="tz"
              value={general.timezone}
              onChange={(e) => setGeneral({ ...general, timezone: e.target.value })}
              placeholder="Africa/Addis_Ababa"
            />
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Security</CardTitle>
          <CardDescription>Session and password rules for administrator accounts.</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="grid gap-6 sm:grid-cols-2">
            <div className={fieldClass}>
              <Label htmlFor="session">Session timeout (minutes)</Label>
              <Input
                id="session"
                type="number"
                min={5}
                max={1440}
                value={security.sessionTimeoutMinutes}
                onChange={(e) => setSecurity({ ...security, sessionTimeoutMinutes: Number(e.target.value) })}
              />
            </div>
            <div className={fieldClass}>
              <Label htmlFor="pwlen">Minimum password length</Label>
              <Input
                id="pwlen"
                type="number"
                min={6}
                max={128}
                value={security.minPasswordLength}
                onChange={(e) => setSecurity({ ...security, minPasswordLength: Number(e.target.value) })}
              />
            </div>
          </div>
        </CardContent>
        {canWrite && (
          <CardFooter className="justify-end rounded-b-xl">
            <Button type="button" size="lg" disabled={m.isPending} onClick={() => m.mutate()}>
              {m.isPending ? 'Saving…' : 'Save changes'}
            </Button>
          </CardFooter>
        )}
      </Card>
    </div>
  );
}

export default function SettingsPage() {
  const read = useAuthStore((s) => s.hasPermission(P.SETTINGS_READ));
  const write = useAuthStore((s) => s.hasPermission(P.SETTINGS_WRITE));
  const q = useQuery({ queryKey: ['platform-settings'], queryFn: fetchSettings, enabled: read });

  if (!read) return <Navigate to="/forbidden" replace />;

  if (!q.isSuccess || !q.data.success || !('data' in q.data)) {
    return <p className="text-muted-foreground">Loading settings…</p>;
  }

  const d = q.data.data as Record<string, Record<string, unknown>>;
  const payload: SettingsPayload = {
    general: {
      companyName: String(d.general?.companyName ?? ''),
      supportEmail: String(d.general?.supportEmail ?? ''),
      timezone: String(d.general?.timezone ?? ''),
    },
    security: {
      sessionTimeoutMinutes: Number(d.security?.sessionTimeoutMinutes ?? 60),
      minPasswordLength: Number(d.security?.minPasswordLength ?? 6),
    },
  };

  return (
    <div className="page-shell max-w-3xl">
      <PageHeader
        eyebrow="Platform"
        title="Settings"
        description="Company branding, support contact, and admin security defaults."
      />
      <SettingsForm key={q.dataUpdatedAt} payload={payload} canWrite={write} />
    </div>
  );
}
