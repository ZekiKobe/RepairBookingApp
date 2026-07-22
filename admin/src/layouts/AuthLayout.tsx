import { Outlet } from 'react-router-dom';

export default function AuthLayout() {
  return (
    <div className="grid min-h-screen lg:grid-cols-[1.05fr_1fr]">
      {/* Brand panel */}
      <aside className="relative hidden overflow-hidden bg-[#0f1c1a] text-white lg:flex lg:flex-col lg:justify-between lg:p-12 xl:p-14">
        <div
          className="pointer-events-none absolute inset-0 opacity-40"
          style={{
            background:
              'radial-gradient(ellipse 80% 60% at 10% 0%, rgba(20, 150, 120, 0.45), transparent 55%), radial-gradient(ellipse 70% 50% at 90% 100%, rgba(30, 100, 140, 0.35), transparent 50%)',
          }}
          aria-hidden
        />
        <div
          className="pointer-events-none absolute inset-0 opacity-[0.07]"
          style={{
            backgroundImage:
              'url("data:image/svg+xml,%3Csvg width=\'40\' height=\'40\' viewBox=\'0 0 40 40\' xmlns=\'http://www.w3.org/2000/svg\'%3E%3Cg fill=\'%23ffffff\' fill-opacity=\'1\' fill-rule=\'evenodd\'%3E%3Cpath d=\'M0 40L40 0H20L0 20M40 40V20L20 40\'/%3E%3C/g%3E%3C/svg%3E")',
          }}
          aria-hidden
        />

        <div className="relative z-10 flex items-center gap-3">
          <div className="flex size-11 items-center justify-center rounded-xl bg-teal-600 text-sm font-bold tracking-tight text-white">
            RB
          </div>
          <div>
            <p className="text-[15px] font-bold tracking-tight">RepairBooking</p>
            <p className="text-xs text-teal-100/55">Admin console</p>
          </div>
        </div>

        <div className="relative z-10 max-w-lg space-y-5">
          <p className="text-[11px] font-semibold uppercase tracking-[0.2em] text-teal-300/90">Operations hub</p>
          <h1 className="text-[2.15rem] font-bold leading-[1.15] tracking-tight text-white xl:text-[2.5rem]">
            Run bookings, technicians, and payouts from one calm workspace.
          </h1>
          <p className="max-w-md text-[15px] leading-relaxed text-teal-50/60">
            Monitor pipeline health, approve technicians, and keep finance moving — without the noise.
          </p>

          <ul className="mt-8 grid gap-3 text-sm text-teal-50/70">
            <li className="flex items-center gap-3 rounded-xl bg-white/[0.06] px-4 py-3 ring-1 ring-white/10">
              <span className="size-1.5 rounded-full bg-teal-400" />
              Live booking & revenue overview
            </li>
            <li className="flex items-center gap-3 rounded-xl bg-white/[0.06] px-4 py-3 ring-1 ring-white/10">
              <span className="size-1.5 rounded-full bg-teal-400" />
              Technician approvals & workforce tools
            </li>
            <li className="flex items-center gap-3 rounded-xl bg-white/[0.06] px-4 py-3 ring-1 ring-white/10">
              <span className="size-1.5 rounded-full bg-teal-400" />
              Finance ledger, refunds & reports
            </li>
          </ul>
        </div>

        <p className="relative z-10 text-xs text-teal-100/40">Secure access for platform administrators only.</p>
      </aside>

      {/* Form panel */}
      <div className="relative flex flex-col items-center justify-center bg-[#f4f6f8] px-5 py-10 sm:px-8">
        <div className="mb-8 flex items-center gap-2.5 lg:hidden">
          <div className="flex size-10 items-center justify-center rounded-xl bg-teal-700 text-xs font-bold text-white">
            RB
          </div>
          <span className="text-sm font-bold tracking-tight text-slate-900">RepairBooking Admin</span>
        </div>
        <Outlet />
      </div>
    </div>
  );
}
