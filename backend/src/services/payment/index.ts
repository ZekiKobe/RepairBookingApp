import { providers } from '../../config/providers';
import { PaymentProvider } from './types';
import { MockPaymentProvider } from './mock';
import { ChapaPaymentProvider } from './chapa';
import { TelebirrPaymentProvider } from './telebirr';

export { PaymentInitResult, PaymentVerifyResult, RefundResult } from './types';

let _instance: PaymentProvider | null = null;

export function getPaymentProvider(): PaymentProvider {
  if (_instance) return _instance;
  switch (providers.payment) {
    case 'chapa':    _instance = new ChapaPaymentProvider(); break;
    case 'telebirr': _instance = new TelebirrPaymentProvider(); break;
    default:         _instance = new MockPaymentProvider(); break;
  }
  console.log(`[Payment] Using provider: ${providers.payment}`);
  return _instance;
}
