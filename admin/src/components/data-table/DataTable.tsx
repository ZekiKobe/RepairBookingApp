import type { ReactNode } from 'react';
import { Skeleton } from '@/components/ui/skeleton';
import { cn } from '@/lib/utils';
import { DataTablePagination } from './DataTablePagination';
import type { ColumnDef, PaginatedMeta } from './types';

type DataTableProps<T> = {
  columns: ColumnDef<T>[];
  data: T[];
  rowKey: (row: T) => string;
  isLoading?: boolean;
  minWidth?: string;
  emptyIcon?: ReactNode;
  emptyTitle?: string;
  emptyDescription?: string;
  pagination?: PaginatedMeta;
};

const alignClass = {
  left: 'text-left',
  center: 'text-center',
  right: 'text-right',
} as const;

export function DataTable<T>({
  columns,
  data,
  rowKey,
  isLoading,
  minWidth = '640px',
  emptyIcon,
  emptyTitle = 'No results',
  emptyDescription = 'Try adjusting filters or check back later.',
  pagination,
}: DataTableProps<T>) {
  const colCount = columns.length;
  const skeletonRows = pagination?.pageSize ?? 10;

  return (
    <div className="surface min-w-0 overflow-hidden">
      <div className="-mx-0 overflow-x-auto overscroll-x-contain">
        <table className="w-full border-collapse text-left text-sm" style={{ minWidth }}>
          <thead>
            <tr className="border-b border-black/[0.06] dark:border-white/[0.08]">
              {columns.map((col) => (
                <th
                  key={col.id}
                  className={cn(
                    'bg-muted/40 px-4 py-3 text-[11px] font-semibold uppercase tracking-[0.06em] text-muted-foreground first:pl-5 last:pr-5 dark:bg-white/[0.03]',
                    alignClass[col.align ?? 'left'],
                    col.headerClassName
                  )}
                >
                  {col.header}
                </th>
              ))}
            </tr>
          </thead>
          <tbody className="[&_tr:last-child]:border-0">
            {isLoading &&
              Array.from({ length: Math.min(skeletonRows, 8) }).map((_, i) => (
                <tr key={`sk-${i}`} className="border-b border-black/[0.04] dark:border-white/[0.05]">
                  {columns.map((col) => (
                    <td key={col.id} className="px-4 py-3.5 first:pl-5 last:pr-5">
                      <Skeleton className="h-4 w-full max-w-[11rem] rounded" />
                    </td>
                  ))}
                </tr>
              ))}

            {!isLoading && data.length === 0 && (
              <tr>
                <td colSpan={colCount} className="px-6 py-16">
                  <div className="flex flex-col items-center justify-center gap-2.5 text-center">
                    {emptyIcon && (
                      <div className="flex size-11 items-center justify-center rounded-xl bg-muted text-muted-foreground">
                        {emptyIcon}
                      </div>
                    )}
                    <p className="text-sm font-semibold text-foreground">{emptyTitle}</p>
                    <p className="max-w-sm text-sm text-muted-foreground">{emptyDescription}</p>
                  </div>
                </td>
              </tr>
            )}

            {!isLoading &&
              data.map((row) => (
                <tr
                  key={rowKey(row)}
                  className="border-b border-black/[0.04] transition-colors hover:bg-muted/40 dark:border-white/[0.05] dark:hover:bg-white/[0.03]"
                >
                  {columns.map((col) => (
                    <td
                      key={col.id}
                      className={cn(
                        'px-4 py-3.5 align-middle first:pl-5 last:pr-5',
                        alignClass[col.align ?? 'left'],
                        col.cellClassName
                      )}
                    >
                      {col.cell(row)}
                    </td>
                  ))}
                </tr>
              ))}
          </tbody>
        </table>
      </div>

      {pagination && <DataTablePagination {...pagination} isLoading={isLoading ?? pagination.isLoading} />}
    </div>
  );
}
