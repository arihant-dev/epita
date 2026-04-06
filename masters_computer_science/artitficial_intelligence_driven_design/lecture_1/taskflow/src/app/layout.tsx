import type { Metadata } from "next";
import { Work_Sans } from "next/font/google";
import "./globals.css";
import { AuthProvider } from "@/lib/auth-context";
import Header from "@/components/Header";
import Sidebar from "@/components/Sidebar";
import StatusBar from "@/components/StatusBar";

const workSans = Work_Sans({
  subsets: ["latin"],
  variable: "--font-work-sans",
});

export const metadata: Metadata = {
  title: "TaskFlow v1.0 — Industrial Management",
  description: "High-density collaborative task management system.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html
      lang="en"
      className={`${workSans.variable} h-full antialiased`}
    >
      <head>
        <link
          rel="stylesheet"
          href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200&display=block"
        />
      </head>
      <body className="min-h-full flex flex-col bg-background text-black font-sans leading-tight">
        <AuthProvider>
          <Header />
          <div className="flex flex-1 pt-12 pb-6">
            <Sidebar />
            <main className="flex-1 ml-48 bg-surface overflow-auto">
              {children}
            </main>
          </div>
          <StatusBar />
        </AuthProvider>
      </body>
    </html>
  );
}
