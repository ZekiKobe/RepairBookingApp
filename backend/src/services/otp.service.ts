import OtpChallenge from '../models/OtpChallenge';

const PURPOSE = 'password_reset' as const;

export async function savePasswordResetOtp(
  phone: string,
  otp: string,
  ttlMs: number
): Promise<void> {
  await OtpChallenge.deleteMany({ phone, purpose: PURPOSE });
  await OtpChallenge.create({
    phone,
    otp,
    purpose: PURPOSE,
    expiresAt: new Date(Date.now() + ttlMs),
  });
}

export async function isPasswordResetOtpValid(phone: string, otp: string): Promise<boolean> {
  const doc = await OtpChallenge.findOne({
    phone,
    purpose: PURPOSE,
    otp,
    expiresAt: { $gt: new Date() },
  }).lean();
  return !!doc;
}

export async function consumePasswordResetOtp(phone: string, otp: string): Promise<boolean> {
  const res = await OtpChallenge.deleteOne({
    phone,
    purpose: PURPOSE,
    otp,
    expiresAt: { $gt: new Date() },
  });
  return res.deletedCount > 0;
}
