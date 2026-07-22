import { useMemo, useState, type ReactNode } from 'react';
import { Navigate } from 'react-router-dom';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { toast } from 'sonner';
import {
  Bell,
  Building2,
  CreditCard,
  KeyRound,
  Palette,
  Receipt,
  Shield,
  Wrench,
} from 'lucide-react';
import { fetchSettings, saveSettings } from '@/api/admin.api';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { PageHeader } from '@/components/data-table';
import { P } from '@/constants/permissions';
import { useAuthStore } from '@/state/authStore';
import { cn } from '@/lib/utils';
import type { LucideIcon } from 'lucide-react';

type SectionKey =
  | 'general'
  | 'branding'
  | 'booking'
  | 'payments'
  | 'tax'
  | 'notifications'
  | 'security'
  | 'maintenance'
  | 'mfa';

type PlatformSettings = Record<SectionKey, Record<string, unknown>>;

const SECTIONS: { id: SectionKey; label: string; icon: LucideIcon; description: string }[] = [
  { id: 'general', label: 'Company', icon: Building2, description: 'Business identity and contact details' },
  { id: 'branding', label: 'Branding', icon: Palette, description: 'App name, colors, and logo URLs' },
  { id: 'booking', label: 'Bookings', icon: Wrench, description: 'Slots, cancellation, and assignment rules' },
  { id: 'payments', label: 'Payments', icon: CreditCard, description: 'Fees, currency, deposits, and refunds' },
  { id: 'tax', label: 'Tax', icon: Receipt, description: 'VAT / tax configuration' },
  { id: 'notifications', label: 'Notifications', icon: Bell, description: 'Push, email, SMS, and admin alerts' },
  { id: 'security', label: 'Security', icon: Shield, description: 'Sessions, passwords, and lockouts' },
  { id: 'maintenance', label: 'Maintenance', icon: Wrench, description: 'Platform maintenance mode' },
  { id: 'mfa', label: 'MFA', icon: KeyRound, description: 'Multi-factor authentication policy' },
];

function asString(v: unknown, fallback = '') {
  return v == null ? fallback : String(v);
}

function asNumber(v: unknown, fallback = 0) {
  const n = Number(v);
  return Number.isFinite(n) ? n : fallback;
}

function asBool(v: unknown, fallback = false) {
  if (typeof v === 'boolean') return v;
  if (v === 'true' || v === 1 || v === '1') return true;
  if (v === 'false' || v === 0 || v === '0') return false;
  return fallback;
}

function Field({
  label,
  hint,
  children,
}: {
  label: string;
  hint?: string;
  children: ReactNode;
}) {
  return (
    <div className="flex flex-col gap-1.5">
      <Label className="text-sm font-medium">{label}</Label>
      {children}
      {hint && <p className="text-xs text-muted-foreground">{hint}</p>}
    </div>
  );
}

function TextInput({
  label,
  hint,
  value,
  onChange,
  type = 'text',
  placeholder,
}: {
  label: string;
  hint?: string;
  value: string;
  onChange: (v: string) => void;
  type?: string;
  placeholder?: string;
}) {
  return (
    <Field label={label} hint={hint}>
      <Input type={type} value={value} placeholder={placeholder} onChange={(e) => onChange(e.target.value)} />
    </Field>
  );
}

function NumberInput({
  label,
  hint,
  value,
  onChange,
  min,
  max,
  step,
}: {
  label: string;
  hint?: string;
  value: number;
  onChange: (v: number) => void;
  min?: number;
  max?: number;
  step?: number;
}) {
  return (
    <Field label={label} hint={hint}>
      <Input
        type="number"
        value={Number.isFinite(value) ? value : 0}
        min={min}
        max={max}
        step={step}
        onChange={(e) => onChange(Number(e.target.value))}
      />
    </Field>
  );
}

function Toggle({
  label,
  hint,
  checked,
  onChange,
  disabled,
}: {
  label: string;
  hint?: string;
  checked: boolean;
  onChange: (v: boolean) => void;
  disabled?: boolean;
}) {
  return (
    <label className="flex cursor-pointer items-start gap-3 rounded-xl bg-muted/40 px-4 py-3">
      <input
        type="checkbox"
        className="mt-1 size-4 rounded border-input accent-[hsl(var(--primary))]"
        checked={checked}
        disabled={disabled}
        onChange={(e) => onChange(e.target.checked)}
      />
      <span>
        <span className="block text-sm font-medium">{label}</span>
        {hint && <span className="mt-0.5 block text-xs text-muted-foreground">{hint}</span>}
      </span>
    </label>
  );
}

