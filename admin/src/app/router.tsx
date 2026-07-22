import { createBrowserRouter, Outlet } from 'react-router-dom';
import { RequireAuth } from '@/app/guards/RequireAuth';
import { AuthEvents } from '@/app/AuthEvents';
import AuthLayout from '@/layouts/AuthLayout';
import AppShell from '@/layouts/AppShell';
import LoginPage from '@/pages/LoginPage';
import DashboardPage from '@/pages/DashboardPage';
import BookingsPage from '@/pages/BookingsPage';
import BookingDetailPage from '@/pages/BookingDetailPage';
import UsersPage from '@/pages/UsersPage';
import UserDetailPage from '@/pages/UserDetailPage';
import TechniciansPage from '@/pages/TechniciansPage';
import FinancePage from '@/pages/FinancePage';
import NotificationsPage from '@/pages/NotificationsPage';
import ReportsPage from '@/pages/ReportsPage';
import SettingsPage from '@/pages/SettingsPage';
import AuditPage from '@/pages/AuditPage';
import NotFoundPage from '@/pages/NotFoundPage';
import ForbiddenPage from '@/pages/ForbiddenPage';
import UnauthorizedPage from '@/pages/UnauthorizedPage';

function RootLayout() {
  return (
    <>
      <AuthEvents />
      <Outlet />
    </>
  );
}

export function createAppRouter() {
  return createBrowserRouter([
    {
      element: <RootLayout />,
      children: [
        {
          path: '/login',
          element: <AuthLayout />,
          children: [{ index: true, element: <LoginPage /> }],
        },
        {
          path: '/unauthorized',
          element: <UnauthorizedPage />,
        },
        {
          path: '/forbidden',
          element: <ForbiddenPage />,
        },
        {
          path: '/',
          element: <RequireAuth />,
          children: [
            {
              element: <AppShell />,
              children: [
                { index: true, element: <DashboardPage /> },
                { path: 'bookings', element: <BookingsPage /> },
                { path: 'bookings/:id', element: <BookingDetailPage /> },
                { path: 'users', element: <UsersPage /> },
                { path: 'users/:id', element: <UserDetailPage /> },
                { path: 'technicians', element: <TechniciansPage /> },
                { path: 'finance', element: <FinancePage /> },
                { path: 'notifications', element: <NotificationsPage /> },
                { path: 'reports', element: <ReportsPage /> },
                { path: 'settings', element: <SettingsPage /> },
                { path: 'audit', element: <AuditPage /> },
              ],
            },
          ],
        },
        { path: '*', element: <NotFoundPage /> },
      ],
    },
  ]);
}
