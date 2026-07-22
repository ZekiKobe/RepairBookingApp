/**
 * Central provider configuration.
 * Switch providers by changing env vars — no code changes needed.
 *
 * PAYMENT_PROVIDER  = mock | chapa | telebirr   (default: mock)
 * SMS_PROVIDER      = mock | twilio | africas_talking  (default: mock)
 * PUSH_PROVIDER     = mock | fcm               (default: mock)
 * STORAGE_PROVIDER  = local | cloudinary       (default: local)
 */

export const providers = {
  payment:  (process.env.PAYMENT_PROVIDER  || 'mock') as 'mock' | 'chapa' | 'telebirr',
  sms:      (process.env.SMS_PROVIDER      || 'mock') as 'mock' | 'twilio' | 'africas_talking',
  push:     (process.env.PUSH_PROVIDER     || 'mock') as 'mock' | 'fcm',
  storage:  (process.env.STORAGE_PROVIDER  || 'local') as 'local' | 'cloudinary',
} as const;

export const chapaConfig = {
  secretKey:      process.env.CHAPA_SECRET_KEY      || '',
  webhookSecret:  process.env.CHAPA_WEBHOOK_SECRET  || '',
  baseUrl:        'https://api.chapa.co/v1',
  callbackUrl:    process.env.CHAPA_CALLBACK_URL    || 'http://localhost:5000/api/payments/webhook',
  returnUrl:      process.env.CHAPA_RETURN_URL      || 'repairbooking://payment-complete',
};

export const telebirrConfig = {
  appId:       process.env.TELEBIRR_APP_ID      || '',
  appKey:      process.env.TELEBIRR_APP_KEY     || '',
  shortCode:   process.env.TELEBIRR_SHORT_CODE  || '',
  publicKey:   process.env.TELEBIRR_PUBLIC_KEY  || '',
  notifyUrl:   process.env.TELEBIRR_NOTIFY_URL  || 'http://localhost:5000/api/payments/webhook',
  returnUrl:   process.env.TELEBIRR_RETURN_URL  || 'repairbooking://payment-complete',
};

export const twilioConfig = {
  accountSid:  process.env.TWILIO_ACCOUNT_SID  || '',
  authToken:   process.env.TWILIO_AUTH_TOKEN   || '',
  fromNumber:  process.env.TWILIO_FROM_NUMBER  || '',
};

export const atConfig = {
  apiKey:    process.env.AT_API_KEY    || '',
  username:  process.env.AT_USERNAME  || '',
  senderId:  process.env.AT_SENDER_ID || 'RepairApp',
};

export const fcmConfig = {
  projectId:    process.env.FCM_PROJECT_ID    || '',
  privateKey:   (process.env.FCM_PRIVATE_KEY  || '').replace(/\\n/g, '\n'),
  clientEmail:  process.env.FCM_CLIENT_EMAIL  || '',
};

export const cloudinaryConfig = {
  cloudName:  process.env.CLOUDINARY_CLOUD_NAME  || '',
  apiKey:     process.env.CLOUDINARY_API_KEY     || '',
  apiSecret:  process.env.CLOUDINARY_API_SECRET  || '',
};
