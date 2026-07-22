import { Link, Navigate } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import { motion } from 'framer-motion';
import {
  ArrowUpRight,
  Banknote,
  CalendarDays,
  Clock,
  Timer,
  Users,
  Wrench,
} from 'lucide-react';
import {
  Area,
  AreaChart,
  Bar,
  BarChart,
  CartesianGrid,
  Cell,
  Legend,
  Pie,
  PieChart,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from 'recharts';
import { fetchDashboard, fetchDashboardAnalytics } from '@/api/admin.api';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Skeleton } from '@/components/ui/skeleton';
import { PageHeader } from '@/components/data-table';
import { P } from '@/constants/permissions';
import { useAuthStore } from '@/state/authStore';
import { cn } from '@/lib/utils';
import {
  chartColors,
  chartGrid,
  chartTooltipStyle,
  paymentChartPalette,
  statusChartPalette,
} from '@/lib/chart';
import { formatCompact, formatMoney, formatStatusLabel } from '@/lib/format';
import type { LucideIcon } from 'lucide-react';

const MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

const statusStyles: Record<string, string> = {
  pending: 'bg-amber-500/10 text-amber-900 dark:text-amber-200 border-amber-500/25',
  accepted: 'bg-sky-500/10 text-sky-900 dark:text-sky-200 border-sky-500/25',
  on_the_way: 'bg-violet-500/10 text-violet-900 dark:text-violet-200 border-violet-500/25',
  in_progress: 'bg-primary/10 text-primary border-primary/25',
  completed: 'bg-emerald-500/10 text-emerald-900 dark:text-emerald-200 border-emerald-500/25',
  cancelled: 'bg-muted text-muted-foreground border-border',
};

type StatTile = {
  label: string;
  key: 'totalBookings' | 'totalUsers' | 'totalTechnicians' | 'pendingTechnicians' | 'totalEarnings';
  icon: LucideIcon;
  format?: 'money' | 'number';
  hint: string;
};

const statTiles: StatTile[] = [
  { label: 'Total bookings', key: 'totalBookings', icon: CalendarDays, hint: 'All-time jobs' },
  { label: 'Customers', key: 'totalUsers', icon: Users, hint: 'Registered users' },
  { label: 'Technicians', key: 'totalTechnicians', icon: Wrench, hint: 'Active workforce' },
  { label: 'Pending approvals', key: 'pendingTechnicians', icon: Clock, hint: 'Awaiting review' },
  { label: 'Earnings paid', key: 'totalEarnings', icon: Banknote, format: 'money', hint: 'Collected revenue' },
];

function ChartEmpty({ label = 'Not enough data yet' }: { label?: string }) {
  return (
    <div className="flex h-full min-h-[12rem] items-center justify-center rounded-xl bg-muted/25 px-4 text-center text-sm text-muted-foreground">
      {label}
    </div>
  );
}

