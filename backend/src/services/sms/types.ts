export interface SmsResult {
  success: boolean;
  messageId?: string;
  error?: string;
}

export interface SmsProvider {
  sendOtp(phone: string, otp: string): Promise<SmsResult>;
}
