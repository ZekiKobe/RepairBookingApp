import type { Server as HttpServer } from 'http';
import { Server } from 'socket.io';
import jwt from 'jsonwebtoken';

let io: Server | null = null;

export function initSocketIO(httpServer: HttpServer): Server {
  io = new Server(httpServer, {
    cors: {
      origin: process.env.NODE_ENV === 'production' ? true : '*',
      methods: ['GET', 'POST'],
    },
  });

  io.use((socket, next) => {
    try {
      const token = socket.handshake.auth?.token as string | undefined;
      if (!token || !process.env.JWT_SECRET) {
        next(new Error('Unauthorized'));
        return;
      }
      const decoded = jwt.verify(token, process.env.JWT_SECRET) as { userId: string };
      (socket as unknown as { userId: string }).userId = decoded.userId;
      next();
    } catch {
      next(new Error('Unauthorized'));
    }
  });

  io.on('connection', (socket) => {
    socket.on('join_booking', (bookingId: string) => {
      if (typeof bookingId === 'string' && bookingId.length < 200) {
        socket.join(`booking:${bookingId}`);
      }
    });
    socket.on('leave_booking', (bookingId: string) => {
      if (typeof bookingId === 'string') {
        socket.leave(`booking:${bookingId}`);
      }
    });
  });

  return io;
}

export function emitBookingMessage(bookingId: string, payload: unknown): void {
  io?.to(`booking:${bookingId}`).emit('booking_message', payload);
}

export function getSocketIO(): Server | null {
  return io;
}
