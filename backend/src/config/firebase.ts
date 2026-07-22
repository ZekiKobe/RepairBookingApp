import * as admin from 'firebase-admin';
import { fcmConfig } from './providers';

let _initialized = false;

/**
 * Initializes Firebase Admin SDK once.
 * Required for both FCM push notifications and Google ID-token verification.
 * Set FCM_PROJECT_ID, FCM_PRIVATE_KEY, FCM_CLIENT_EMAIL in .env to enable.
 */
export function initFirebase(): void {
  if (_initialized || admin.apps.length > 0) {
    _initialized = true;
    return;
  }
  if (!fcmConfig.projectId || !fcmConfig.privateKey || !fcmConfig.clientEmail) {
    console.warn('[Firebase] Credentials not set — Google Auth and FCM push will be unavailable.');
    return;
  }
  admin.initializeApp({
    credential: admin.credential.cert({
      projectId:   fcmConfig.projectId,
      privateKey:  fcmConfig.privateKey,
      clientEmail: fcmConfig.clientEmail,
    }),
  });
  _initialized = true;
  console.log('[Firebase] Admin SDK initialized.');
}

export function isFirebaseReady(): boolean {
  return admin.apps.length > 0;
}
