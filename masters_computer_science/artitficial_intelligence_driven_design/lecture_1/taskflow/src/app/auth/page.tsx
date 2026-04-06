import AuthForm from "@/components/AuthForm";

export default function AuthPage() {
  return (
    <div className="flex min-h-screen items-center justify-center p-8 bg-surface pattern-dots">
      <div className="space-y-6 flex flex-col items-center max-w-md w-full">
        <div className="text-center space-y-2 mb-4">
          <h1 className="text-4xl font-black uppercase tracking-tighter text-black drop-shadow-sm">
            TaskFlow v1.0
          </h1>
          <div className="text-[10px] font-bold text-secondary uppercase bg-white border-2 border-gray-400 px-3 py-1 inline-block outset-bevel">
            Industrial Logic Terminal // Secured
          </div>
        </div>
        
        <AuthForm />
        
        <div className="text-[9px] text-secondary max-w-[280px] text-center leading-relaxed opacity-75">
          * Authorized personnel only. All access attempts are logged on the central mainframe.
        </div>
      </div>
    </div>
  );
}
