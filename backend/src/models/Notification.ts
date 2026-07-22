import mongoose, { Schema, Document } from 'mongoose';

export type NotificationType =
  | 'booking_new'
  | 'booking_accepted'
  | 'booking_cancelled'
  | 'booking_in_progress'
  | 'booking_completed'
  | 'new_message'
  | 'review_received'
<<<<<<< HEAD
  | 'payment_received'
  | 'announcement';
=======
  | 'payment_received';
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739

export interface INotification extends Document {
  user: mongoose.Types.ObjectId;
  type: NotificationType;
  title: string;
  body: string;
  bookingId?: mongoose.Types.ObjectId;
  isRead: boolean;
  createdAt: Date;
}

const NotificationSchema = new Schema<INotification>(
  {
    user: { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    type: {
      type: String,
<<<<<<< HEAD
      enum: [
        'booking_new',
        'booking_accepted',
        'booking_cancelled',
        'booking_in_progress',
        'booking_completed',
        'new_message',
        'review_received',
        'payment_received',
        'announcement',
      ],
=======
      enum: ['booking_new','booking_accepted','booking_cancelled','booking_in_progress','booking_completed','new_message','review_received','payment_received'],
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
      required: true,
    },
    title: { type: String, required: true },
    body: { type: String, required: true },
    bookingId: { type: Schema.Types.ObjectId, ref: 'Booking' },
    isRead: { type: Boolean, default: false, index: true },
  },
  { timestamps: true }
);

export default mongoose.model<INotification>('Notification', NotificationSchema);
