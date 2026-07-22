export interface PaymentInitResult {
  checkoutUrl: string;
  txRef: string;
  provider: string;
}

export interface PaymentVerifyResult {
  status: 'paid' | 'pending' | 'failed';
  txRef: string;
  amount?: number;
}

export interface RefundResult {
  status: 'refunded' | 'failed';
  message?: string;
}

export interface PaymentProvider {
  initiate(params: {
    bookingId: string;
    amount: number;
    currency: string;
    customerEmail?: string;
    customerPhone?: string;
    customerName?: string;
    description?: string;
  }): Promise<PaymentInitResult>;

  verify(txRef: string): Promise<PaymentVerifyResult>;

  /** Optional — real PSP integrations should implement refunds. */
  refund?(params: { txRef: string; amount: number; currency?: string }): Promise<RefundResult>;
}
