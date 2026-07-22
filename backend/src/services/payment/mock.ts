import { PaymentProvider, PaymentInitResult, PaymentVerifyResult, RefundResult } from './types';

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

  async refund(params: { txRef: string; amount: number; currency?: string }): Promise<RefundResult> {
    console.log(`[MOCK PAYMENT] Refund: txRef=${params.txRef} amount=${params.amount}`);
    return { status: 'refunded', message: 'Mock refund processed' };
  }
}
