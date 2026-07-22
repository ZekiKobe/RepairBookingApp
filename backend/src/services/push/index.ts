import { providers } from '../../config/providers';
import { PushProvider } from './types';
import { MockPushProvider } from './mock';
import { FcmPushProvider } from './fcm';

export { PushResult } from './types';

let _instance: PushProvider | null = null;

export function getPushProvider(): PushProvider {
  if (_instance) return _instance;
  switch (providers.push) {
    case 'fcm': _instance = new FcmPushProvider(); break;
    default:    _instance = new MockPushProvider(); break;
  }
  console.log(`[Push] Using provider: ${providers.push}`);
  return _instance;
}

/**
 * Helper: send a push to a user by looking up their FCM token.
 * Silently ignores if user has no token.
 */
export async function sendPushToUser(
  userId: string,
  title: string,
  body: string,
  data?: Record<string, string>
): Promise<void> {
  try {
    const User = (await import('../../models/User')).default;
    const user = await User.findById(userId).select('fcmToken');
    if (!user?.fcmToken) return;
    await getPushProvider().send({ fcmToken: user.fcmToken, title, body, data });
  } catch (err: any) {
    console.error('[Push] sendPushToUser error:', err.message);
  }
}
