import { zodResolver } from '@hookform/resolvers/zod';
import { useForm } from 'react-hook-form';
import { useNavigate } from 'react-router-dom';
import { toast } from 'sonner';
import { z } from 'zod';
import { Lock, Phone } from 'lucide-react';
import { loginAdmin } from '@/api/auth.api';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { useAuthStore } from '@/state/authStore';

const schema = z.object({
  phone: z.string().min(5, 'Phone is required'),
  password: z.string().min(1, 'Password is required'),
});

type Form = z.infer<typeof schema>;

export default function LoginPage() {
  const navigate = useNavigate();
  const setSession = useAuthStore((s) => s.setSession);
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<Form>({ resolver: zodResolver(schema) });

  async function onSubmit(values: Form) {
    const res = await loginAdmin(values.phone, values.password);
    if (!res.success || !('data' in res)) {
      toast.error('message' in res ? res.message : 'Login failed');
      return;
    }
    if (res.data.user.role !== 'admin') {
      toast.error('This account is not an administrator.');
      return;
    }
    setSession(res.data.user, res.data.tokens);
    toast.success('Signed in');
    navigate('/', { replace: true });
  }

  return (
    <Card className="w-full max-w-[420px]">
      <CardHeader className="space-y-1.5 pb-2">
        <CardTitle className="text-xl font-bold">Sign in</CardTitle>
        <CardDescription>Enter your admin phone number and password to continue.</CardDescription>
      </CardHeader>
      <CardContent>
        <form className="space-y-4" onSubmit={handleSubmit(onSubmit)}>
          <div className="space-y-2">
            <Label htmlFor="phone">Phone</Label>
            <div className="relative">
              <Phone className="pointer-events-none absolute left-3 top-1/2 size-4 -translate-y-1/2 text-muted-foreground" />
              <Input id="phone" className="pl-9" autoComplete="username" placeholder="09xxxxxxxx" {...register('phone')} />
            </div>
            {errors.phone && <p className="text-sm text-destructive">{errors.phone.message}</p>}
          </div>
          <div className="space-y-2">
            <Label htmlFor="password">Password</Label>
            <div className="relative">
              <Lock className="pointer-events-none absolute left-3 top-1/2 size-4 -translate-y-1/2 text-muted-foreground" />
              <Input
                id="password"
                type="password"
                className="pl-9"
                autoComplete="current-password"
                placeholder="••••••••"
                {...register('password')}
              />
            </div>
            {errors.password && <p className="text-sm text-destructive">{errors.password.message}</p>}
          </div>
          <Button type="submit" className="mt-2 h-11 w-full rounded-xl text-sm font-semibold" disabled={isSubmitting}>
            {isSubmitting ? 'Signing in…' : 'Sign in to console'}
          </Button>
        </form>
      </CardContent>
    </Card>
  );
}
