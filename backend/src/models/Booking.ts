import mongoose, { Schema, Document } from 'mongoose';

export type BookingStatus = 'pending' | 'accepted' | 'on_the_way' | 'in_progress' | 'completed' | 'cancelled';
export type PaymentStatus = 'pending' | 'paid' | 'failed' | 'refunded';

export interface IBooking extends Document {
  user: mongoose.Types.ObjectId;
  technician: mongoose.Types.ObjectId;
  service: mongoose.Types.ObjectId;
  status: BookingStatus;
  paymentStatus: PaymentStatus;
  scheduledDate: Date;
  scheduledTimeSlot: { start: string; end: string };
  description?: string;
  images?: string[];
  address: string;
  location?: {
    type: 'Point';
    coordinates: [number, number];
  };
  price: number;
  paymentMethod?: string;
  paymentIntentId?: string;
  notes?: string;
  cancellationReason?: string;
<<<<<<< HEAD
  cancelledBy?: 'user' | 'technician' | 'admin';
=======
  cancelledBy?: 'user' | 'technician';
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
  completedAt?: Date;
  createdAt: Date;
  updatedAt: Date;
}

const BookingSchema: Schema = new Schema({
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
  service: {
    type: Schema.Types.ObjectId,
    ref: 'Service',
    required: true,
  },
  status: {
    type: String,
    enum: ['pending', 'accepted', 'on_the_way', 'in_progress', 'completed', 'cancelled'],
    default: 'pending',
    index: true,
  },
  paymentStatus: {
    type: String,
    enum: ['pending', 'paid', 'failed', 'refunded'],
    default: 'pending',
  },
  scheduledDate: {
    type: Date,
    required: true,
  },
  scheduledTimeSlot: {
    start: { type: String, required: true },
    end: { type: String, required: true },
  },
  description: {
    type: String,
    maxlength: [1000, 'Description cannot exceed 1000 characters'],
  },
  images: [{
    type: String,
  }],
  address: {
    type: String,
    required: true,
  },
  location: {
    type: {
      type: String,
      enum: ['Point'],
    },
    coordinates: { type: [Number], default: undefined },
  },
  price: {
    type: Number,
    required: true,
    min: 0,
  },
  paymentMethod: {
    type: String,
    enum: ['cash', 'card', 'wallet'],
    default: 'cash',
  },
  paymentIntentId: {
    type: String,
  },
  notes: {
    type: String,
  },
  cancellationReason: {
    type: String,
  },
  cancelledBy: {
    type: String,
<<<<<<< HEAD
    enum: ['user', 'technician', 'admin'],
=======
    enum: ['user', 'technician'],
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
  },
  completedAt: {
    type: Date,
  },
}, {
  timestamps: true,
});

// Index for status queries
BookingSchema.index({ user: 1, status: 1, createdAt: -1 });
BookingSchema.index({ technician: 1, status: 1, createdAt: -1 });
BookingSchema.index({ status: 1, scheduledDate: 1 });
BookingSchema.index({ location: '2dsphere' });

export default mongoose.model<IBooking>('Booking', BookingSchema);
