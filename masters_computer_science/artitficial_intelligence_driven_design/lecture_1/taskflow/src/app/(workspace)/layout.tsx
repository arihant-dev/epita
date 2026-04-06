import Header from "@/components/Header";
import Sidebar from "@/components/Sidebar";
import StatusBar from "@/components/StatusBar";
import { AuthProvider } from "@/lib/auth-context";

export default function WorkspaceLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <AuthProvider>
      <div className="min-h-full flex flex-col bg-background text-black font-sans leading-tight">
        <Header />
        <div className="flex flex-1 pt-12 pb-6">
          <Sidebar />
          <main className="flex-1 ml-48 bg-surface overflow-auto">{children}</main>
        </div>
        <StatusBar />
      </div>
    </AuthProvider>
  );
}
