<<<<<<< HEAD
import express, { Application, Request, Response, NextFunction } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import { buildCorsOptions } from './config/cors';
import compression from 'compression';
import dotenv from 'dotenv';
import path from 'path';

import { connectDB } from './config/database';
import { errorHandler } from './middleware/errorHandler';
import { requestIdMiddleware, structuredRequestLogger } from './middleware/requestContext';

import authRoutes from './routes/auth.routes';
import userRoutes from './routes/user.routes';
import technicianRoutes from './routes/technician.routes';
import serviceRoutes from './routes/service.routes';
import bookingRoutes from './routes/booking.routes';
import reviewRoutes from './routes/review.routes';
import adminRoutes from './routes/admin.routes';
import paymentRoutes from './routes/payment.routes';
import messageRoutes from './routes/message.routes';
import notificationRoutes from './routes/notification.routes';
import uploadRoutes from './routes/upload.routes';
import estimateRoutes from './routes/estimate.routes';
import disputeRoutes from './routes/dispute.routes';
import { initFirebase } from './config/firebase';
import http from 'http';
import { initSocketIO } from './socket';

dotenv.config();
initFirebase();

const app: Application = express();
const PORT = Number(process.env.PORT) || 5000;

// Connect to MongoDB
connectDB();

// Middleware
app.use(requestIdMiddleware);
app.use(structuredRequestLogger);
app.use(helmet());
app.use(cors(buildCorsOptions()));
app.use(compression());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Health check
app.get('/health', (req: Request, res: Response) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/technicians', technicianRoutes);
app.use('/api/services', serviceRoutes);
app.use('/api/bookings', bookingRoutes);
app.use('/api/reviews', reviewRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/payments', paymentRoutes);
app.use('/api/messages', messageRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/uploads', uploadRoutes);
app.use('/api/estimates', estimateRoutes);
app.use('/api/disputes', disputeRoutes);

// Serve locally uploaded files
app.use('/static', express.static(path.join(process.cwd(), 'uploads')));

// 404 handler
app.use((req: Request, res: Response) => {
  res.status(404).json({ success: false, message: 'Route not found' });
});

// Error handling - must be last and must have 4 params for Express to recognize it
app.use(errorHandler);

const httpServer = http.createServer(app);
initSocketIO(httpServer);

httpServer.listen(PORT, () => {
  console.log(`Server running on port ${PORT} in ${process.env.NODE_ENV} mode`);
});

export default app;
export { httpServer };
=======
import express, { Application, Request, Response, NextFunction } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import compression from 'compression';
import dotenv from 'dotenv';
import path from 'path';

import { connectDB } from './config/database';
import { errorHandler } from './middleware/errorHandler';

import authRoutes from './routes/auth.routes';
import userRoutes from './routes/user.routes';
import technicianRoutes from './routes/technician.routes';
import serviceRoutes from './routes/service.routes';
import bookingRoutes from './routes/booking.routes';
import reviewRoutes from './routes/review.routes';
import adminRoutes from './routes/admin.routes';
import paymentRoutes from './routes/payment.routes';
import messageRoutes from './routes/message.routes';
import notificationRoutes from './routes/notification.routes';
import uploadRoutes from './routes/upload.routes';

dotenv.config();

const app: Application = express();
const PORT = process.env.PORT || 5000;

// Connect to MongoDB
connectDB();

// Middleware
app.use(helmet());
app.use(cors({
  origin: process.env.NODE_ENV === 'production' 
    ? ['https://admin.repairbooking.com', 'http://localhost:3000'] 
    : '*',
  credentials: true
}));
app.use(morgan('dev'));
app.use(compression());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Health check
app.get('/health', (req: Request, res: Response) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/technicians', technicianRoutes);
app.use('/api/services', serviceRoutes);
app.use('/api/bookings', bookingRoutes);
app.use('/api/reviews', reviewRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/payments', paymentRoutes);
app.use('/api/messages', messageRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/uploads', uploadRoutes);

// Serve locally uploaded files
app.use('/static', express.static(path.join(process.cwd(), 'uploads')));

// 404 handler
app.use((req: Request, res: Response) => {
  res.status(404).json({ success: false, message: 'Route not found' });
});

// Error handling - must be last and must have 4 params for Express to recognize it
app.use(errorHandler);

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT} in ${process.env.NODE_ENV} mode`);
});

export default app;
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
