import { Outlet } from 'react-router-dom';

export default function AuthLayout() {
  return (
    <div className="relative flex min-h-screen overflow-hidden">
      <div
        className="pointer-events-none absolute inset-0 bg-[radial-gradient(ellipse_at_top_left,hsl(173_58%_32%/0.18),transparent_50%),radial-gradient(ellipse_at_bottom_right,hsl(199_72%_42%/0.12),transparent_45%)]"
        aria-hidden
      />
      <div
        className="pointer-events-none absolute inset-0 opacity-[0.035] dark:opacity-[0.06]"
        style={{
          backgroundImage:
            'url("data:image/svg+xml,%3Csvg width=\'60\' height=\'60\' viewBox=\'0 0 60 60\' xmlns=\'http://www.w3.org/2000/svg\'%3E%3Cg fill=\'none\' fill-rule=\'evenodd\'%3E%3Cg fill=\'%23000000\' fill-opacity=\'1\'%3E%3Cpath d=\'M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0-30V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6 34v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6 4V0H4v4H0v2h4v4h2V6h4V4H6z\'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E")',
        }}
        aria-hidden
      />

      <div className="relative hidden w-[42%] flex-col justify-between bg-sidebar p-10 text-sidebar-foreground lg:flex xl:w-[46%]">
        <div className="flex items-center gap-3">
          <div className="flex size-10 items-center justify-center rounded-xl bg-primary text-sm font-bold text-primary-foreground">
            RB
          </div>
          <div>
            <p className="text-sm font-bold tracking-tight">RepairBooking</p>
            <p className="text-xs text-sidebar-muted">Admin console</p>
          </div>
        </div>

        <div className="max-w-md space-y-4">
          <p className="text-[11px] font-semibold uppercase tracking-[0.18em] text-primary">Operations hub</p>
          <h1 className="text-3xl font-bold leading-tight tracking-tight xl:text-4xl">
            Run bookings, technicians, and payouts from one calm workspace.
          </h1>
          <p className="text-sm leading-relaxed text-sidebar-muted">
            Monitor pipeline health, approve technicians, and keep finance moving — without the noise.
          </p>
        </div>

        <p className="text-xs text-sidebar-muted">Secure access for platform administrators only.</p>
      </div>

      <div className="relative flex flex-1 flex-col items-center justify-center px-4 py-10 sm:px-8">
        <div className="mb-8 flex items-center gap-2.5 lg:hidden">
          <div className="flex size-9 items-center justify-center rounded-xl bg-primary text-xs font-bold text-primary-foreground">
            RB
          </div>
          <span className="text-sm font-bold tracking-tight">RepairBooking Admin</span>
        </div>
        <Outlet />
      </div>
    </div>
  );
}
