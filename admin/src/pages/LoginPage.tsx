import { zodResolver } from '@hookform/resolvers/zod';
import { useForm } from 'react-hook-form';
import { useNavigate } from 'react-router-dom';
import { toast } from 'sonner';
import { z } from 'zod';
import { Lock, Phone } from 'lucide-react';
import { loginAdmin } from '@/api/auth.api';
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
    <div className="w-full max-w-[420px] rounded-2xl bg-white p-8 shadow-[0_12px_40px_-16px_rgba(15,23,42,0.18)] ring-1 ring-slate-900/5 sm:p-9">
      <div className="mb-7">
        <h1 className="text-2xl font-bold tracking-tight text-slate-900">Sign in</h1>
        <p className="mt-1.5 text-sm leading-relaxed text-slate-500">
          Enter your admin phone number and password to continue.
        </p>
      </div>

      <form className="space-y-5" onSubmit={handleSubmit(onSubmit)}>
        <div className="space-y-2">
          <label htmlFor="phone" className="block text-sm font-medium text-slate-700">
            Phone
          </label>
          <div className="relative">
            <Phone className="pointer-events-none absolute left-3.5 top-1/2 size-4 -translate-y-1/2 text-slate-400" />
            <input
              id="phone"
              autoComplete="username"
              placeholder="09xxxxxxxx"
              className="h-11 w-full rounded-xl border border-slate-200 bg-slate-50/80 pl-10 pr-3.5 text-sm text-slate-900 outline-none transition placeholder:text-slate-400 focus:border-teal-600 focus:bg-white focus:ring-4 focus:ring-teal-600/15"
              {...register('phone')}
            />
          </div>
          {errors.phone && <p className="text-sm text-red-600">{errors.phone.message}</p>}
        </div>

        <div className="space-y-2">
          <label htmlFor="password" className="block text-sm font-medium text-slate-700">
            Password
          </label>
          <div className="relative">
            <Lock className="pointer-events-none absolute left-3.5 top-1/2 size-4 -translate-y-1/2 text-slate-400" />
            <input
              id="password"
              type="password"
              autoComplete="current-password"
              placeholder="••••••••"
              className="h-11 w-full rounded-xl border border-slate-200 bg-slate-50/80 pl-10 pr-3.5 text-sm text-slate-900 outline-none transition placeholder:text-slate-400 focus:border-teal-600 focus:bg-white focus:ring-4 focus:ring-teal-600/15"
              {...register('password')}
            />
          </div>
          {errors.password && <p className="text-sm text-red-600">{errors.password.message}</p>}
        </div>

        <button
          type="submit"
          disabled={isSubmitting}
          className="mt-1 flex h-11 w-full items-center justify-center rounded-xl bg-teal-700 text-sm font-semibold text-white transition hover:bg-teal-800 focus-visible:outline-none focus-visible:ring-4 focus-visible:ring-teal-700/25 disabled:cursor-not-allowed disabled:opacity-60"
        >
          {isSubmitting ? 'Signing in…' : 'Sign in to console'}
        </button>
      </form>
    </div>
  );
}
