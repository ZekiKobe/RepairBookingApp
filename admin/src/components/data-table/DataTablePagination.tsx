import { ChevronLeft, ChevronRight, ChevronsLeft, ChevronsRight } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { formatListRange } from '@/lib/format';
import { cn } from '@/lib/utils';
import type { PaginatedMeta } from './types';

const DEFAULT_PAGE_SIZES = [10, 20, 50];

function pageItems(page: number, pages: number): (number | 'ellipsis')[] {
  if (pages <= 1) return pages === 1 ? [1] : [];
  if (pages <= 7) return Array.from({ length: pages }, (_, i) => i + 1);

  const items: (number | 'ellipsis')[] = [1];
  const start = Math.max(2, page - 1);
  const end = Math.min(pages - 1, page + 1);

  if (start > 2) items.push('ellipsis');
  for (let p = start; p <= end; p++) items.push(p);
  if (end < pages - 1) items.push('ellipsis');
  items.push(pages);
  return items;
}

type Props = PaginatedMeta;

export function DataTablePagination({
  page,
  pageSize,
  total,
  pages,
  onPageChange,
  onPageSizeChange,
  pageSizeOptions = DEFAULT_PAGE_SIZES,
  isLoading,
}: Props) {
  const safePages = Math.max(1, pages || 1);
  const { from, to } = formatListRange(page, pageSize, total);
  const items = pageItems(page, safePages);

  return (
    <footer className="flex flex-col gap-3 border-t border-black/[0.05] bg-muted/30 px-4 py-3 sm:flex-row sm:items-center sm:justify-between sm:px-5 dark:border-white/[0.06] dark:bg-muted/15">
      <div className="flex flex-wrap items-center gap-x-4 gap-y-2 text-[13px] text-muted-foreground">
        <span>
          {total === 0 ? (
            'No results'
          ) : (
            <>
              Showing <span className="font-medium text-foreground">{from}</span>–<span className="font-medium text-foreground">{to}</span> of{' '}
              <span className="font-medium text-foreground">{total}</span>
            </>
          )}
        </span>
        <label className="flex items-center gap-2">
          <span className="sr-only">Rows per page</span>
          <span className="hidden sm:inline">Rows</span>
          <select
            className="h-8 rounded-md border border-input bg-background px-2 text-[13px] font-medium text-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring disabled:opacity-50"
            value={pageSize}
            disabled={isLoading}
            onChange={(e) => onPageSizeChange(Number(e.target.value))}
          >
            {pageSizeOptions.map((n) => (
              <option key={n} value={n}>
                {n}
              </option>
            ))}
          </select>
        </label>
      </div>

      <nav className="flex flex-wrap items-center gap-0.5" aria-label="Table pagination">
        <Button
          variant="ghost"
          size="icon"
          className="size-8 shrink-0"
          disabled={page <= 1 || isLoading}
          onClick={() => onPageChange(1)}
          aria-label="First page"
        >
          <ChevronsLeft className="size-4" />
        </Button>
        <Button
          variant="ghost"
          size="icon"
          className="size-8 shrink-0"
          disabled={page <= 1 || isLoading}
          onClick={() => onPageChange(page - 1)}
          aria-label="Previous page"
        >
          <ChevronLeft className="size-4" />
        </Button>

        <div className="hidden items-center gap-0.5 sm:flex">
          {items.map((item, idx) =>
            item === 'ellipsis' ? (
              <span key={`e-${idx}`} className="px-1.5 text-muted-foreground">
                …
              </span>
            ) : (
              <Button
                key={item}
                variant={item === page ? 'secondary' : 'ghost'}
                size="icon"
                className={cn('size-8 min-w-8 font-medium tabular-nums', item === page && 'pointer-events-none bg-muted font-semibold')}
                disabled={isLoading}
                onClick={() => onPageChange(item)}
                aria-label={`Page ${item}`}
                aria-current={item === page ? 'page' : undefined}
              >
                {item}
              </Button>
            )
          )}
        </div>

        <span className="px-2 text-[13px] tabular-nums text-muted-foreground sm:hidden">
          {page} / {safePages}
        </span>

        <Button
          variant="ghost"
          size="icon"
          className="size-8 shrink-0"
          disabled={page >= safePages || isLoading || total === 0}
          onClick={() => onPageChange(page + 1)}
          aria-label="Next page"
        >
          <ChevronRight className="size-4" />
        </Button>
        <Button
          variant="ghost"
          size="icon"
          className="size-8 shrink-0"
          disabled={page >= safePages || isLoading || total === 0}
          onClick={() => onPageChange(safePages)}
          aria-label="Last page"
        >
          <ChevronsRight className="size-4" />
        </Button>
      </nav>
    </footer>
  );
}
