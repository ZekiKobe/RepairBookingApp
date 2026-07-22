import { useEffect, useState } from 'react';
import { NavLink, Outlet, useLocation, useNavigate } from 'react-router-dom';
import {
  Bell,
  ChevronDown,
  ClipboardList,
  FileBarChart,
  KeyRound,
  LayoutDashboard,
  LogOut,
  Menu,
  Moon,
  PanelLeft,
  PanelLeftClose,
  ScrollText,
  Settings,
  Sun,
  Users,
  Wallet,
  Wrench,
  X,
} from 'lucide-react';
import { useTheme } from 'next-themes';
import { ChangePasswordDialog } from '@/components/ChangePasswordDialog';
import { Button } from '@/components/ui/button';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import { cn } from '@/lib/utils';
import { initials } from '@/lib/format';
import { useAuthStore } from '@/state/authStore';
import { P, type PermissionKey } from '@/constants/permissions';
import type { LucideIcon } from 'lucide-react';

const navGroups: { label: string; items: { to: string; label: string; perm: PermissionKey; icon: LucideIcon }[] }[] = [
  {
    label: 'Overview',
    items: [
      { to: '/', label: 'Dashboard', perm: P.DASHBOARD_READ, icon: LayoutDashboard },
      { to: '/bookings', label: 'Bookings', perm: P.BOOKINGS_READ, icon: ClipboardList },
    ],
  },
  {
    label: 'People',
    items: [
      { to: '/users', label: 'Users', perm: P.USERS_READ, icon: Users },
      { to: '/technicians', label: 'Technicians', perm: P.TECHNICIANS_READ, icon: Wrench },
    ],
  },
  {
    label: 'Business',
    items: [
      { to: '/finance', label: 'Finance', perm: P.FINANCE_READ, icon: Wallet },
      { to: '/reports', label: 'Reports', perm: P.REPORTS_READ, icon: FileBarChart },
      { to: '/notifications', label: 'Notifications', perm: P.NOTIFICATIONS_READ, icon: Bell },
    ],
  },
  {
    label: 'System',
    items: [
      { to: '/settings', label: 'Settings', perm: P.SETTINGS_READ, icon: Settings },
      { to: '/audit', label: 'Audit log', perm: P.AUDIT_READ, icon: ScrollText },
    ],
  },
];

const pageTitles: Record<string, string> = {
  '/': 'Dashboard',
  '/bookings': 'Bookings',
  '/users': 'Users',
  '/technicians': 'Technicians',
  '/finance': 'Finance',
  '/notifications': 'Notifications',
  '/reports': 'Reports',
  '/settings': 'Settings',
  '/audit': 'Audit log',
};

function resolveTitle(pathname: string) {
  if (pageTitles[pathname]) return pageTitles[pathname];
  if (pathname.startsWith('/bookings/')) return 'Booking detail';
  if (pathname.startsWith('/users/')) return 'User profile';
  return 'Admin';
}

