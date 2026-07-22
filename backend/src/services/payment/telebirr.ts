import axios from 'axios';
import crypto from 'crypto';
import { PaymentProvider, PaymentInitResult, PaymentVerifyResult, RefundResult } from './types';
import { telebirrConfig } from '../../config/providers';

// Telebirr Super App API (Ethio Telecom)
// Docs: https://developer.ethiotelecom.et/docs/SuperAppPayment
export class TelebirrPaymentProvider implements PaymentProvider {
  private sign(data: string): string {
    // Telebirr uses RSA PKCS1 signing with their public key
    const sign = crypto.createSign('SHA256');
    sign.update(data);
    return sign.sign(
      `-----BEGIN PUBLIC KEY-----\n${telebirrConfig.publicKey}\n-----END PUBLIC KEY-----`,
      'base64'
    );
  }

  async initiate(params: {
    bookingId: string;
    amount: number;
    currency: string;
    customerPhone?: string;
    description?: string;
  }): Promise<PaymentInitResult> {
    const outTradeNo = `TB_${params.bookingId}_${Date.now()}`;
    const timestamp = Math.floor(Date.now() / 1000).toString();

    const rawRequest = {
      appid: telebirrConfig.appId,
      merch_code: telebirrConfig.shortCode,
      nonce_str: crypto.randomBytes(8).toString('hex'),
      notify_url: telebirrConfig.notifyUrl,
      out_trade_no: outTradeNo,
      subject: params.description || 'Repair Service Payment',
      timeout_express: '30m',
      timestamp,
      total_amount: params.amount.toFixed(2),
      trade_type: 'InApp',
      return_url: `${telebirrConfig.returnUrl}?txRef=${outTradeNo}`,
      receiver_msisdn: params.customerPhone || '',
    };

    // Sort keys and build sign string
    const signStr = Object.keys(rawRequest)
      .sort()
      .map(k => `${k}=${(rawRequest as any)[k]}`)
      .join('&') + `&key=${telebirrConfig.appKey}`;

    const signature = crypto.createHmac('sha256', telebirrConfig.appKey)
      .update(signStr).digest('hex').toUpperCase();

    const res = await axios.post(
      'https://196.188.120.3:38443/apiaccess/payment/gateway/InAppPay',
      { ...rawRequest, sign: signature, sign_type: 'HMACSHA256' },
      { headers: { 'Content-Type': 'application/json' } }
    );

    if (res.data?.code !== '0') {
      throw new Error(`Telebirr initiate failed: ${res.data?.msg}`);
    }

    return {
      checkoutUrl: res.data?.biz_content?.toPayUrl || '',
      txRef: outTradeNo,
      provider: 'telebirr',
    };
  }

  async verify(txRef: string): Promise<PaymentVerifyResult> {
    const timestamp = Math.floor(Date.now() / 1000).toString();
    const signStr = `appid=${telebirrConfig.appId}&merch_code=${telebirrConfig.shortCode}&out_trade_no=${txRef}&timestamp=${timestamp}&key=${telebirrConfig.appKey}`;
    const signature = crypto.createHmac('sha256', telebirrConfig.appKey)
      .update(signStr).digest('hex').toUpperCase();

    const res = await axios.post(
      'https://196.188.120.3:38443/apiaccess/payment/gateway/QueryPayment',
      {
        appid: telebirrConfig.appId,
        merch_code: telebirrConfig.shortCode,
        out_trade_no: txRef,
        timestamp,
        sign: signature,
        sign_type: 'HMACSHA256',
      }
    );

    const tbStatus = res.data?.biz_content?.trade_status;
    const status: 'paid' | 'pending' | 'failed' =
      tbStatus === 'TRADE_SUCCESS' ? 'paid' :
      tbStatus === 'WAIT_BUYER_PAY' ? 'pending' : 'failed';

    return { status, txRef };
  }

  async refund(): Promise<RefundResult> {
    return { status: 'failed', message: 'Telebirr refund not implemented in this integration' };
  }
}
