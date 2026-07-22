import type { ReactNode } from 'react';

export type ColumnDef<T> = {
  id: string;
  header: ReactNode;
  headerClassName?: string;
  cellClassName?: string;
  align?: 'left' | 'center' | 'right';
  cell: (row: T) => ReactNode;
};

export type PaginatedMeta = {
  page: number;
  pageSize: number;
  total: number;
  pages: number;
  onPageChange: (page: number) => void;
  onPageSizeChange: (size: number) => void;
  pageSizeOptions?: number[];
  isLoading?: boolean;
};
