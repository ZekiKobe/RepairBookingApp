import { Link } from 'react-router-dom';

export default function ForbiddenPage() {
  return (
    <div className="flex min-h-screen flex-col items-center justify-center gap-4 p-6 text-center">
      <h1 className="text-3xl font-semibold">403 Forbidden</h1>
      <p className="text-muted-foreground">You do not have permission to view this resource.</p>
      <Link to="/" className="text-primary underline">
        Dashboard
      </Link>
    </div>
  );
}
