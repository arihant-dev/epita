import Link from "next/link";

export default function NotFound() {
  return (
    <main className="flex min-h-screen items-center justify-center p-6">
      <div className="outset-bevel bg-background p-1 w-full max-w-md">
        <div className="bg-secondary px-2 py-1 text-[11px] font-bold uppercase text-white">
          Route_Not_Found
        </div>
        <div className="space-y-4 bg-surface p-5">
          <div className="space-y-1">
            <h1 className="text-2xl font-black uppercase tracking-tight">
              404 // Missing Route
            </h1>
            <p className="text-xs leading-relaxed text-secondary">
              The requested page is not part of the current TaskFlow sprint scope.
            </p>
          </div>
          <Link
            href="/"
            className="inline-flex items-center gap-2 outset-bevel bg-background px-3 py-2 text-xs font-bold uppercase hover:text-tertiary"
          >
            <span aria-hidden="true">&lt;</span>
            Return to dashboard
          </Link>
        </div>
      </div>
    </main>
  );
}
