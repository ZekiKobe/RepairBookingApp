import mongoose, { Schema, Document } from 'mongoose';

export type LedgerType = 'payment' | 'refund' | 'payout' | 'adjustment';

export interface ILedgerEntry extends Document {
  booking?: mongoose.Types.ObjectId;
  user?: mongoose.Types.ObjectId;
  technician?: mongoose.Types.ObjectId;
  type: LedgerType;
  amount: number;
  currency: string;
  description?: string;
  externalRef?: string;
  metadata?: Record<string, unknown>;
  createdAt: Date;
}

const LedgerEntrySchema = new Schema<ILedgerEntry>(
  {
    booking: { type: Schema.Types.ObjectId, ref: 'Booking', index: true },
    user: { type: Schema.Types.ObjectId, ref: 'User', index: true },
    technician: { type: Schema.Types.ObjectId, ref: 'Technician', index: true },
    type: {
      type: String,
      enum: ['payment', 'refund', 'payout', 'adjustment'],
      required: true,
      index: true,
    },
    amount: { type: Number, required: true },
    currency: { type: String, default: 'ETB' },
    description: { type: String, maxlength: 500 },
    externalRef: { type: String },
    metadata: { type: Schema.Types.Mixed },
  },
  { timestamps: { createdAt: true, updatedAt: false } }
);

export default mongoose.model<ILedgerEntry>('LedgerEntry', LedgerEntrySchema);
