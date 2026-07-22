import mongoose, { Schema, Document } from 'mongoose';

export type OtpPurpose = 'password_reset';

export interface IOtpChallenge extends Document {
  phone: string;
  otp: string;
  purpose: OtpPurpose;
  expiresAt: Date;
}

const OtpChallengeSchema = new Schema<IOtpChallenge>(
  {
    phone: { type: String, required: true, index: true },
    otp: { type: String, required: true },
    purpose: {
      type: String,
      enum: ['password_reset'],
      default: 'password_reset',
      index: true,
    },
    expiresAt: { type: Date, required: true },
  },
  { timestamps: true }
);

OtpChallengeSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 });

export default mongoose.model<IOtpChallenge>('OtpChallenge', OtpChallengeSchema);
