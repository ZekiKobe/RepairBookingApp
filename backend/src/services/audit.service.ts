import AuditLog, { IAuditLog } from '../models/AuditLog';
import { Request } from 'express';

export async function appendAuditLog(data: {
  req?: Request;
  actorUserId?: string;
  action: string;
  targetType?: string;
  targetId?: string;
  metadata?: Record<string, unknown>;
  ip?: string;
  userAgent?: string;
  status?: 'success' | 'failure';
}): Promise<IAuditLog> {
  const requestId = (data.req as { requestId?: string } | undefined)?.requestId;
  const forwarded = data.req?.headers['x-forwarded-for'];
  const ip =
    data.ip ??
    (typeof forwarded === 'string' ? forwarded.split(',')[0]?.trim() : undefined) ??
    data.req?.socket?.remoteAddress;
  const userAgent = data.userAgent ?? (data.req?.headers['user-agent'] as string | undefined);

  return AuditLog.create({
    actorUser: data.actorUserId,
    action: data.action,
    targetType: data.targetType,
    targetId: data.targetId,
    metadata: data.metadata,
    requestId,
    ip,
    userAgent,
    status: data.status ?? 'success',
  });
}

export async function listRecentAuditLogs(limit: number = 100): Promise<IAuditLog[]> {
  return AuditLog.find().sort({ createdAt: -1 }).limit(limit).populate('actorUser', 'phone role firstName lastName');
}

export async function listAuditLogsQuery(params: {
  page?: number;
  limit?: number;
  action?: string;
  targetType?: string;
  actorUserId?: string;
  from?: Date;
  to?: Date;
}): Promise<{ logs: IAuditLog[]; total: number; page: number; pages: number }> {
  const page = Math.max(1, params.page ?? 1);
  const limit = Math.min(200, Math.max(1, params.limit ?? 50));
  const filter: Record<string, unknown> = {};
  if (params.action) filter.action = params.action;
  if (params.targetType) filter.targetType = params.targetType;
  if (params.actorUserId) filter.actorUser = params.actorUserId;
  if (params.from || params.to) {
    const range: Record<string, Date> = {};
    if (params.from) range.$gte = params.from;
    if (params.to) range.$lte = params.to;
    filter.createdAt = range;
  }
  const skip = (page - 1) * limit;
  const [logs, total] = await Promise.all([
    AuditLog.find(filter)
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit)
      .populate('actorUser', 'phone role firstName lastName'),
    AuditLog.countDocuments(filter),
  ]);
  return { logs, total, page, pages: Math.ceil(total / limit) || 1 };
}
