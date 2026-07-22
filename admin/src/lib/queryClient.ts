import type { QueryClientConfig } from '@tanstack/react-query';

export function createQueryClientConfig(): QueryClientConfig {
  return {
    defaultOptions: {
      queries: {
        staleTime: 30_000,
        retry: 1,
        refetchOnWindowFocus: false,
      },
    },
  };
}
