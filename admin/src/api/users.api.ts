import { api } from '@/lib/axios';
import type { ApiResponse } from '@/types/api';

export async function searchUsers(params: Record<string, string | undefined>) {
  const { data } = await api.get<ApiResponse<unknown>>('/users', { params });
  return data;
}

export async function fetchUser(id: string) {
  const { data } = await api.get<ApiResponse<unknown>>(`/users/${id}`);
  return data;
}
