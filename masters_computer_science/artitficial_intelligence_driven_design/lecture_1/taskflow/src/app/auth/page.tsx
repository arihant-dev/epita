import AuthForm from "@/components/AuthForm";

export default function AuthPage() {
  return (
    <div className="flex flex-1 items-center justify-center p-8 bg-surface pattern-dots">
      <div className="space-y-6 flex flex-col items-center">
        <div className="text-center space-y-2 mb-4">
          <h1 className="text-3xl font-black uppercase tracking-tighter text-black">
            TaskFlow v1.0
          </h1>
          <div className="text-[10px] font-bold text-secondary uppercase bg-white border border-gray-400 px-2 py-0.5">
            Industrial Logic Terminal // Secured
          </div>
        </div>
        
        <AuthForm />
        
        <div className="text-[10px] text-secondary max-w-[250px] text-center leading-relaxed">
          * Authorized personnel only. All access attempts are logged on the central mainframe.
        </div>
      </div>
    </div>
  );
}
