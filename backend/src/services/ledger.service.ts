import LedgerEntry, { ILedgerEntry, LedgerType } from '../models/LedgerEntry';

export async function appendLedgerEntry(data: {
  type: LedgerType;
  amount: number;
  currency?: string;
  bookingId?: string;
  userId?: string;
  technicianId?: string;
  description?: string;
  externalRef?: string;
  metadata?: Record<string, unknown>;
}): Promise<ILedgerEntry> {
  return LedgerEntry.create({
    type: data.type,
    amount: data.amount,
    currency: data.currency ?? 'ETB',
    booking: data.bookingId,
    user: data.userId,
    technician: data.technicianId,
    description: data.description,
    externalRef: data.externalRef,
    metadata: data.metadata,
  });
}

export async function listLedgerForBooking(bookingId: string): Promise<ILedgerEntry[]> {
  return LedgerEntry.find({ booking: bookingId }).sort({ createdAt: -1 });
}

export async function listLedgerEntries(params: {
  page?: number;
  limit?: number;
  type?: LedgerType;
  bookingId?: string;
  from?: Date;
  to?: Date;
}): Promise<{ entries: ILedgerEntry[]; total: number; page: number; pages: number }> {
  const page = Math.max(1, params.page ?? 1);
  const limit = Math.min(100, Math.max(1, params.limit ?? 30));
  const filter: Record<string, unknown> = {};
  if (params.type) filter.type = params.type;
  if (params.bookingId) filter.booking = params.bookingId;
  if (params.from || params.to) {
    const range: Record<string, Date> = {};
    if (params.from) range.$gte = params.from;
    if (params.to) range.$lte = params.to;
    filter.createdAt = range;
  }
  const skip = (page - 1) * limit;
  const [entries, total] = await Promise.all([
    LedgerEntry.find(filter)
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit)
      .populate([
        { path: 'booking', select: 'status price paymentStatus' },
        { path: 'user', select: 'firstName lastName phone' },
        { path: 'technician', populate: { path: 'user', select: 'firstName lastName phone' } },
      ]),
    LedgerEntry.countDocuments(filter),
  ]);
  return { entries, total, page, pages: Math.ceil(total / limit) || 1 };
}
