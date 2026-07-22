import { Request, Response, NextFunction } from 'express';
import crypto from 'crypto';
import { AuthRequest } from '../middleware/auth';
import Booking from '../models/Booking';
import User from '../models/User';
import { getPaymentProvider } from '../services/payment';
import { createNotification } from '../services/notification.service';
import { sendPushToUser } from '../services/push';
import { providers, chapaConfig } from '../config/providers';
<<<<<<< HEAD
import { appendLedgerEntry } from '../services/ledger.service';
import { appendAuditLog } from '../services/audit.service';
=======
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739

/**
 * POST /api/payments/intent
 * Initiates a payment — returns a checkoutUrl to open in the app.
 */
export const createPaymentIntent = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { bookingId } = req.body;

    const booking = await Booking.findOne({ _id: bookingId, user: req.user!._id })
      .populate('user', 'firstName lastName email phone');
    if (!booking) {
      res.status(404).json({ success: false, message: 'Booking not found' });
      return;
    }

    if (booking.paymentStatus === 'paid') {
      res.status(400).json({ success: false, message: 'Booking is already paid' });
      return;
    }

    const customer = booking.user as any;
    const result = await getPaymentProvider().initiate({
      bookingId: booking._id.toString(),
      amount: booking.price,
      currency: 'ETB',
      customerEmail: customer?.email,
      customerPhone: customer?.phone,
      customerName: customer ? `${customer.firstName} ${customer.lastName}` : undefined,
      description: `Repair booking #${booking._id.toString().slice(-6).toUpperCase()}`,
    });

    // Store txRef on booking for webhook reconciliation
    booking.paymentIntentId = result.txRef;
    await booking.save();

    res.json({
      success: true,
      data: {
        checkoutUrl: result.checkoutUrl,
        txRef: result.txRef,
        provider: result.provider,
        amount: booking.price,
        currency: 'ETB',
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * POST /api/payments/confirm
 * Called by the Flutter app after returning from checkout, or directly in mock mode.
 */
export const confirmPayment = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { bookingId, txRef } = req.body;

    const booking = await Booking.findOne({ _id: bookingId, user: req.user!._id });
    if (!booking) {
      res.status(404).json({ success: false, message: 'Booking not found' });
      return;
    }

    // Verify with the payment provider
    const verifyRef = txRef || booking.paymentIntentId || '';
    const result = await getPaymentProvider().verify(verifyRef);

    if (result.status === 'paid') {
<<<<<<< HEAD
      const wasUnpaid = booking.paymentStatus !== 'paid';
=======
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
      booking.paymentStatus = 'paid';
      booking.paymentIntentId = verifyRef;
      await booking.save();

<<<<<<< HEAD
      if (wasUnpaid) {
        try {
          await appendLedgerEntry({
            type: 'payment',
            amount: booking.price,
            currency: 'ETB',
            bookingId: booking._id.toString(),
            userId: booking.user.toString(),
            technicianId: booking.technician.toString(),
            description: `Payment confirmed for booking ${booking._id}`,
            externalRef: verifyRef,
          });
        } catch (_) {}
      }

=======
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
      // Notify technician
      try {
        const Technician = (await import('../models/Technician')).default;
        const tech = await Technician.findById(booking.technician).select('user');
        if (tech) {
          const techUserId = tech.user.toString();
          await createNotification({ userId: techUserId, type: 'payment_received', title: 'Payment Received', body: `Payment of ETB ${booking.price} has been confirmed.`, bookingId: booking._id.toString() });
          await sendPushToUser(techUserId, 'Payment Received', `ETB ${booking.price} payment confirmed for booking #${booking._id.toString().slice(-6).toUpperCase()}.`);
        }
      } catch (_) {}

      res.json({ success: true, message: 'Payment confirmed successfully', data: { paymentStatus: 'paid', booking } });
    } else if (result.status === 'pending') {
      res.json({ success: false, message: 'Payment is still pending', data: { paymentStatus: 'pending' } });
    } else {
      booking.paymentStatus = 'failed';
      await booking.save();
      res.status(400).json({ success: false, message: 'Payment failed or was rejected', data: { paymentStatus: 'failed' } });
    }
  } catch (error) {
    next(error);
  }
};

/**
 * GET /api/payments/status/:bookingId
 */
export const getPaymentStatus = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { bookingId } = req.params;
    const booking = await Booking.findOne({ _id: bookingId, user: req.user!._id });
    if (!booking) {
      res.status(404).json({ success: false, message: 'Booking not found' });
      return;
    }
    res.json({
      success: true,
      data: {
        paymentStatus: booking.paymentStatus,
        amount: booking.price,
        paymentMethod: booking.paymentMethod,
        provider: providers.payment,
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * POST /api/payments/webhook
 * Receives callbacks from Chapa / Telebirr to auto-confirm payment.
 */
export const paymentWebhook = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    // Chapa webhook verification
    if (providers.payment === 'chapa') {
      const signature = req.headers['x-chapa-signature'] as string;
      if (chapaConfig.webhookSecret && signature) {
        const expected = crypto.createHmac('sha256', chapaConfig.webhookSecret)
          .update(JSON.stringify(req.body)).digest('hex');
        if (signature !== expected) {
          res.status(401).json({ success: false, message: 'Invalid webhook signature' });
          return;
        }
      }
    }

    const txRef: string = req.body.tx_ref || req.body.out_trade_no || '';
    const eventStatus: string = req.body.status || req.body.trade_status || '';

    const isPaid = eventStatus === 'success' || eventStatus === 'TRADE_SUCCESS';
    if (!isPaid || !txRef) {
      res.json({ success: true, message: 'Webhook received, no action needed' });
      return;
    }

    // Find booking by stored txRef
    const booking = await Booking.findOne({ paymentIntentId: txRef });
    if (!booking) {
      res.json({ success: true, message: 'Booking not found for txRef' });
      return;
    }

    if (booking.paymentStatus !== 'paid') {
      booking.paymentStatus = 'paid';
      await booking.save();

<<<<<<< HEAD
      try {
        await appendLedgerEntry({
          type: 'payment',
          amount: booking.price,
          currency: 'ETB',
          bookingId: booking._id.toString(),
          userId: booking.user.toString(),
          technicianId: booking.technician.toString(),
          description: `Payment confirmed via webhook for booking ${booking._id}`,
          externalRef: txRef,
        });
      } catch (_) {}

=======
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
      const userId = booking.user.toString();
      await createNotification({ userId, type: 'payment_received', title: 'Payment Confirmed', body: `Your payment of ETB ${booking.price} has been confirmed.`, bookingId: booking._id.toString() });
      await sendPushToUser(userId, 'Payment Confirmed', `Your payment of ETB ${booking.price} was successful.`);
    }

    res.json({ success: true, message: 'Webhook processed' });
  } catch (error) {
    next(error);
  }
};
<<<<<<< HEAD

/**
 * POST /api/payments/refund  (admin) — marks booking refunded and records ledger entry.
 */
export const refundPayment = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { bookingId } = req.body;
    if (!bookingId) {
      res.status(400).json({ success: false, message: 'bookingId is required' });
      return;
    }

    const booking = await Booking.findById(bookingId);
    if (!booking) {
      res.status(404).json({ success: false, message: 'Booking not found' });
      return;
    }
    if (booking.paymentStatus !== 'paid') {
      res.status(400).json({ success: false, message: 'Only paid bookings can be refunded' });
      return;
    }

    const provider = getPaymentProvider();
    const txRef = booking.paymentIntentId || '';
    if (typeof provider.refund === 'function') {
      const r = await provider.refund({ txRef, amount: booking.price, currency: 'ETB' });
      if (r.status !== 'refunded') {
        res.status(502).json({ success: false, message: r.message || 'Provider refused refund' });
        return;
      }
    }

    booking.paymentStatus = 'refunded';
    await booking.save();

    try {
      await appendLedgerEntry({
        type: 'refund',
        amount: booking.price,
        currency: 'ETB',
        bookingId: booking._id.toString(),
        userId: booking.user.toString(),
        technicianId: booking.technician.toString(),
        description: `Refund for booking ${booking._id}`,
        externalRef: txRef,
      });
    } catch (_) {}

    try {
      await appendAuditLog({
        req,
        actorUserId: req.user!._id.toString(),
        action: 'payment.refund',
        targetType: 'booking',
        targetId: booking._id.toString(),
        metadata: { amount: booking.price },
      });
    } catch (_) {}

    res.json({
      success: true,
      message: 'Refund recorded',
      data: { paymentStatus: booking.paymentStatus },
    });
  } catch (error) {
    next(error);
  }
};
=======
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