export default function AppShell() {
  const [collapsed, setCollapsed] = useState(false);
  const [mobileOpen, setMobileOpen] = useState(false);
  const [passwordOpen, setPasswordOpen] = useState(false);
  const { theme, setTheme } = useTheme();
  const navigate = useNavigate();
  const location = useLocation();
  const user = useAuthStore((s) => s.user);
  const clearSession = useAuthStore((s) => s.clearSession);
  const hasPermission = useAuthStore((s) => s.hasPermission);
  const title = resolveTitle(location.pathname);
  const canSettings = hasPermission(P.SETTINGS_READ);

  // Drawer always shows labels on mobile; desktop respects collapse.
  const showLabels = mobileOpen || !collapsed;

  function logout() {
    clearSession();
    navigate('/login', { replace: true });
  }

  useEffect(() => {
    setMobileOpen(false);
  }, [location.pathname]);

  useEffect(() => {
    const mq = window.matchMedia('(min-width: 1024px)');
    const onChange = () => {
      if (mq.matches) setMobileOpen(false);
    };
    mq.addEventListener('change', onChange);
    return () => mq.removeEventListener('change', onChange);
  }, []);

  useEffect(() => {
    if (!mobileOpen) return;
    const prev = document.body.style.overflow;
    document.body.style.overflow = 'hidden';
    return () => {
      document.body.style.overflow = prev;
    };
  }, [mobileOpen]);

  return (
    <div className="flex min-h-dvh min-h-screen overflow-x-hidden bg-background">
      <aside
        className={cn(
          'fixed inset-y-0 left-0 z-50 flex w-[min(18rem,88vw)] shrink-0 flex-col bg-sidebar text-sidebar-foreground transition-[width,transform] duration-200 lg:z-40',
          // Desktop width only — mobile drawer always expanded
          collapsed ? 'lg:w-[4.5rem]' : 'lg:w-64',
          mobileOpen ? 'translate-x-0 shadow-2xl' : '-translate-x-full lg:translate-x-0 lg:shadow-none'
        )}
      >
        <div className={cn('flex h-14 shrink-0 items-center gap-3 px-4 sm:h-16', !showLabels && 'lg:justify-center lg:px-2')}>
          <div className="flex size-9 shrink-0 items-center justify-center rounded-xl bg-primary text-sm font-bold text-primary-foreground">
            RB
          </div>
          {showLabels && (
            <div className="min-w-0 flex-1">
              <p className="truncate text-sm font-bold tracking-tight">RepairBooking</p>
              <p className="truncate text-[11px] text-sidebar-muted">Operations console</p>
            </div>
          )}
          {showLabels && (
            <Button
              variant="ghost"
              size="icon"
              className="hidden size-8 shrink-0 text-sidebar-muted hover:bg-white/10 hover:text-sidebar-foreground lg:flex"
              onClick={() => setCollapsed(true)}
            >
              <PanelLeftClose className="size-4" />
            </Button>
          )}
          <Button
            variant="ghost"
            size="icon"
            className="size-8 shrink-0 text-sidebar-muted hover:bg-white/10 lg:hidden"
            onClick={() => setMobileOpen(false)}
            aria-label="Close menu"
          >
            <X className="size-4" />
          </Button>
        </div>

        <nav className="flex min-h-0 flex-1 flex-col gap-5 overflow-y-auto overflow-x-hidden overscroll-contain px-3 pb-4 pt-1">
          {navGroups.map((group) => {
            const items = group.items.filter((n) => hasPermission(n.perm));
            if (!items.length) return null;
            return (
              <div key={group.label}>
                {showLabels && (
                  <p className="mb-1.5 px-2.5 text-[10px] font-semibold uppercase tracking-[0.14em] text-sidebar-muted/80">
                    {group.label}
                  </p>
                )}
                <div className="flex flex-col gap-0.5">
                  {items.map((n) => {
                    const Icon = n.icon;
                    return (
                      <NavLink
                        key={n.to}
                        to={n.to}
                        end={n.to === '/'}
                        onClick={() => setMobileOpen(false)}
                        title={!showLabels ? n.label : undefined}
                        className={({ isActive }) =>
                          cn(
                            'group relative flex items-center gap-3 rounded-lg px-2.5 py-2.5 text-[13px] font-medium transition-colors',
                            isActive
                              ? 'bg-white/10 text-sidebar-foreground'
                              : 'text-sidebar-muted hover:bg-white/[0.06] hover:text-sidebar-foreground',
                            !showLabels && 'lg:justify-center lg:px-2'
                          )
                        }
                      >
                        {({ isActive }) => (
                          <>
                            {isActive && (
                              <span className="absolute left-0 top-1/2 h-5 w-0.5 -translate-y-1/2 rounded-full bg-primary" />
                            )}
                            <Icon className="size-4 shrink-0 opacity-90" aria-hidden />
                            {showLabels && <span className="truncate">{n.label}</span>}
                          </>
                        )}
                      </NavLink>
                    );
                  })}
                </div>
              </div>
            );
          })}
        </nav>

        <div className={cn('p-3', !showLabels && 'lg:flex lg:justify-center')}>
          {!showLabels ? (
            <Button
              variant="ghost"
              size="icon"
              className="hidden size-9 text-sidebar-muted hover:bg-white/10 lg:flex"
              onClick={() => setCollapsed(false)}
            >
              <PanelLeft className="size-4" />
            </Button>
          ) : (
            <div className="flex items-center gap-2.5 rounded-xl bg-white/[0.04] px-2.5 py-2">
              <div className="flex size-8 shrink-0 items-center justify-center rounded-full bg-primary/20 text-[11px] font-semibold text-primary-foreground/90">
                {initials(user?.firstName, user?.lastName)}
              </div>
              <div className="min-w-0 flex-1">
                <p className="truncate text-xs font-semibold">
                  {user?.firstName} {user?.lastName}
                </p>
                <p className="truncate text-[10px] text-sidebar-muted">Administrator</p>
              </div>
            </div>
          )}
        </div>
      </aside>

      {mobileOpen && (
        <button
          type="button"
          className="fixed inset-0 z-40 bg-black/50 backdrop-blur-sm lg:hidden"
          aria-label="Close menu"
          onClick={() => setMobileOpen(false)}
        />
      )}

      <div
        className={cn(
          'flex min-w-0 flex-1 flex-col transition-[margin] duration-200',
          collapsed ? 'lg:ml-[4.5rem]' : 'lg:ml-64'
        )}
      >
        <header className="sticky top-0 z-20 flex h-14 shrink-0 items-center gap-2 border-b border-black/[0.04] bg-card/95 px-3 backdrop-blur-xl supports-[backdrop-filter]:bg-card/80 dark:border-white/[0.06] sm:h-16 sm:gap-3 sm:px-4 md:px-6">
          <Button
            variant="ghost"
            size="icon"
            className="shrink-0 lg:hidden"
            onClick={() => setMobileOpen(true)}
            aria-label="Open menu"
          >
            <Menu className="size-5" />
          </Button>
          <div className="min-w-0 flex-1 overflow-hidden">
            <p className="truncate text-sm font-semibold tracking-tight md:text-base">{title}</p>
            <p className="hidden truncate text-xs text-muted-foreground sm:block">Manage operations in real time</p>
          </div>
          <div className="flex shrink-0 items-center gap-1">
            <Button
              variant="ghost"
              size="icon"
              className="rounded-full text-muted-foreground"
              onClick={() => setTheme(theme === 'dark' ? 'light' : 'dark')}
              aria-label="Toggle theme"
            >
              <Sun className="size-4 dark:hidden" />
              <Moon className="hidden size-4 dark:inline" />
            </Button>

            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <button
                  type="button"
                  className="flex items-center gap-1.5 rounded-full bg-muted/50 py-1 pl-1 pr-1.5 outline-none ring-offset-background transition hover:bg-muted focus-visible:ring-2 focus-visible:ring-ring sm:gap-2 sm:pr-2.5"
                >
                  <div className="flex size-7 items-center justify-center rounded-full bg-primary text-[10px] font-bold text-primary-foreground">
                    {initials(user?.firstName, user?.lastName)}
                  </div>
                  <span className="hidden max-w-[8rem] truncate text-xs font-medium md:inline">
                    {user?.firstName} {user?.lastName}
                  </span>
                  <ChevronDown className="size-3.5 text-muted-foreground" />
                </button>
              </DropdownMenuTrigger>
              <DropdownMenuContent align="end" className="w-56">
                <DropdownMenuLabel>
                  <p className="truncate text-sm font-semibold text-foreground">
                    {user?.firstName} {user?.lastName}
                  </p>
                  <p className="truncate font-normal">{user?.phone}</p>
                </DropdownMenuLabel>
                <DropdownMenuSeparator />
                <DropdownMenuItem onSelect={() => setPasswordOpen(true)}>
                  <KeyRound className="size-4 opacity-70" />
                  Change password
                </DropdownMenuItem>
                {canSettings && (
                  <DropdownMenuItem onSelect={() => navigate('/settings')}>
                    <Settings className="size-4 opacity-70" />
                    Settings
                  </DropdownMenuItem>
                )}
                <DropdownMenuSeparator />
                <DropdownMenuItem
                  className="text-destructive focus:bg-destructive/10 focus:text-destructive"
                  onSelect={logout}
                >
                  <LogOut className="size-4 opacity-70" />
                  Log out
                </DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>
          </div>
        </header>
        <main className="min-h-0 min-w-0 flex-1 overflow-x-hidden px-3 py-4 sm:px-4 sm:py-6 md:px-7 md:py-7">
          <Outlet />
        </main>
      </div>

      <ChangePasswordDialog open={passwordOpen} onOpenChange={setPasswordOpen} />
    </div>
  );
}
