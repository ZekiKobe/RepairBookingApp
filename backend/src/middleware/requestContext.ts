import { randomUUID } from 'crypto';
import { Request, Response, NextFunction } from 'express';

export function requestIdMiddleware(req: Request, res: Response, next: NextFunction): void {
  const id = (req.headers['x-request-id'] as string) || randomUUID();
  (req as Request & { requestId: string }).requestId = id;
  res.setHeader('X-Request-Id', id);
  next();
}

export function structuredRequestLogger(req: Request, res: Response, next: NextFunction): void {
  const start = Date.now();
  const rid = (req as Request & { requestId?: string }).requestId;
  res.on('finish', () => {
    const line = JSON.stringify({
      t: new Date().toISOString(),
      requestId: rid,
      method: req.method,
      path: req.originalUrl?.split('?')[0],
      status: res.statusCode,
      ms: Date.now() - start,
    });
    // eslint-disable-next-line no-console
    console.log(line);
  });
  next();
}
