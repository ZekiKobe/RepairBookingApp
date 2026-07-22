import { PushProvider, PushResult } from './types';

export class MockPushProvider implements PushProvider {
  async send(params: { fcmToken: string; title: string; body: string; data?: Record<string, string> }): Promise<PushResult> {
    console.log(`[MOCK PUSH] → token=${params.fcmToken.substring(0, 20)}... title="${params.title}" body="${params.body}"`);
    return { success: true, messageId: `mock_push_${Date.now()}` };
  }
}
