import mongoose, { Schema, Document } from 'mongoose';

export type EstimateStatus = 'pending' | 'accepted' | 'rejected' | 'expired';

export interface IEstimate extends Document {
  user: mongoose.Types.ObjectId;
  technician: mongoose.Types.ObjectId;
  service: mongoose.Types.ObjectId;
  proposedAmount: number;
  notes?: string;
  photos?: string[];
  status: EstimateStatus;
  expiresAt?: Date;
  createdAt: Date;
  updatedAt: Date;
}

const EstimateSchema = new Schema<IEstimate>(
  {
    user: { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    technician: { type: Schema.Types.ObjectId, ref: 'Technician', required: true, index: true },
    service: { type: Schema.Types.ObjectId, ref: 'Service', required: true },
    proposedAmount: { type: Number, required: true, min: 0 },
    notes: { type: String, maxlength: 2000 },
    photos: [{ type: String }],
    status: {
      type: String,
      enum: ['pending', 'accepted', 'rejected', 'expired'],
      default: 'pending',
      index: true,
    },
    expiresAt: { type: Date },
  },
  { timestamps: true }
);

export default mongoose.model<IEstimate>('Estimate', EstimateSchema);
