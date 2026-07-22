import mongoose, { Schema, Document } from 'mongoose';

export interface IService extends Document {
  name: string;
  slug: string;
  description?: string;
  icon: string;
  category: string;
  isActive: boolean;
  estimatedDuration: number;
  basePrice: number;
  createdAt: Date;
  updatedAt: Date;
}

const ServiceSchema: Schema = new Schema({
  name: {
    type: String,
    required: [true, 'Service name is required'],
    trim: true,
    unique: true,
  },
  slug: {
    type: String,
    required: true,
    unique: true,
    lowercase: true,
  },
  description: {
    type: String,
    trim: true,
  },
  icon: {
    type: String,
    required: [true, 'Icon is required'],
    default: 'wrench',
  },
  category: {
    type: String,
    required: [true, 'Category is required'],
    enum: ['plumbing', 'electrical', 'cleaning', 'appliance_repair', 'other'],
  },
  isActive: {
    type: Boolean,
    default: true,
  },
  estimatedDuration: {
    type: Number,
    default: 60,
    comment: 'Estimated duration in minutes',
  },
  basePrice: {
    type: Number,
    default: 0,
    min: 0,
  },
}, {
  timestamps: true,
});

ServiceSchema.index({ category: 1, isActive: 1 });
ServiceSchema.index({ slug: 1 });

export default mongoose.model<IService>('Service', ServiceSchema);
