import twilio from 'twilio';
import { SmsProvider, SmsResult } from './types';
import { twilioConfig } from '../../config/providers';

export class TwilioSmsProvider implements SmsProvider {
  private client = twilio(twilioConfig.accountSid, twilioConfig.authToken);

  async sendOtp(phone: string, otp: string): Promise<SmsResult> {
    try {
      const message = await this.client.messages.create({
        body: `Your RepairBooking verification code is: ${otp}. Valid for 10 minutes.`,
        from: twilioConfig.fromNumber,
        to: phone,
      });
      return { success: true, messageId: message.sid };
    } catch (err: any) {
      console.error('[Twilio SMS] Error:', err.message);
      return { success: false, error: err.message };
    }
  }
}
