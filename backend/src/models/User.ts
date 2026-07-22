import mongoose, { Schema, Document } from 'mongoose';
import * as bcrypt from 'bcryptjs';
import type { AdminAppRole } from '../config/adminPermissions';

export interface ILocation {
  type: 'Point';
  coordinates: [number, number];
  address?: string;
}

export interface IUser extends Document {
  _id: mongoose.Types.ObjectId;
  phone: string;
  email?: string;
  password: string;
  role: 'user' | 'technician' | 'admin';
  /** Sub-role for platform administrators (ignored when role !== admin). */
  adminRole?: AdminAppRole;
  firstName: string;
  lastName: string;
  avatar?: string;
  location?: ILocation;
  isActive: boolean;
  isVerified: boolean;
  fcmToken?: string;
  googleUid?: string;
  createdAt: Date;
  updatedAt: Date;
  comparePassword(candidatePassword: string): Promise<boolean>;
}

const LocationSchema: Schema = new Schema({
  type: { type: String, enum: ['Point'], default: 'Point' },
  coordinates: { type: [Number], required: true },
  address: { type: String }
}, { _id: false });

const UserSchema: Schema = new Schema({
  phone: {
    type: String,
    required: [true, 'Phone number is required'],
    unique: true,
    trim: true,
  },
  email: {
    type: String,
    unique: true,
    sparse: true,
    lowercase: true,
    trim: true,
  },
  password: {
    type: String,
    required: [true, 'Password is required'],
    minlength: [6, 'Password must be at least 6 characters'],
    select: false,
  },
  role: {
    type: String,
    enum: ['user', 'technician', 'admin'],
    default: 'user',
  },
  adminRole: {
    type: String,
    enum: ['super_admin', 'operations', 'support', 'finance', 'technician_manager', 'read_only'],
    default: undefined,
  },
  firstName: {
    type: String,
    required: [true, 'First name is required'],
    trim: true,
  },
  lastName: {
    type: String,
    required: [true, 'Last name is required'],
    trim: true,
  },
  avatar: {
    type: String,
  },
  location: {
    type: LocationSchema,
  },
  isActive: {
    type: Boolean,
    default: true,
  },
  isVerified: {
    type: Boolean,
    default: false,
  },
  fcmToken: {
    type: String,
    select: false,
  },
  googleUid: {
    type: String,
    unique: true,
    sparse: true,
  },
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true },
});

// Index for geospatial queries
UserSchema.index({ location: '2dsphere' });

// Hash password before saving
UserSchema.pre<IUser & mongoose.Document>('save', async function() {
  if (!this.isModified('password')) return;
  
  const saltRounds = parseInt(process.env.BCRYPT_SALT_ROUNDS || '12', 10);
  this.password = await bcrypt.hash(this.password, saltRounds);
});

// Compare password method
UserSchema.methods.comparePassword = async function(candidatePassword: string): Promise<boolean> {
  return await bcrypt.compare(candidatePassword, this.password);
};

// Virtual for full name
UserSchema.virtual('fullName').get(function() {
  return `${this.firstName} ${this.lastName}`;
});

export default mongoose.model<IUser>('User', UserSchema);
