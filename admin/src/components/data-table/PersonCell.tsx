import { displayName, initials } from '@/lib/format';

type PersonCellProps = {
  firstName?: string;
  lastName?: string;
  subtitle?: string;
};

export function PersonCell({ firstName, lastName, subtitle }: PersonCellProps) {
  return (
    <div className="flex items-center gap-3">
      <span className="flex size-10 shrink-0 items-center justify-center rounded-xl bg-primary/10 text-sm font-semibold text-primary">
        {initials(firstName, lastName)}
      </span>
      <div className="min-w-0">
        <p className="font-medium text-foreground">{displayName(firstName, lastName)}</p>
        {subtitle && <p className="text-xs text-muted-foreground">{subtitle}</p>}
      </div>
    </div>
  );
}
