import {
  getFirebaseConfigErrorMessage,
  missingFirebaseEnvVars,
} from "@/lib/firebase";

interface ConfigNoticeProps {
  title?: string;
  body?: string;
}

export default function ConfigNotice({
  title = "Firebase configuration required",
  body = "TaskFlow needs its public Firebase variables before authentication and Firestore can run.",
}: ConfigNoticeProps) {
  return (
    <div className="outset-bevel bg-background p-1 w-full max-w-2xl">
      <div className="bg-secondary px-2 py-1 text-[11px] font-bold uppercase text-white">
        Deployment_Config_Check
      </div>
      <div className="space-y-4 bg-surface p-4 text-sm text-black">
        <div className="space-y-1">
          <h2 className="text-lg font-black uppercase tracking-tight">{title}</h2>
          <p className="text-xs leading-relaxed text-secondary">{body}</p>
        </div>

        <div className="inset-bevel bg-white p-3">
          <p className="text-[11px] font-bold uppercase text-red-700">
            {getFirebaseConfigErrorMessage()}
          </p>
        </div>

        {missingFirebaseEnvVars.length > 0 ? (
          <div className="space-y-2">
            <p className="text-[10px] font-bold uppercase text-secondary">
              Add these values in Vercel Project Settings -> Environment Variables:
            </p>
            <ul className="space-y-1 text-[11px] font-mono">
              {missingFirebaseEnvVars.map((key) => (
                <li key={key} className="inset-bevel bg-white px-2 py-1">
                  {key}
                </li>
              ))}
            </ul>
          </div>
        ) : (
          <p className="text-[10px] font-bold uppercase text-secondary">
            Verify the published Firebase values in Vercel and redeploy this environment.
          </p>
        )}
      </div>
    </div>
  );
}