export default function DashboardPage() {
  const ok = useAuthStore((s) => s.hasPermission(P.DASHBOARD_READ));
  const user = useAuthStore((s) => s.user);
  const qDash = useQuery({ queryKey: ['admin', 'dashboard'], queryFn: fetchDashboard });
  const qAn = useQuery({ queryKey: ['admin', 'dashboard-analytics'], queryFn: () => fetchDashboardAnalytics({}) });

  if (!ok) return <Navigate to="/forbidden" replace />;

  const dash = qDash.data?.success && 'data' in qDash.data ? (qDash.data.data as Record<string, unknown>) : null;
  const stats = (dash?.stats as Record<string, number> | undefined) ?? {};
  const breakdown = (dash?.bookingStatusBreakdown as Record<string, number> | undefined) ?? {};
  const recentBookings =
    (dash?.recentBookings as Array<Record<string, unknown> & { _id: string }>) ?? [];

  const an = qAn.data?.success && 'data' in qAn.data ? (qAn.data.data as Record<string, unknown>) : null;
  const byMonth = (an?.byMonth as Array<{ _id: { y: number; m: number }; bookings: number; revenue: number }>) ?? [];
  const paymentMix = (an?.paymentMix as Array<{ _id: string; count: number }>) ?? [];
  const byService = (an?.byService as Array<{ _id: string; count: number }>) ?? [];
  const techPerf =
    (an?.techPerf as Array<{ techName?: string; completed: number; revenue: number }>) ?? [];
  const avgTurnaroundHours = an?.avgTurnaroundHours as number | null | undefined;

  const chartData = byMonth.map((b) => ({
    label: `${MONTHS[(b._id.m ?? 1) - 1] ?? b._id.m} ${String(b._id.y).slice(2)}`,
    bookings: b.bookings,
    revenue: b.revenue,
  }));

  const statusData = Object.entries(breakdown).map(([name, value]) => ({
    name: formatStatusLabel(name),
    value,
    raw: name,
  }));

  const paymentData = paymentMix.map((p) => ({
    name: formatStatusLabel(String(p._id || 'unknown')),
    value: p.count,
  }));

  const serviceData = byService.slice(0, 8).map((s) => ({
    name: String(s._id || 'Service').slice(0, 22),
    count: s.count,
  }));

  const techData = techPerf.slice(0, 8).map((t) => ({
    name: String(t.techName || 'Technician').slice(0, 18),
    completed: t.completed,
    revenue: t.revenue,
  }));

  const first = user?.firstName?.trim() || 'there';
  const totalStatus = statusData.reduce((sum, d) => sum + d.value, 0);

  return (
    <div className="page-shell space-y-7">
      <PageHeader
        eyebrow="Overview"
        title={`Welcome back, ${first}`}
        description="Live pulse of bookings, revenue, technicians, and customer activity."
        actions={
          <Button asChild variant="outline" className="rounded-full">
            <Link to="/bookings">
              View bookings
              <ArrowUpRight className="size-3.5 opacity-70" />
            </Link>
          </Button>
        }
      />

      <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-6">
        {statTiles.map(({ label, key, icon: Icon, format, hint }, i) => {
          const raw = stats[key] ?? 0;
          const display = format === 'money' ? formatMoney(raw) : formatCompact(raw);
          return (
            <motion.div
              key={key}
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: i * 0.04, duration: 0.35 }}
              className="surface p-4"
            >
              <div className="flex items-start justify-between gap-2">
                <div>
                  <p className="text-xs font-medium text-muted-foreground">{label}</p>
                  <div className="mt-2 text-2xl font-bold tabular-nums tracking-tight">
                    {qDash.isLoading ? <Skeleton className="h-8 w-16 rounded-md" /> : display}
                  </div>
                  <p className="mt-1 text-[11px] text-muted-foreground/80">{hint}</p>
                </div>
                <span className="flex size-9 shrink-0 items-center justify-center rounded-lg bg-primary/10 text-primary">
                  <Icon className="size-4" aria-hidden />
                </span>
              </div>
            </motion.div>
          );
        })}

        <motion.div
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.22, duration: 0.35 }}
          className="surface bg-gradient-to-br from-primary/[0.08] via-card to-card p-4"
        >
          <div className="flex items-start justify-between gap-2">
            <div>
              <p className="text-xs font-medium text-muted-foreground">Avg. turnaround</p>
              <div className="mt-2 text-2xl font-bold tabular-nums tracking-tight">
                {qAn.isLoading ? (
                  <Skeleton className="h-8 w-16 rounded-md" />
                ) : avgTurnaroundHours != null ? (
                  `${Number(avgTurnaroundHours).toFixed(1)}h`
                ) : (
                  '—'
                )}
              </div>
              <p className="mt-1 text-[11px] text-muted-foreground/80">Job completion time</p>
            </div>
            <span className="flex size-9 shrink-0 items-center justify-center rounded-lg bg-primary/15 text-primary">
              <Timer className="size-4" aria-hidden />
            </span>
          </div>
        </motion.div>
      </div>

      <div className="grid gap-5 xl:grid-cols-3">
        <Card className="xl:col-span-2">
          <CardHeader className="flex flex-row items-start justify-between space-y-0 pb-2">
            <div>
              <CardTitle>Booking volume & revenue</CardTitle>
              <CardDescription>Monthly trend across the platform</CardDescription>
            </div>
          </CardHeader>
          <CardContent className="h-[300px] pt-2">
            {qAn.isLoading ? (
              <Skeleton className="h-full w-full rounded-xl" />
            ) : chartData.length === 0 ? (
              <ChartEmpty />
            ) : (
              <ResponsiveContainer width="100%" height="100%">
                <AreaChart data={chartData} margin={{ top: 8, right: 8, left: -8, bottom: 0 }}>
                  <defs>
                    <linearGradient id="fillBookings" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="0%" stopColor={chartColors.primary} stopOpacity={0.35} />
                      <stop offset="100%" stopColor={chartColors.primary} stopOpacity={0.02} />
                    </linearGradient>
                    <linearGradient id="fillRevenue" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="0%" stopColor={chartColors.secondary} stopOpacity={0.28} />
                      <stop offset="100%" stopColor={chartColors.secondary} stopOpacity={0.02} />
                    </linearGradient>
                  </defs>
                  <CartesianGrid stroke={chartGrid} strokeDasharray="4 8" vertical={false} />
                  <XAxis
                    dataKey="label"
                    tick={{ fontSize: 11, fill: 'hsl(var(--muted-foreground))' }}
                    axisLine={false}
                    tickLine={false}
                  />
                  <YAxis
                    yAxisId="left"
                    tick={{ fontSize: 11, fill: 'hsl(var(--muted-foreground))' }}
                    axisLine={false}
                    tickLine={false}
                    width={36}
                  />
                  <YAxis
                    yAxisId="right"
                    orientation="right"
                    tick={{ fontSize: 11, fill: 'hsl(var(--muted-foreground))' }}
                    axisLine={false}
                    tickLine={false}
                    width={48}
                    tickFormatter={(v) => formatCompact(Number(v))}
                  />
                  <Tooltip
                    contentStyle={chartTooltipStyle}
                    labelStyle={{ color: 'hsl(var(--muted-foreground))', marginBottom: 4 }}
                    formatter={(value, name) => {
                      const n = Number(value);
                      if (name === 'Revenue') return [formatMoney(n), name];
                      return [n.toLocaleString(), name];
                    }}
                  />
                  <Legend wrapperStyle={{ fontSize: 12, paddingTop: 8 }} />
                  <Area
                    yAxisId="left"
                    type="monotone"
                    dataKey="bookings"
                    name="Bookings"
                    stroke={chartColors.primary}
                    fill="url(#fillBookings)"
                    strokeWidth={2.25}
                  />
                  <Area
                    yAxisId="right"
                    type="monotone"
                    dataKey="revenue"
                    name="Revenue"
                    stroke={chartColors.secondary}
                    fill="url(#fillRevenue)"
                    strokeWidth={2.25}
                  />
                </AreaChart>
              </ResponsiveContainer>
            )}
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="pb-2">
            <CardTitle>Status mix</CardTitle>
            <CardDescription>Current booking pipeline</CardDescription>
          </CardHeader>
          <CardContent className="pt-1">
            {qDash.isLoading ? (
              <Skeleton className="h-56 w-full rounded-xl" />
            ) : statusData.length === 0 ? (
              <ChartEmpty />
            ) : (
              <>
                <div className="mx-auto h-48 w-full max-w-[220px]">
                  <ResponsiveContainer width="100%" height="100%">
                    <PieChart>
                      <Pie
                        data={statusData}
                        dataKey="value"
                        nameKey="name"
                        innerRadius={52}
                        outerRadius={76}
                        paddingAngle={2}
                        stroke="hsl(var(--card))"
                        strokeWidth={2}
                      >
                        {statusData.map((_, i) => (
                          <Cell key={i} fill={statusChartPalette[i % statusChartPalette.length]} />
                        ))}
                      </Pie>
                      <Tooltip contentStyle={chartTooltipStyle} />
                    </PieChart>
                  </ResponsiveContainer>
                </div>
                <ul className="mt-2 space-y-1.5">
                  {statusData.map((d, i) => (
                    <li key={d.raw} className="flex items-center justify-between gap-2 text-xs">
                      <span className="flex min-w-0 items-center gap-2 capitalize text-muted-foreground">
                        <span
                          className="size-2 shrink-0 rounded-full"
                          style={{ background: statusChartPalette[i % statusChartPalette.length] }}
                        />
                        <span className="truncate">{d.name}</span>
                      </span>
                      <span className="font-semibold tabular-nums text-foreground">
                        {d.value}
                        {totalStatus > 0 && (
                          <span className="ml-1 font-normal text-muted-foreground">
                            ({Math.round((d.value / totalStatus) * 100)}%)
                          </span>
                        )}
                      </span>
                    </li>
                  ))}
                </ul>
              </>
            )}
          </CardContent>
        </Card>
      </div>

      <div className="grid gap-5 lg:grid-cols-2 xl:grid-cols-3">
        <Card>
          <CardHeader className="pb-2">
            <CardTitle>Top services</CardTitle>
            <CardDescription>Most requested repair categories</CardDescription>
          </CardHeader>
          <CardContent className="h-[280px] pt-2">
            {qAn.isLoading ? (
              <Skeleton className="h-full w-full rounded-xl" />
            ) : serviceData.length === 0 ? (
              <ChartEmpty />
            ) : (
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={serviceData} layout="vertical" margin={{ top: 4, right: 12, left: 4, bottom: 0 }}>
                  <CartesianGrid stroke={chartGrid} strokeDasharray="4 8" horizontal={false} />
                  <XAxis type="number" tick={{ fontSize: 11, fill: 'hsl(var(--muted-foreground))' }} axisLine={false} tickLine={false} />
                  <YAxis
                    type="category"
                    dataKey="name"
                    width={96}
                    tick={{ fontSize: 11, fill: 'hsl(var(--muted-foreground))' }}
                    axisLine={false}
                    tickLine={false}
                  />
                  <Tooltip contentStyle={chartTooltipStyle} />
                  <Bar dataKey="count" name="Bookings" fill={chartColors.primary} radius={[0, 6, 6, 0]} barSize={14} />
                </BarChart>
              </ResponsiveContainer>
            )}
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="pb-2">
            <CardTitle>Technician performance</CardTitle>
            <CardDescription>Completed jobs by top technicians</CardDescription>
          </CardHeader>
          <CardContent className="h-[280px] pt-2">
            {qAn.isLoading ? (
              <Skeleton className="h-full w-full rounded-xl" />
            ) : techData.length === 0 ? (
              <ChartEmpty />
            ) : (
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={techData} margin={{ top: 4, right: 8, left: -12, bottom: 28 }}>
                  <CartesianGrid stroke={chartGrid} strokeDasharray="4 8" vertical={false} />
                  <XAxis
                    dataKey="name"
                    interval={0}
                    angle={-28}
                    textAnchor="end"
                    height={48}
                    tick={{ fontSize: 10, fill: 'hsl(var(--muted-foreground))' }}
                    axisLine={false}
                    tickLine={false}
                  />
                  <YAxis tick={{ fontSize: 11, fill: 'hsl(var(--muted-foreground))' }} axisLine={false} tickLine={false} width={32} />
                  <Tooltip
                    contentStyle={chartTooltipStyle}
                    formatter={(value, name) => {
                      if (name === 'Revenue') return [formatMoney(Number(value)), name];
                      return [Number(value).toLocaleString(), String(name)];
                    }}
                  />
                  <Bar dataKey="completed" name="Completed" fill={chartColors.success} radius={[6, 6, 0, 0]} barSize={18} />
                </BarChart>
              </ResponsiveContainer>
            )}
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="pb-2">
            <CardTitle>Payment mix</CardTitle>
            <CardDescription>Distribution by payment status</CardDescription>
          </CardHeader>
          <CardContent className="pt-1">
            {qAn.isLoading ? (
              <Skeleton className="h-56 w-full rounded-xl" />
            ) : paymentData.length === 0 ? (
              <ChartEmpty />
            ) : (
              <>
                <div className="mx-auto h-48 w-full max-w-[220px]">
                  <ResponsiveContainer width="100%" height="100%">
                    <PieChart>
                      <Pie
                        data={paymentData}
                        dataKey="value"
                        nameKey="name"
                        innerRadius={48}
                        outerRadius={74}
                        paddingAngle={2}
                        stroke="hsl(var(--card))"
                        strokeWidth={2}
                      >
                        {paymentData.map((_, i) => (
                          <Cell key={i} fill={paymentChartPalette[i % paymentChartPalette.length]} />
                        ))}
                      </Pie>
                      <Tooltip contentStyle={chartTooltipStyle} />
                    </PieChart>
                  </ResponsiveContainer>
                </div>
                <ul className="mt-2 space-y-1.5">
                  {paymentData.map((d, i) => (
                    <li key={d.name} className="flex items-center justify-between gap-2 text-xs">
                      <span className="flex items-center gap-2 capitalize text-muted-foreground">
                        <span
                          className="size-2 rounded-full"
                          style={{ background: paymentChartPalette[i % paymentChartPalette.length] }}
                        />
                        {d.name}
                      </span>
                      <span className="font-semibold tabular-nums">{d.value}</span>
                    </li>
                  ))}
                </ul>
              </>
            )}
          </CardContent>
        </Card>
      </div>

      <Card>
        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-3">
          <div>
            <CardTitle>Recent bookings</CardTitle>
            <CardDescription>Latest activity across the platform</CardDescription>
          </div>
          <Button asChild variant="ghost" size="sm" className="rounded-full text-muted-foreground">
            <Link to="/bookings">
              See all
              <ArrowUpRight className="size-3.5" />
            </Link>
          </Button>
        </CardHeader>
        <CardContent className="px-0 pb-2">
          {qDash.isLoading ? (
            <div className="space-y-3 px-6 pb-4">
              {Array.from({ length: 5 }).map((_, i) => (
                <Skeleton key={i} className="h-12 w-full rounded-lg" />
              ))}
            </div>
          ) : recentBookings.length === 0 ? (
            <p className="px-6 pb-6 text-sm text-muted-foreground">No recent bookings yet.</p>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full text-sm">
                <thead>
                  <tr className="border-b border-black/[0.06] bg-muted/40 text-left text-[11px] font-semibold uppercase tracking-[0.06em] text-muted-foreground dark:border-white/[0.08] dark:bg-white/[0.03]">
                    <th className="px-5 py-3">Customer</th>
                    <th className="px-4 py-3">Service</th>
                    <th className="px-4 py-3">Status</th>
                    <th className="px-4 py-3">Price</th>
                    <th className="px-5 py-3 text-right"> </th>
                  </tr>
                </thead>
                <tbody>
                  {recentBookings.slice(0, 8).map((b) => {
                    const u = b.user as Record<string, string> | undefined;
                    const svc = b.service as { name?: string } | undefined;
                    const status = String(b.status ?? '');
                    return (
                      <tr
                        key={String(b._id)}
                        className="border-b border-black/[0.04] last:border-0 hover:bg-muted/40 dark:border-white/[0.05] dark:hover:bg-white/[0.03]"
                      >
                        <td className="px-5 py-3 font-medium">
                          {u?.firstName} {u?.lastName}
                        </td>
                        <td className="px-4 py-3 text-muted-foreground">{svc?.name ?? '—'}</td>
                        <td className="px-4 py-3">
                          <Badge className={cn('border font-medium capitalize', statusStyles[status] ?? statusStyles.pending)}>
                            {formatStatusLabel(status)}
                          </Badge>
                        </td>
                        <td className="px-4 py-3 tabular-nums font-medium">{formatMoney(b.price as number)}</td>
                        <td className="px-5 py-3 text-right">
                          <Button asChild variant="ghost" size="sm" className="rounded-full">
                            <Link to={`/bookings/${String(b._id)}`}>Open</Link>
                          </Button>
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
