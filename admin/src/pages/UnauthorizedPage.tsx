import { Link } from 'react-router-dom';

export default function UnauthorizedPage() {
  return (
    <div className="flex min-h-screen flex-col items-center justify-center gap-4 p-6 text-center">
      <h1 className="text-3xl font-semibold">401 Unauthorized</h1>
      <p className="text-muted-foreground">Please sign in to continue.</p>
      <Link to="/login" className="text-primary underline">
        Sign in
      </Link>
    </div>
  );
}
