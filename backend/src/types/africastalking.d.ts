declare module 'africastalking' {
  interface AfricasTalkingOptions {
    apiKey: string;
    username: string;
  }

  interface SendOptions {
    to: string[];
    message: string;
    from?: string;
  }

  interface SMSService {
    send(opts: SendOptions): Promise<any>;
  }

  interface AfricasTalkingInstance {
    SMS: SMSService;
  }

  function AfricasTalking(opts: AfricasTalkingOptions): AfricasTalkingInstance;
  export = AfricasTalking;
}
