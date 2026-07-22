import { api } from '@/lib/axios';
import type { ApiResponse, AuthTokens, AuthUser } from '@/types/api';

export async function loginAdmin(phone: string, password: string) {
  const { data } = await api.post<ApiResponse<{ user: AuthUser; tokens: AuthTokens }>>('/auth/login', {
    phone,
    password,
  });
  return data;
}

export async function fetchMe() {
  const { data } = await api.get<ApiResponse<{ user: AuthUser }>>('/auth/me');
  return data;
}

export async function changePassword(currentPassword: string, newPassword: string) {
  const { data } = await api.put<ApiResponse<unknown>>('/auth/change-password', {
    currentPassword,
    newPassword,
  });
  return data;
}
