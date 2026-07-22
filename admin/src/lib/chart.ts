import type { CSSProperties } from 'react';

export const chartGrid = 'hsl(var(--muted-foreground) / 0.1)';

export const chartTooltipStyle: CSSProperties = {
  background: 'hsl(var(--popover))',
  border: '1px solid hsl(var(--border) / 0.8)',
  borderRadius: '0.75rem',
  boxShadow: '0 16px 40px -16px rgba(15, 23, 42, 0.28)',
  fontSize: '0.75rem',
  padding: '0.625rem 0.75rem',
};

export const chartColors = {
  primary: 'hsl(var(--chart-1))',
  secondary: 'hsl(var(--chart-2))',
  accent: 'hsl(var(--chart-3))',
  success: 'hsl(var(--chart-4))',
  muted: 'hsl(var(--chart-5))',
};

export const statusChartPalette = [
  'hsl(38 92% 50%)',
  'hsl(199 72% 42%)',
  'hsl(262 48% 52%)',
  'hsl(173 58% 32%)',
  'hsl(152 48% 38%)',
  'hsl(215 14% 55%)',
];

export const paymentChartPalette = [
  'hsl(152 48% 38%)',
  'hsl(38 92% 50%)',
  'hsl(0 72% 48%)',
  'hsl(199 72% 42%)',
  'hsl(215 14% 55%)',
];
