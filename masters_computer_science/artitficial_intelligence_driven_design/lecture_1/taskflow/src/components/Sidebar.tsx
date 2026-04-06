"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";

export default function Sidebar() {
  const pathname = usePathname();

  const navItems = [
    { label: "Dashboard", href: "/", badge: "01" },
  ];

  return (
    <aside className="fixed left-0 top-12 bottom-0 w-48 flex flex-col p-1 bg-background border-r-2 border-white border-b-2 border-black outset-bevel-heavy z-40">
      <div className="px-2 py-3 border-b-2 border-secondary mb-2">
        <div className="text-md font-bold text-black uppercase tracking-tight">Main_Menu</div>
        <div className="text-[10px] text-secondary font-bold uppercase">v1.0.97</div>
      </div>
      
      <nav className="flex flex-col gap-1">
        {navItems.map((item) => {
          const isActive = pathname === item.href;
          return (
            <Link
              key={item.href}
              href={item.href}
              className={`flex items-center gap-2 px-2 py-1.5 text-xs font-bold transition-all ${
                isActive
                  ? "bg-surface border-t-2 border-l-2 border-black border-r-2 border-white border-b-2 border-white text-tertiary underline"
                  : "border-t-2 border-l-2 border-white border-r-2 border-black border-b-2 border-black hover:bg-surface-container-highest text-black no-underline"
              }`}
            >
              <span className="text-[9px] font-black text-secondary">{item.badge}</span>
              {item.label}
            </Link>
          );
        })}
      </nav>

      <div className="mt-auto p-2 outset-bevel bg-surface-container-highest">
        <div className="text-[10px] font-bold uppercase mb-1">System Status</div>
        <div className="flex items-center gap-1">
          <div className="w-2 h-2 bg-green-500 border border-black shadow-[1px_1px_0_rgba(255,255,255,0.5)]"></div>
          <span className="text-[9px] font-black tracking-widest">ONLINE</span>
        </div>
        <div className="mt-2 text-[9px] uppercase text-secondary">
          Scope locked to the completed sprint stories.
        </div>
      </div>
    </aside>
  );
}