function patchSection(
  settings: PlatformSettings,
  section: SectionKey,
  key: string,
  value: unknown
): PlatformSettings {
  return {
    ...settings,
    [section]: { ...settings[section], [key]: value },
  };
}

function SettingsForm({ payload, canWrite }: { payload: PlatformSettings; canWrite: boolean }) {
  const qc = useQueryClient();
  const [tab, setTab] = useState<SectionKey>('general');
  const [settings, setSettings] = useState<PlatformSettings>(payload);

  const m = useMutation({
    mutationFn: () => saveSettings(settings),
    onSuccess: (d) => {
      if (d.success) {
        toast.success('Settings saved');
        void qc.invalidateQueries({ queryKey: ['platform-settings'] });
      } else toast.error('message' in d ? d.message : 'Save failed');
    },
    onError: () => toast.error('Save failed'),
  });

  const set = (section: SectionKey, key: string, value: unknown) =>
    setSettings((s) => patchSection(s, section, key, value));

  const active = SECTIONS.find((s) => s.id === tab)!;
  const g = settings.general;
  const b = settings.branding;
  const bk = settings.booking;
  const p = settings.payments;
  const t = settings.tax;
  const n = settings.notifications;
  const s = settings.security;
  const mnt = settings.maintenance;
  const mfa = settings.mfa;

  return (
    <div className="flex flex-col gap-6">
      {/* Mobile: horizontal section chips */}
      <nav className="-mx-1 flex gap-1.5 overflow-x-auto px-1 pb-1 lg:hidden">
        {SECTIONS.map((sec) => {
          const Icon = sec.icon;
          return (
            <button
              key={sec.id}
              type="button"
              onClick={() => setTab(sec.id)}
              className={cn(
                'inline-flex shrink-0 items-center gap-1.5 rounded-full px-3 py-2 text-xs font-semibold transition-colors',
                tab === sec.id
                  ? 'bg-primary text-primary-foreground'
                  : 'bg-muted text-muted-foreground hover:text-foreground'
              )}
            >
              <Icon className="size-3.5 opacity-80" />
              {sec.label}
            </button>
          );
        })}
      </nav>

      <div className="grid gap-6 lg:grid-cols-[220px_minmax(0,1fr)]">
        <nav className="surface hidden h-fit p-2 lg:sticky lg:top-24 lg:block">
          {SECTIONS.map((sec) => {
            const Icon = sec.icon;
            return (
              <button
                key={sec.id}
                type="button"
                onClick={() => setTab(sec.id)}
                className={cn(
                  'flex w-full items-center gap-2.5 rounded-lg px-3 py-2.5 text-left text-sm font-medium transition-colors',
                  tab === sec.id
                    ? 'bg-primary/10 text-primary'
                    : 'text-muted-foreground hover:bg-muted hover:text-foreground'
                )}
              >
                <Icon className="size-4 shrink-0 opacity-80" />
                {sec.label}
              </button>
            );
          })}
        </nav>

        <Card className="min-w-0">
          <CardHeader>
            <CardTitle>{active.label}</CardTitle>
            <CardDescription>{active.description}</CardDescription>
          </CardHeader>
          <CardContent className="min-w-0 space-y-5">
          {tab === 'general' && (
            <div className="grid gap-4 sm:grid-cols-2">
              <TextInput label="Company name" value={asString(g.companyName)} onChange={(v) => set('general', 'companyName', v)} />
              <TextInput label="Legal name" value={asString(g.legalName)} onChange={(v) => set('general', 'legalName', v)} />
              <TextInput label="Support email" type="email" value={asString(g.supportEmail)} onChange={(v) => set('general', 'supportEmail', v)} />
              <TextInput label="Support phone" value={asString(g.supportPhone)} onChange={(v) => set('general', 'supportPhone', v)} />
              <TextInput label="WhatsApp number" value={asString(g.whatsappNumber)} onChange={(v) => set('general', 'whatsappNumber', v)} />
              <TextInput label="Website" value={asString(g.website)} onChange={(v) => set('general', 'website', v)} placeholder="https://" />
              <TextInput label="Address" value={asString(g.address)} onChange={(v) => set('general', 'address', v)} />
              <TextInput label="City" value={asString(g.city)} onChange={(v) => set('general', 'city', v)} />
              <TextInput label="Country" value={asString(g.country)} onChange={(v) => set('general', 'country', v)} />
              <TextInput label="Timezone" value={asString(g.timezone)} onChange={(v) => set('general', 'timezone', v)} hint="e.g. Africa/Addis_Ababa" />
              <TextInput label="Locale" value={asString(g.locale)} onChange={(v) => set('general', 'locale', v)} hint="e.g. en-ET" />
              <TextInput
                label="Business hours note"
                value={asString(g.businessHoursNote)}
                onChange={(v) => set('general', 'businessHoursNote', v)}
              />
            </div>
          )}

          {tab === 'branding' && (
            <div className="grid gap-4 sm:grid-cols-2">
              <TextInput label="App name" value={asString(b.appName)} onChange={(v) => set('branding', 'appName', v)} />
              <TextInput label="Tagline" value={asString(b.tagline)} onChange={(v) => set('branding', 'tagline', v)} />
              <TextInput label="Primary color" value={asString(b.primaryColor)} onChange={(v) => set('branding', 'primaryColor', v)} placeholder="#0f766e" />
              <TextInput label="Secondary color" value={asString(b.secondaryColor)} onChange={(v) => set('branding', 'secondaryColor', v)} />
              <TextInput label="Logo URL" value={asString(b.logoUrl)} onChange={(v) => set('branding', 'logoUrl', v)} />
              <TextInput label="Favicon URL" value={asString(b.faviconUrl)} onChange={(v) => set('branding', 'faviconUrl', v)} />
            </div>
          )}

          {tab === 'booking' && (
            <div className="space-y-4">
              <div className="grid gap-4 sm:grid-cols-2">
                <NumberInput label="Default slot (minutes)" value={asNumber(bk.defaultSlotMinutes, 60)} onChange={(v) => set('booking', 'defaultSlotMinutes', v)} min={15} max={480} />
                <NumberInput label="Min advance (hours)" value={asNumber(bk.minAdvanceHours, 2)} onChange={(v) => set('booking', 'minAdvanceHours', v)} min={0} />
                <NumberInput label="Max advance (days)" value={asNumber(bk.maxAdvanceDays, 30)} onChange={(v) => set('booking', 'maxAdvanceDays', v)} min={1} />
                <NumberInput label="Cancel window (hours)" value={asNumber(bk.cancellationWindowHours, 6)} onChange={(v) => set('booking', 'cancellationWindowHours', v)} min={0} />
                <NumberInput label="Reschedule window (hours)" value={asNumber(bk.rescheduleWindowHours, 12)} onChange={(v) => set('booking', 'rescheduleWindowHours', v)} min={0} />
                <NumberInput
                  label="Max active bookings / customer"
                  value={asNumber(bk.maxActiveBookingsPerCustomer, 5)}
                  onChange={(v) => set('booking', 'maxActiveBookingsPerCustomer', v)}
                  min={1}
                />
              </div>
              <div className="grid gap-3 sm:grid-cols-2">
                <Toggle label="Allow customer cancel" checked={asBool(bk.allowCustomerCancel, true)} onChange={(v) => set('booking', 'allowCustomerCancel', v)} />
                <Toggle label="Allow customer reschedule" checked={asBool(bk.allowCustomerReschedule, true)} onChange={(v) => set('booking', 'allowCustomerReschedule', v)} />
                <Toggle label="Auto-assign technician" checked={asBool(bk.autoAssignTechnician)} onChange={(v) => set('booking', 'autoAssignTechnician', v)} />
                <Toggle label="Require service address" checked={asBool(bk.requireAddress, true)} onChange={(v) => set('booking', 'requireAddress', v)} />
                <Toggle label="Require phone verification" checked={asBool(bk.requirePhoneVerification)} onChange={(v) => set('booking', 'requirePhoneVerification', v)} />
              </div>
            </div>
          )}

          {tab === 'payments' && (
            <div className="space-y-4">
              <div className="grid gap-4 sm:grid-cols-2">
                <TextInput label="Default currency" value={asString(p.defaultCurrency, 'ETB')} onChange={(v) => set('payments', 'defaultCurrency', v)} />
                <NumberInput label="Platform fee (%)" value={asNumber(p.platformFeePercent, 10)} onChange={(v) => set('payments', 'platformFeePercent', v)} min={0} max={100} />
                <NumberInput label="Technician share (%)" value={asNumber(p.technicianCommissionPercent, 80)} onChange={(v) => set('payments', 'technicianCommissionPercent', v)} min={0} max={100} />
                <NumberInput label="Deposit (%)" value={asNumber(p.depositPercent, 0)} onChange={(v) => set('payments', 'depositPercent', v)} min={0} max={100} />
                <NumberInput label="Refund window (hours)" value={asNumber(p.refundWindowHours, 24)} onChange={(v) => set('payments', 'refundWindowHours', v)} min={0} />
                <TextInput
                  label="Accepted methods"
                  value={Array.isArray(p.acceptedMethods) ? (p.acceptedMethods as string[]).join(', ') : asString(p.acceptedMethods)}
                  onChange={(v) =>
                    set(
                      'payments',
                      'acceptedMethods',
                      v
                        .split(',')
                        .map((x) => x.trim())
                        .filter(Boolean)
                    )
                  }
                  hint="Comma-separated, e.g. chapa, telebirr, cash"
                />
              </div>
              <div className="grid gap-3 sm:grid-cols-2">
                <Toggle label="Require deposit" checked={asBool(p.depositRequired)} onChange={(v) => set('payments', 'depositRequired', v)} />
                <Toggle label="Auto-capture payments" checked={asBool(p.autoCapture, true)} onChange={(v) => set('payments', 'autoCapture', v)} />
              </div>
            </div>
          )}

          {tab === 'tax' && (
            <div className="space-y-4">
              <Toggle label="Enable tax" checked={asBool(t.enabled)} onChange={(v) => set('tax', 'enabled', v)} />
              <div className="grid gap-4 sm:grid-cols-2">
                <TextInput label="Tax name" value={asString(t.taxName, 'VAT')} onChange={(v) => set('tax', 'taxName', v)} />
                <NumberInput label="Rate (%)" value={asNumber(t.ratePercent, 15)} onChange={(v) => set('tax', 'ratePercent', v)} min={0} max={100} step={0.01} />
                <TextInput label="Tax ID / TIN" value={asString(t.taxId)} onChange={(v) => set('tax', 'taxId', v)} />
              </div>
              <Toggle label="Prices include tax" checked={asBool(t.inclusive)} onChange={(v) => set('tax', 'inclusive', v)} />
            </div>
          )}

          {tab === 'notifications' && (
            <div className="space-y-4">
              <div className="grid gap-3 sm:grid-cols-2">
                <Toggle label="Push notifications" checked={asBool(n.pushEnabled, true)} onChange={(v) => set('notifications', 'pushEnabled', v)} />
                <Toggle label="Email notifications" checked={asBool(n.emailEnabled)} onChange={(v) => set('notifications', 'emailEnabled', v)} />
                <Toggle label="SMS notifications" checked={asBool(n.smsEnabled)} onChange={(v) => set('notifications', 'smsEnabled', v)} />
                <Toggle label="Alert admin on new booking" checked={asBool(n.notifyAdminOnNewBooking, true)} onChange={(v) => set('notifications', 'notifyAdminOnNewBooking', v)} />
                <Toggle label="Alert admin on dispute" checked={asBool(n.notifyAdminOnDispute, true)} onChange={(v) => set('notifications', 'notifyAdminOnDispute', v)} />
              </div>
              <div className="grid gap-4 sm:grid-cols-2">
                <NumberInput label="Booking reminder (hours before)" value={asNumber(n.bookingReminderHours, 2)} onChange={(v) => set('notifications', 'bookingReminderHours', v)} min={0} />
                <TextInput label="Admin alert email" type="email" value={asString(n.adminAlertEmail)} onChange={(v) => set('notifications', 'adminAlertEmail', v)} />
              </div>
            </div>
          )}

          {tab === 'security' && (
            <div className="space-y-4">
              <div className="grid gap-4 sm:grid-cols-2">
                <NumberInput label="Session timeout (minutes)" value={asNumber(s.sessionTimeoutMinutes, 60)} onChange={(v) => set('security', 'sessionTimeoutMinutes', v)} min={5} max={1440} />
                <NumberInput label="Min password length" value={asNumber(s.minPasswordLength, 8)} onChange={(v) => set('security', 'minPasswordLength', v)} min={6} max={128} />
                <NumberInput label="Max login attempts" value={asNumber(s.maxLoginAttempts, 5)} onChange={(v) => set('security', 'maxLoginAttempts', v)} min={3} max={20} />
                <NumberInput label="Lockout (minutes)" value={asNumber(s.lockoutMinutes, 15)} onChange={(v) => set('security', 'lockoutMinutes', v)} min={1} />
              </div>
              <Toggle
                label="Require strong passwords"
                hint="Uppercase, lowercase, number, and symbol"
                checked={asBool(s.requireStrongPassword, true)}
                onChange={(v) => set('security', 'requireStrongPassword', v)}
              />
            </div>
          )}

          {tab === 'maintenance' && (
            <div className="space-y-4">
              <Toggle
                label="Maintenance mode"
                hint="Customers and technicians see the maintenance message"
                checked={asBool(mnt.enabled)}
                onChange={(v) => set('maintenance', 'enabled', v)}
              />
              <Toggle label="Allow admin access during maintenance" checked={asBool(mnt.allowAdminAccess, true)} onChange={(v) => set('maintenance', 'allowAdminAccess', v)} />
              <Field label="Maintenance message">
                <textarea
                  className="min-h-[100px] w-full rounded-lg border border-input bg-background px-3 py-2 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring"
                  value={asString(mnt.message)}
                  onChange={(e) => set('maintenance', 'message', e.target.value)}
                />
              </Field>
            </div>
          )}

          {tab === 'mfa' && (
            <div className="grid gap-3 sm:grid-cols-2">
              <Toggle label="Enable MFA" checked={asBool(mfa.enabled)} onChange={(v) => set('mfa', 'enabled', v)} />
              <Toggle label="Enforce MFA for admins" checked={asBool(mfa.enforcedForAdmins)} onChange={(v) => set('mfa', 'enforcedForAdmins', v)} />
            </div>
          )}
        </CardContent>
        {canWrite && (
          <CardFooter className="justify-end gap-2">
            <Button type="button" size="lg" className="w-full sm:w-auto" disabled={m.isPending} onClick={() => m.mutate()}>
              {m.isPending ? 'Saving…' : 'Save all settings'}
            </Button>
          </CardFooter>
        )}
      </Card>
      </div>
    </div>
  );
}

