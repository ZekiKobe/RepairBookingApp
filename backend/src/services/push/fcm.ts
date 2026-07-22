import * as admin from 'firebase-admin';
import { PushProvider, PushResult } from './types';
import { fcmConfig } from '../../config/providers';

let _initialized = false;

function initFcm() {
<<<<<<< HEAD
  if (_initialized || admin.apps.length > 0) { _initialized = true; return; }
  if (!fcmConfig.projectId || !fcmConfig.privateKey || !fcmConfig.clientEmail) {
    throw new Error('FCM config incomplete. Set FCM_PROJECT_ID, FCM_PRIVATE_KEY, FCM_CLIENT_EMAIL in .env');
=======
  if (_initialized) return;
  if (!fcmConfig.projectId || !fcmConfig.privateKey || !fcmConfig.clientEmail) {
    throw new Error('FCM config is incomplete. Set FCM_PROJECT_ID, FCM_PRIVATE_KEY, FCM_CLIENT_EMAIL in .env');
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
  }
  admin.initializeApp({
    credential: admin.credential.cert({
      projectId:   fcmConfig.projectId,
      privateKey:  fcmConfig.privateKey,
      clientEmail: fcmConfig.clientEmail,
    }),
  });
  _initialized = true;
}

export class FcmPushProvider implements PushProvider {
  constructor() {
    initFcm();
  }

  async send(params: {
    fcmToken: string;
    title: string;
    body: string;
    data?: Record<string, string>;
  }): Promise<PushResult> {
    try {
      const messageId = await admin.messaging().send({
        token: params.fcmToken,
        notification: { title: params.title, body: params.body },
        data: params.data,
        android: { priority: 'high', notification: { sound: 'default', channelId: 'default' } },
        apns: { payload: { aps: { sound: 'default', badge: 1 } } },
      });
      return { success: true, messageId };
    } catch (err: any) {
      console.error('[FCM] Error:', err.message);
      return { success: false, error: err.message };
    }
  }
}
