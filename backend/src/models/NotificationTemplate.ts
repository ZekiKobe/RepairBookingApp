import mongoose, { Schema, Document } from 'mongoose';

export interface INotificationTemplate extends Document {
  name: string;
  title: string;
  body: string;
  channel: 'in_app' | 'email' | 'sms' | 'push';
  createdAt: Date;
  updatedAt: Date;
}

const NotificationTemplateSchema = new Schema<INotificationTemplate>(
  {
    name: { type: String, required: true, trim: true, unique: true },
    title: { type: String, required: true, maxlength: 200 },
    body: { type: String, required: true, maxlength: 4000 },
    channel: {
      type: String,
      enum: ['in_app', 'email', 'sms', 'push'],
      default: 'in_app',
    },
  },
  { timestamps: true }
);

export default mongoose.model<INotificationTemplate>('NotificationTemplate', NotificationTemplateSchema);
