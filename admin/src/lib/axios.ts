import axios, { type AxiosError, type InternalAxiosRequestConfig } from 'axios';
import type { ApiResponse, AuthTokens } from '@/types/api';

const baseURL = import.meta.env.VITE_API_BASE_URL ?? '/api';

export const api = axios.create({
  baseURL,
  headers: { 'Content-Type': 'application/json' },
  timeout: 60_000,
});

let isRefreshing = false;
const failedQueue: Array<{
  resolve: (value: unknown) => void;
  reject: (reason?: unknown) => void;
  config: InternalAxiosRequestConfig;
}> = [];

function processQueue(error: unknown, token: string | null) {
  failedQueue.forEach(({ resolve, reject, config }) => {
    if (error || !token) {
      reject(error);
      return;
    }
    if (config.headers) config.headers.Authorization = `Bearer ${token}`;
    resolve(api(config));
  });
  failedQueue.length = 0;
}

export function getStoredTokens(): AuthTokens | null {
  try {
    const raw = sessionStorage.getItem('admin_auth');
    if (!raw) return null;
    return JSON.parse(raw) as AuthTokens;
  } catch {
    return null;
  }
}

export function setStoredTokens(tokens: AuthTokens | null) {
  if (!tokens) sessionStorage.removeItem('admin_auth');
  else sessionStorage.setItem('admin_auth', JSON.stringify(tokens));
}

async function refreshTokens(): Promise<string | null> {
  const stored = getStoredTokens();
  if (!stored?.refreshToken) return null;
  try {
    const res = await axios.post<ApiResponse<{ tokens: AuthTokens }>>(`${baseURL}/auth/refresh`, {
      refreshToken: stored.refreshToken,
    });
    const body = res.data;
    if (!body.success || !('data' in body)) return null;
    setStoredTokens(body.data.tokens);
    return body.data.tokens.accessToken;
  } catch {
    return null;
  }
}

api.interceptors.request.use((config: InternalAxiosRequestConfig) => {
  const t = getStoredTokens();
  if (t?.accessToken && config.headers) {
    config.headers.Authorization = `Bearer ${t.accessToken}`;
  }
  return config;
});

api.interceptors.response.use(
  (r) => r,
  async (error: AxiosError) => {
    const original = error.config as (InternalAxiosRequestConfig & { _retry?: boolean }) | undefined;
    if (!original) return Promise.reject(error);

    const url = original.url ?? '';
    const isAuthPath = url.includes('/auth/login') || url.includes('/auth/refresh');
    if (error.response?.status !== 401 || original._retry || isAuthPath) {
      return Promise.reject(error);
    }

    if (isRefreshing) {
      return new Promise((resolve, reject) => {
        failedQueue.push({ resolve, reject, config: original });
      });
    }

    original._retry = true;
    isRefreshing = true;
    try {
      const token = await refreshTokens();
      if (!token) {
        processQueue(new Error('Session expired'), null);
        setStoredTokens(null);
        window.dispatchEvent(new CustomEvent('admin:auth-expired'));
        return Promise.reject(error);
      }
      processQueue(null, token);
      if (original.headers) original.headers.Authorization = `Bearer ${token}`;
      return api(original);
    } catch (e) {
      processQueue(e, null);
      return Promise.reject(e);
    } finally {
      isRefreshing = false;
    }
  }
);
