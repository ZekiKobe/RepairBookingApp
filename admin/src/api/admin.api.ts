import { api } from '@/lib/axios';
import type { ApiResponse } from '@/types/api';

export async function fetchDashboard() {
  const { data } = await api.get<ApiResponse<unknown>>('/admin/dashboard');
  return data;
}

export async function fetchDashboardAnalytics(params: Record<string, string | undefined>) {
  const { data } = await api.get<ApiResponse<unknown>>('/admin/dashboard/analytics', { params });
  return data;
}

export async function fetchAuditLogs(params: Record<string, string | undefined>) {
  const { data } = await api.get<ApiResponse<unknown>>('/admin/audit-log', { params });
  return data;
}

export async function fetchAdminUsers(params: Record<string, string | undefined>) {
  const { data } = await api.get<ApiResponse<unknown>>('/admin/users', { params });
  return data;
}

export async function toggleUserActive(id: string) {
  const { data } = await api.put<ApiResponse<unknown>>(`/admin/users/${id}/toggle`);
  return data;
}

export async function fetchLedger(params: Record<string, string | undefined>) {
  const { data } = await api.get<ApiResponse<unknown>>('/admin/finance/ledger', { params });
  return data;
}

export async function fetchSettings() {
  const { data } = await api.get<ApiResponse<unknown>>('/admin/settings');
  return data;
}

export async function saveSettings(body: Record<string, unknown>) {
  const { data } = await api.put<ApiResponse<unknown>>('/admin/settings', body);
  return data;
}

export async function fetchNotificationTemplates() {
  const { data } = await api.get<ApiResponse<unknown>>('/admin/notification-templates');
  return data;
}

export async function createNotificationTemplate(body: { name: string; title: string; body: string; channel?: string }) {
  const { data } = await api.post<ApiResponse<unknown>>('/admin/notification-templates', body);
  return data;
}

export async function updateNotificationTemplate(
  id: string,
  body: Partial<{ name: string; title: string; body: string; channel: string }>
) {
  const { data } = await api.put<ApiResponse<unknown>>(`/admin/notification-templates/${id}`, body);
  return data;
}

export async function deleteNotificationTemplate(id: string) {
  const { data } = await api.delete<ApiResponse<unknown>>(`/admin/notification-templates/${id}`);
  return data;
}

export async function broadcastNotification(body: { title: string; body: string; audience?: string }) {
  const { data } = await api.post<ApiResponse<unknown>>('/admin/notifications/broadcast', body);
  return data;
}

export async function fetchTechnicianSuggestions(serviceId?: string) {
  const { data } = await api.get<ApiResponse<unknown>>('/admin/technicians/suggestions', {
    params: serviceId ? { serviceId } : {},
  });
  return data;
}
