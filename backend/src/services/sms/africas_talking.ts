// eslint-disable-next-line @typescript-eslint/no-var-requires
const AfricasTalking: any = require('africastalking');
import { SmsProvider, SmsResult } from './types';
import { atConfig } from '../../config/providers';

export class AfricasTalkingSmsProvider implements SmsProvider {
  private sms: any;

  constructor() {
    const at = AfricasTalking({
      apiKey: atConfig.apiKey,
      username: atConfig.username,
    });
    this.sms = at.SMS;
  }

  async sendOtp(phone: string, otp: string): Promise<SmsResult> {
    try {
      const res = await this.sms.send({
        to: [phone],
        message: `Your RepairBooking verification code is: ${otp}. Valid for 10 minutes.`,
        from: atConfig.senderId,
      });
      const recipient = res.SMSMessageData?.Recipients?.[0];
      if (recipient?.status === 'Success') {
        return { success: true, messageId: recipient.messageId };
      }
      return { success: false, error: recipient?.status || 'Unknown error' };
    } catch (err: any) {
      console.error("[Africa's Talking SMS] Error:", err.message);
      return { success: false, error: err.message };
    }
  }
}
