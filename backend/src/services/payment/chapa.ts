import axios from 'axios';
import { PaymentProvider, PaymentInitResult, PaymentVerifyResult } from './types';
import { chapaConfig } from '../../config/providers';

export class ChapaPaymentProvider implements PaymentProvider {
  private readonly headers = {
    Authorization: `Bearer ${chapaConfig.secretKey}`,
    'Content-Type': 'application/json',
  };

  async initiate(params: {
    bookingId: string;
    amount: number;
    currency: string;
    customerEmail?: string;
    customerPhone?: string;
    customerName?: string;
    description?: string;
  }): Promise<PaymentInitResult> {
    const txRef = `chapa_${params.bookingId}_${Date.now()}`;
    const [firstName, ...rest] = (params.customerName || 'Customer').split(' ');
    const lastName = rest.join(' ') || 'User';

    const body = {
      amount: params.amount.toString(),
      currency: params.currency || 'ETB',
      email: params.customerEmail || 'customer@repairbooking.com',
      first_name: firstName,
      last_name: lastName,
      phone_number: params.customerPhone || '',
      tx_ref: txRef,
      callback_url: chapaConfig.callbackUrl,
      return_url: `${chapaConfig.returnUrl}?txRef=${txRef}`,
      customization: {
        title: 'Repair Booking Payment',
        description: params.description || 'Payment for repair service',
      },
    };

    const res = await axios.post(`${chapaConfig.baseUrl}/transaction/initialize`, body, {
      headers: this.headers,
    });

    if (res.data.status !== 'success') {
      throw new Error(`Chapa initiate failed: ${res.data.message}`);
    }

    return {
      checkoutUrl: res.data.data.checkout_url,
      txRef,
      provider: 'chapa',
    };
  }

  async verify(txRef: string): Promise<PaymentVerifyResult> {
    const res = await axios.get(`${chapaConfig.baseUrl}/transaction/verify/${txRef}`, {
      headers: this.headers,
    });

    const chapaStatus = res.data?.data?.status;
    const status: 'paid' | 'pending' | 'failed' =
      chapaStatus === 'success' ? 'paid' :
      chapaStatus === 'pending' ? 'pending' : 'failed';

    return {
      status,
      txRef,
      amount: parseFloat(res.data?.data?.amount || '0'),
    };
  }
}
