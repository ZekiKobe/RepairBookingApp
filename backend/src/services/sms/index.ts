import { providers } from '../../config/providers';
import { SmsProvider } from './types';
import { MockSmsProvider } from './mock';
import { TwilioSmsProvider } from './twilio';
import { AfricasTalkingSmsProvider } from './africas_talking';

export { SmsResult } from './types';

let _instance: SmsProvider | null = null;

export function getSmsProvider(): SmsProvider {
  if (_instance) return _instance;
  switch (providers.sms) {
    case 'twilio':           _instance = new TwilioSmsProvider(); break;
    case 'africas_talking':  _instance = new AfricasTalkingSmsProvider(); break;
    default:                 _instance = new MockSmsProvider(); break;
  }
  console.log(`[SMS] Using provider: ${providers.sms}`);
  return _instance;
}
