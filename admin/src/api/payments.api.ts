import { api } from '@/lib/axios';
import type { ApiResponse } from '@/types/api';

export async function refundPayment(body: { bookingId: string; amount?: number; reason?: string }) {
  const { data } = await api.post<ApiResponse<unknown>>('/payments/refund', body);
  return data;
}
