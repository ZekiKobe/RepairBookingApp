export interface PushResult {
  success: boolean;
  messageId?: string;
  error?: string;
}

export interface PushProvider {
  send(params: {
    fcmToken: string;
    title: string;
    body: string;
    data?: Record<string, string>;
  }): Promise<PushResult>;
}
