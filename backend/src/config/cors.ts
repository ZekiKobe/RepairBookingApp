import type { CorsOptions } from 'cors';

const LOCALHOST_ORIGIN = /^https?:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/;

function parseEnvOrigins(): string[] {
  const raw = process.env.CORS_ORIGINS?.trim();
  if (!raw) return [];
  return raw.split(',').map((o) => o.trim()).filter(Boolean);
}

const defaultDevOrigins = [
  'http://localhost:5173',
  'http://127.0.0.1:5173',
  'http://localhost:3000',
  'http://127.0.0.1:3000',
  'http://localhost:10912',
  'http://127.0.0.1:10912',
];

const defaultProdOrigins = ['https://admin.repairbooking.com'];

export function buildCorsOptions(): CorsOptions {
  const isProd = process.env.NODE_ENV === 'production';
  const envOrigins = parseEnvOrigins();
  const allowlist = envOrigins.length > 0 ? envOrigins : isProd ? defaultProdOrigins : defaultDevOrigins;

  return {
    origin(origin, callback) {
      // Same-origin tools, mobile apps, server-to-server
      if (!origin) {
        callback(null, true);
        return;
      }
      if (allowlist.includes(origin)) {
        callback(null, true);
        return;
      }
      // Dev: Flutter web, Vite, etc. often use random localhost ports
      if (!isProd && LOCALHOST_ORIGIN.test(origin)) {
        callback(null, true);
        return;
      }
      callback(null, false);
    },
    credentials: true,
    methods: ['GET', 'HEAD', 'PUT', 'PATCH', 'POST', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'X-Request-Id'],
  };
}
