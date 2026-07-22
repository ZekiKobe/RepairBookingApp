import { SmsProvider, SmsResult } from './types';

export class MockSmsProvider implements SmsProvider {
  async sendOtp(phone: string, otp: string): Promise<SmsResult> {
    console.log(`[MOCK SMS] OTP for ${phone}: ${otp}`);
    return { success: true, messageId: `mock_${Date.now()}` };
  }
}
