import mongoose, { Schema, Document } from 'mongoose';

export interface IConsentLog extends Document {
  user: mongoose.Types.ObjectId;
  marketing: boolean;
  analytics: boolean;
  location: boolean;
  policyVersion: string;
  createdAt: Date;
}

const ConsentLogSchema = new Schema<IConsentLog>(
  {
    user: { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    marketing: { type: Boolean, default: false },
    analytics: { type: Boolean, default: false },
    location: { type: Boolean, default: false },
    policyVersion: { type: String, required: true },
  },
  { timestamps: { createdAt: true, updatedAt: false } }
);

export default mongoose.model<IConsentLog>('ConsentLog', ConsentLogSchema);
