<<<<<<< HEAD
import { PaymentProvider, PaymentInitResult, PaymentVerifyResult, RefundResult } from './types';
=======
import { PaymentProvider, PaymentInitResult, PaymentVerifyResult } from './types';
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739

export class MockPaymentProvider implements PaymentProvider {
  async initiate(params: {
    bookingId: string;
    amount: number;
    currency: string;
  }): Promise<PaymentInitResult> {
    const txRef = `mock_${params.bookingId}_${Date.now()}`;
    console.log(`[MOCK PAYMENT] Initiated: bookingId=${params.bookingId}, amount=${params.amount} ${params.currency}, txRef=${txRef}`);
    return {
      checkoutUrl: `repairbooking://mock-payment?txRef=${txRef}&amount=${params.amount}`,
      txRef,
      provider: 'mock',
    };
  }

  async verify(txRef: string): Promise<PaymentVerifyResult> {
    console.log(`[MOCK PAYMENT] Verified: txRef=${txRef} → paid`);
    return { status: 'paid', txRef };
  }
<<<<<<< HEAD

  async refund(params: { txRef: string; amount: number; currency?: string }): Promise<RefundResult> {
    console.log(`[MOCK PAYMENT] Refund: txRef=${params.txRef} amount=${params.amount}`);
    return { status: 'refunded', message: 'Mock refund processed' };
  }
=======
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
}