export default function SettingsPage() {
  const read = useAuthStore((s) => s.hasPermission(P.SETTINGS_READ));
  const write = useAuthStore((s) => s.hasPermission(P.SETTINGS_WRITE));
  const q = useQuery({ queryKey: ['platform-settings'], queryFn: fetchSettings, enabled: read });

  const payload = useMemo(() => {
    if (!q.isSuccess || !q.data.success || !('data' in q.data)) return null;
    const d = q.data.data as PlatformSettings;
    return {
      general: d.general ?? {},
      branding: d.branding ?? {},
      booking: d.booking ?? {},
      payments: d.payments ?? {},
      tax: d.tax ?? {},
      notifications: d.notifications ?? {},
      security: d.security ?? {},
      maintenance: d.maintenance ?? {},
      mfa: d.mfa ?? {},
    } satisfies PlatformSettings;
  }, [q.data, q.isSuccess]);

  if (!read) return <Navigate to="/forbidden" replace />;

  if (!payload) {
    return <p className="text-muted-foreground">Loading settings…</p>;
  }

  return (
    <div className="page-shell max-w-5xl">
      <PageHeader
        eyebrow="Platform"
        title="Settings"
        description="Configure company profile, bookings, payments, tax, notifications, and security for production."
      />
      <SettingsForm key={q.dataUpdatedAt} payload={payload} canWrite={write} />
    </div>
  );
}
