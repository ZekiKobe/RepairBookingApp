export type ApiSuccess<T> = { success: true; data: T; message?: string };
export type ApiErrorBody = { success: false; message: string };
export type ApiResponse<T> = ApiSuccess<T> | ApiErrorBody;

export type AuthUser = {
  id: string;
  phone: string;
  email?: string;
  firstName: string;
  lastName: string;
  role: string;
  avatar?: string;
  isVerified?: boolean;
  adminRole?: string;
  permissions?: string[];
};

export type AuthTokens = { accessToken: string; refreshToken: string };
