import mongoose, { Schema, Document } from 'mongoose';

export type DisputeStatus = 'open' | 'under_review' | 'resolved' | 'dismissed';

export interface IDispute extends Document {
  booking: mongoose.Types.ObjectId;
  openedBy: mongoose.Types.ObjectId;
  reason: string;
  details?: string;
  status: DisputeStatus;
  resolution?: string;
  evidenceUrls?: string[];
  createdAt: Date;
  updatedAt: Date;
}

const DisputeSchema = new Schema<IDispute>(
  {
    booking: { type: Schema.Types.ObjectId, ref: 'Booking', required: true, index: true },
    openedBy: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    reason: { type: String, required: true, maxlength: 500 },
    details: { type: String, maxlength: 4000 },
    status: {
      type: String,
      enum: ['open', 'under_review', 'resolved', 'dismissed'],
      default: 'open',
      index: true,
    },
    resolution: { type: String, maxlength: 4000 },
    evidenceUrls: [{ type: String }],
  },
  { timestamps: true }
);

DisputeSchema.index({ booking: 1, status: 1 });

export default mongoose.model<IDispute>('Dispute', DisputeSchema);
