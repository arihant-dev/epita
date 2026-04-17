const API_BASE = "/api/v1";
let accessToken = "";

const byId = (id) => document.getElementById(id);

function setText(id, text) {
  byId(id).textContent = text;
}

function pretty(obj) {
  return JSON.stringify(obj, null, 2);
}

async function api(path, options = {}) {
  const headers = { "Content-Type": "application/json", ...(options.headers || {}) };
  if (accessToken) {
    headers.Authorization = `Bearer ${accessToken}`;
  }
  const res = await fetch(`${API_BASE}${path}`, { ...options, headers });
  let data = {};
  try {
    data = await res.json();
  } catch (_) {
    data = {};
  }
  if (!res.ok) {
    throw new Error(data.error || `HTTP ${res.status}`);
  }
  return data;
}

byId("login-form").addEventListener("submit", async (e) => {
  e.preventDefault();
  setText("login-result", "Loading...");
  try {
    const data = await api("/auth/login", {
      method: "POST",
      body: JSON.stringify({
        username: byId("username").value,
        password: byId("password").value
      })
    });
    accessToken = data.access_token || "";
    setText("login-result", `Role: ${data.role}\nToken stored in-memory.`);
  } catch (err) {
    setText("login-result", `Error: ${err.message}`);
  }
});

byId("congestion-form").addEventListener("submit", async (e) => {
  e.preventDefault();
  setText("congestion-result", "Loading...");
  try {
    const limit = byId("congestion-limit").value || "5";
    const data = await api(`/congestion?limit=${encodeURIComponent(limit)}`);
    setText("congestion-result", pretty(data));
  } catch (err) {
    setText("congestion-result", `Error: ${err.message}`);
  }
});

byId("route-form").addEventListener("submit", async (e) => {
  e.preventDefault();
  setText("route-result", "Loading...");
  try {
    const origin = byId("origin").value;
    const destination = byId("destination").value;
    const data = await api(
      `/routes/recommendation?origin=${encodeURIComponent(origin)}&destination=${encodeURIComponent(destination)}`
    );
    setText("route-result", pretty(data));
  } catch (err) {
    setText("route-result", `Error: ${err.message}`);
  }
});

byId("event-form").addEventListener("submit", async (e) => {
  e.preventDefault();
  setText("event-result", "Loading...");
  try {
    const body = {
      segment_id: byId("segment-id").value,
      congestion_level: Number(byId("congestion-level").value),
      incident: byId("incident").checked,
      source: "frontend-demo",
      timestamp_unix: Math.floor(Date.now() / 1000)
    };
    const data = await api("/events", { method: "POST", body: JSON.stringify(body) });
    setText("event-result", pretty(data));
  } catch (err) {
    setText("event-result", `Error: ${err.message}`);
  }
});
