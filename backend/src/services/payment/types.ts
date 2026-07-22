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

<<<<<<< HEAD
export interface RefundResult {
  status: 'refunded' | 'failed';
  message?: string;
}

=======
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
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
<<<<<<< HEAD

  /** Optional — real PSP integrations should implement refunds. */
  refund?(params: { txRef: string; amount: number; currency?: string }): Promise<RefundResult>;
=======
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
}
