import { api } from '@/lib/axios';
import type { ApiResponse } from '@/types/api';

export async function fetchBookingsAdmin(params: Record<string, string | undefined>) {
  const { data } = await api.get<ApiResponse<unknown>>('/bookings/admin/all', { params });
  return data;
}

export async function fetchBookingStatsAdmin() {
  const { data } = await api.get<ApiResponse<unknown>>('/bookings/admin/statistics');
  return data;
}

export async function fetchBooking(id: string) {
  const { data } = await api.get<ApiResponse<unknown>>(`/bookings/${id}`);
  return data;
}

export async function updateBookingStatus(id: string, status: string, notes?: string) {
  const { data } = await api.put<ApiResponse<unknown>>(`/bookings/${id}/status`, { status, notes });
  return data;
}

export async function cancelBooking(id: string, reason?: string) {
  const { data } = await api.put<ApiResponse<unknown>>(`/bookings/${id}/cancel`, { reason });
  return data;
}

export async function fetchBookingInvoiceHtml(id: string) {
  const res = await api.get(`/bookings/${id}/invoice`, { responseType: 'blob' });
  return res.data as Blob;
}

export async function updateBookingNotesAdmin(id: string, notes: string) {
  const { data } = await api.put<ApiResponse<unknown>>(`/bookings/admin/${id}/notes`, { notes });
  return data;
}

export async function assignBookingTechnicianAdmin(id: string, technicianId: string) {
  const { data } = await api.put<ApiResponse<unknown>>(`/bookings/admin/${id}/technician`, { technicianId });
  return data;
}

export async function fetchBookingMessages(bookingId: string, page = '1') {
  const { data } = await api.get<ApiResponse<unknown>>(`/messages/booking/${bookingId}`, { params: { page } });
  return data;
}
