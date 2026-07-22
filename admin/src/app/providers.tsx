import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { ThemeProvider } from 'next-themes';
import { useState } from 'react';
import { RouterProvider } from 'react-router-dom';
import { Toaster } from 'sonner';
import { createQueryClientConfig } from '@/lib/queryClient';
import { createAppRouter } from '@/app/router';

export function AppProviders() {
  const [client] = useState(() => new QueryClient(createQueryClientConfig()));
  const [router] = useState(() => createAppRouter());
  return (
    <QueryClientProvider client={client}>
      <ThemeProvider attribute="class" defaultTheme="light" enableSystem disableTransitionOnChange>
        <RouterProvider router={router} />
        <Toaster richColors closeButton />
      </ThemeProvider>
    </QueryClientProvider>
  );
}
