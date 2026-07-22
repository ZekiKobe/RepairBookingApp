export function initials(first?: string, last?: string) {
  const a = (first?.[0] ?? '?').toUpperCase();
  const b = (last?.[0] ?? '').toUpperCase();
  return (a + b).slice(0, 2);
}

export function displayName(first?: string, last?: string) {
  const raw = `${first ?? ''} ${last ?? ''}`.trim();
  if (!raw) return '—';
  return raw.replace(/\S+/g, (w) => w.charAt(0).toUpperCase() + w.slice(1).toLowerCase());
}

export function formatListRange(page: number, pageSize: number, total: number) {
  if (total === 0) return { from: 0, to: 0 };
  const from = (page - 1) * pageSize + 1;
  const to = Math.min(page * pageSize, total);
  return { from, to };
}

export function formatMoney(value: number | string | null | undefined, currency = 'ETB') {
  const n = typeof value === 'string' ? Number(value) : (value ?? 0);
  if (!Number.isFinite(n)) return '—';
  try {
    return new Intl.NumberFormat(undefined, {
      style: 'currency',
      currency,
      maximumFractionDigits: n % 1 === 0 ? 0 : 2,
    }).format(n);
  } catch {
    return `${n.toLocaleString()} ${currency}`;
  }
}

export function formatCompact(value: number | null | undefined) {
  const n = value ?? 0;
  if (!Number.isFinite(n)) return '—';
  return new Intl.NumberFormat(undefined, { notation: 'compact', maximumFractionDigits: 1 }).format(n);
}

export function formatStatusLabel(status: string) {
  return status.replaceAll('_', ' ');
}
