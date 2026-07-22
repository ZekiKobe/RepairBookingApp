import mongoose, { Schema, Document } from 'mongoose';

export interface IAuditLog extends Document {
  actorUser?: mongoose.Types.ObjectId;
  action: string;
  targetType?: string;
  targetId?: string;
  metadata?: Record<string, unknown>;
  requestId?: string;
  ip?: string;
  userAgent?: string;
  status?: 'success' | 'failure';
  createdAt: Date;
}

const AuditLogSchema = new Schema<IAuditLog>(
  {
    actorUser: { type: Schema.Types.ObjectId, ref: 'User', index: true },
    action: { type: String, required: true, index: true },
    targetType: { type: String },
    targetId: { type: String },
    metadata: { type: Schema.Types.Mixed },
    requestId: { type: String, index: true },
    ip: { type: String },
    userAgent: { type: String },
    status: { type: String, enum: ['success', 'failure'], default: 'success' },
  },
  { timestamps: { createdAt: true, updatedAt: false } }
);

export default mongoose.model<IAuditLog>('AuditLog', AuditLogSchema);
