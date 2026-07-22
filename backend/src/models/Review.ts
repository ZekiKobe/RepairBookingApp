import mongoose, { Schema, Document } from 'mongoose';

export interface IReview extends Document {
  booking: mongoose.Types.ObjectId;
  user: mongoose.Types.ObjectId;
  technician: mongoose.Types.ObjectId;
  rating: number;
  comment?: string;
  isVisible: boolean;
  createdAt: Date;
  updatedAt: Date;
}

const ReviewSchema: Schema = new Schema({
  booking: {
    type: Schema.Types.ObjectId,
    ref: 'Booking',
    required: true,
    unique: true,
  },
  user: {
    type: Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true,
  },
  technician: {
    type: Schema.Types.ObjectId,
    ref: 'Technician',
    required: true,
    index: true,
  },
  rating: {
    type: Number,
    required: true,
    min: 1,
    max: 5,
  },
  comment: {
    type: String,
    maxlength: [500, 'Review comment cannot exceed 500 characters'],
    trim: true,
  },
  isVisible: {
    type: Boolean,
    default: true,
  },
}, {
  timestamps: true,
});

// Index for technician reviews
ReviewSchema.index({ technician: 1, isVisible: 1, createdAt: -1 });
ReviewSchema.index({ user: 1, createdAt: -1 });

export default mongoose.model<IReview>('Review', ReviewSchema);
