import { api } from '@/lib/axios';
import type { ApiResponse } from '@/types/api';

export async function fetchTechnicians(params: Record<string, string | undefined>) {
  const { data } = await api.get<ApiResponse<unknown>>('/technicians', { params });
  return data;
}

export async function fetchTechnician(id: string) {
  const { data } = await api.get<ApiResponse<unknown>>(`/technicians/${id}`);
  return data;
}

export async function fetchPendingTechnicians(params: Record<string, string | undefined>) {
  const { data } = await api.get<ApiResponse<unknown>>('/technicians/pending', { params });
  return data;
}

export async function approveTechnician(id: string) {
  const { data } = await api.put<ApiResponse<unknown>>(`/technicians/${id}/approve`);
  return data;
}

export async function updateTechnician(id: string, body: Record<string, unknown>) {
  const { data } = await api.put<ApiResponse<unknown>>(`/technicians/${id}`, body);
  return data;
}

export async function setTechnicianSuspended(id: string, suspended: boolean) {
  const { data } = await api.put<ApiResponse<unknown>>(`/technicians/${id}/suspend`, { suspended });
  return data;
}
