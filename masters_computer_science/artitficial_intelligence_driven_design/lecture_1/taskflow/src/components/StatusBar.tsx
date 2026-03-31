"use client";

import { useEffect, useState } from "react";

export default function StatusBar() {
  const [time, setTime] = useState("");

  useEffect(() => {
    const updateTime = () => {
      const now = new Date();
      setTime(
        now.toLocaleString("en-US", {
          month: "2-digit",
          day: "2-digit",
          year: "numeric",
          hour: "2-digit",
          minute: "2-digit",
          second: "2-digit",
          hour12: true,
        })
      );
    };
    updateTime();
    const interval = setInterval(updateTime, 1000);
    return () => clearInterval(interval);
  }, []);

  return (
    <footer className="fixed bottom-0 left-48 right-0 h-6 bg-background border-t-2 border-white flex items-center px-2 justify-between z-50 outset-bevel shadow-[0_-1px_0_rgba(0,0,0,0.2)]">
      <div className="flex items-center gap-4 text-[10px] font-bold uppercase overflow-hidden">
        <div className="flex items-center gap-1 truncate">
          <span className="material-symbols-outlined" style={{ fontSize: '12px' }}>terminal</span>
          Connected: SRV-NODE-01
        </div>
        <div className="flex items-center gap-1 text-green-700 truncate">
          <span className="material-symbols-outlined" style={{ fontSize: '12px' }}>database</span>
          Sync: Nominal
        </div>
      </div>
      <div className="flex items-center gap-2 outset-bevel bg-white px-2 h-4 text-[9px] font-black italic whitespace-nowrap min-w-max">
        {time || "INITIALIZING..."}
      </div>
    </footer>
  );
}
