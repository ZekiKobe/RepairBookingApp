import mongoose, { Schema, Document } from 'mongoose';

export interface IServiceOffering {
  service: mongoose.Types.ObjectId;
  price: number;
  description?: string;
}

export interface IAvailability {
  day: string;
  slots: { start: string; end: string }[];
}

export interface ITechnician extends Document {
  user: mongoose.Types.ObjectId;
  bio?: string;
  services: IServiceOffering[];
  availability: IAvailability[];
  isAvailable: boolean;
  isApproved: boolean;
  /** When true, technician cannot be assigned new work. */
  isSuspended: boolean;
  approvalDate?: Date;
  rating: number;
  reviewCount: number;
  yearsOfExperience: number;
  idDocument?: string;
  certificationDocument?: string;
  totalEarnings: number;
  totalJobs: number;
  createdAt: Date;
  updatedAt: Date;
}

const ServiceOfferingSchema: Schema = new Schema({
  service: { type: Schema.Types.ObjectId, ref: 'Service', required: true },
  price: { type: Number, required: true, min: 0 },
  description: { type: String },
}, { _id: true });

const AvailabilitySlotSchema: Schema = new Schema({
  start: { type: String, required: true },
  end: { type: String, required: true },
}, { _id: false });

const AvailabilitySchema: Schema = new Schema({
  day: { 
    type: String, 
    enum: ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'],
    required: true 
  },
  slots: [AvailabilitySlotSchema],
}, { _id: false });

const TechnicianSchema: Schema = new Schema({
  user: {
    type: Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    unique: true,
  },
  bio: {
    type: String,
    maxlength: [500, 'Bio cannot exceed 500 characters'],
  },
  services: [ServiceOfferingSchema],
  availability: [AvailabilitySchema],
  isAvailable: {
    type: Boolean,
    default: true,
  },
  isApproved: {
    type: Boolean,
    default: false,
  },
  isSuspended: {
    type: Boolean,
    default: false,
    index: true,
  },
  approvalDate: {
    type: Date,
  },
  rating: {
    type: Number,
    default: 0,
    min: 0,
    max: 5,
  },
  reviewCount: {
    type: Number,
    default: 0,
  },
  yearsOfExperience: {
    type: Number,
    default: 0,
    min: 0,
  },
  idDocument: {
    type: String,
  },
  certificationDocument: {
    type: String,
  },
  totalEarnings: {
    type: Number,
    default: 0,
  },
  totalJobs: {
    type: Number,
    default: 0,
  },
}, {
  timestamps: true,
});

// Index for searching approved technicians
TechnicianSchema.index({ isApproved: 1, isAvailable: 1, rating: -1 });

export default mongoose.model<ITechnician>('Technician', TechnicianSchema);
