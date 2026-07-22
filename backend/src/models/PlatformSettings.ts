import mongoose, { Schema, Document } from 'mongoose';

/** Single row platform configuration (sections are open-ended JSON). */
export interface IPlatformSettings extends Document {
  key: string;
  general: Record<string, unknown>;
  branding: Record<string, unknown>;
  booking: Record<string, unknown>;
  payments: Record<string, unknown>;
  tax: Record<string, unknown>;
  notifications: Record<string, unknown>;
  security: Record<string, unknown>;
  maintenance: Record<string, unknown>;
  mfa: Record<string, unknown>;
  updatedAt: Date;
}

const emptySection = { type: Schema.Types.Mixed, default: {} };

const PlatformSettingsSchema = new Schema<IPlatformSettings>(
  {
    key: { type: String, default: 'platform', unique: true, index: true },
    general: emptySection,
    branding: emptySection,
    booking: emptySection,
    payments: emptySection,
    tax: emptySection,
    notifications: emptySection,
    security: emptySection,
    maintenance: emptySection,
    mfa: emptySection,
  },
  { timestamps: { createdAt: false, updatedAt: true } }
);

export default mongoose.model<IPlatformSettings>('PlatformSettings', PlatformSettingsSchema);
