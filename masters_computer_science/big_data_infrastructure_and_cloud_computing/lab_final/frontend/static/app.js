const API_BASE = "/api/v1";
const SESSION_KEYS = {
  token: "urbanmove_access_token",
  role: "urbanmove_role",
  username: "urbanmove_username"
};

const byId = (id) => document.getElementById(id);

function pretty(value) {
  return JSON.stringify(value, null, 2);
}

function readSession() {
  return {
    token: localStorage.getItem(SESSION_KEYS.token) || "",
    role: localStorage.getItem(SESSION_KEYS.role) || "",
    username: localStorage.getItem(SESSION_KEYS.username) || ""
  };
}

function writeSession(nextSession) {
  localStorage.setItem(SESSION_KEYS.token, nextSession.token || "");
  localStorage.setItem(SESSION_KEYS.role, nextSession.role || "");
  localStorage.setItem(SESSION_KEYS.username, nextSession.username || "");
}

function clearSession() {
  localStorage.removeItem(SESSION_KEYS.token);
  localStorage.removeItem(SESSION_KEYS.role);
  localStorage.removeItem(SESSION_KEYS.username);
}

let session = readSession();

function setResult(id, message, variant = "info") {
  const el = byId(id);
  if (!el) {
    return;
  }
  el.textContent = message;
  el.classList.remove("is-success", "is-error");
  if (variant === "success") {
    el.classList.add("is-success");
  }
  if (variant === "error") {
    el.classList.add("is-error");
  }
}

function setGateMessage(message, variant = "info") {
  const gate = byId("page-gate");
  if (!gate) {
    return;
  }
  gate.classList.remove("is-success", "is-error");
  if (variant === "success") {
    gate.classList.add("is-success");
  }
  if (variant === "error") {
    gate.classList.add("is-error");
  }
  gate.textContent = message;
}

async function api(path, options = {}) {
  const headers = { ...(options.headers || {}) };
  if (options.body && !headers["Content-Type"]) {
    headers["Content-Type"] = "application/json";
  }
  if (session.token) {
    headers.Authorization = `Bearer ${session.token}`;
  }

  const response = await fetch(`${API_BASE}${path}`, { ...options, headers });
  let payload = {};
  try {
    payload = await response.json();
  } catch (_) {
    payload = {};
  }

  if (!response.ok) {
    throw new Error(payload.error || payload.message || `HTTP ${response.status}`);
  }
  return payload;
}

function updateHeaderUI() {
  const page = (document.body && document.body.dataset.page) || "home";
  document.querySelectorAll("[data-nav]").forEach((link) => {
    link.classList.toggle("active", link.dataset.nav === page);
  });

  const chip = byId("session-chip");
  if (chip) {
    if (session.token) {
      const role = session.role || "role-unknown";
      const name = session.username || "user";
      chip.textContent = `${name} (${role})`;
      chip.classList.add("signed-in");
    } else {
      chip.textContent = "Guest session";
      chip.classList.remove("signed-in");
    }
  }

  const logoutBtn = byId("logout-btn");
  if (logoutBtn) {
    logoutBtn.classList.toggle("hidden", !session.token);
  }
}

function bindLogout() {
  const logoutBtn = byId("logout-btn");
  if (!logoutBtn) {
    return;
  }
  logoutBtn.addEventListener("click", () => {
    clearSession();
    session = readSession();
    updateHeaderUI();
    setGateMessage("Session cleared. Login again to continue.");
    setResult("login-result", "Session cleared. Sign in again.");
  });
}

function bindLogin() {
  const form = byId("login-form");
  if (!form) {
    return;
  }

  form.addEventListener("submit", async (event) => {
    event.preventDefault();
    setResult("login-result", "Signing in...");

    try {
      const username = byId("username").value.trim();
      const password = byId("password").value;
      const data = await api("/auth/login", {
        method: "POST",
        body: JSON.stringify({ username, password })
      });

      session = {
        token: data.access_token || "",
        role: data.role || "operator",
        username
      };
      writeSession(session);
      updateHeaderUI();
      setResult("login-result", `Signed in as ${username} (${session.role}).`, "success");

      const next = byId("login-next");
      if (next) {
        next.classList.remove("hidden");
      }
    } catch (err) {
      setResult("login-result", `Error: ${err.message}`, "error");
    }
  });
}

function bindCongestion() {
  const form = byId("congestion-form");
  if (!form) {
    return;
  }

  form.addEventListener("submit", async (event) => {
    event.preventDefault();
    setResult("congestion-result", "Loading congestion summary...");
    try {
      const limit = byId("congestion-limit").value || "5";
      const data = await api(`/congestion?limit=${encodeURIComponent(limit)}`);
      setResult("congestion-result", pretty(data), "success");
    } catch (err) {
      setResult("congestion-result", `Error: ${err.message}`, "error");
    }
  });
}

function bindRouteRecommendation() {
  const form = byId("route-form");
  if (!form) {
    return;
  }

  form.addEventListener("submit", async (event) => {
    event.preventDefault();
    setResult("route-result", "Calculating recommended route...");
    try {
      const origin = byId("origin").value.trim();
      const destination = byId("destination").value.trim();
      const data = await api(
        `/routes/recommendation?origin=${encodeURIComponent(origin)}&destination=${encodeURIComponent(destination)}`
      );
      setResult("route-result", pretty(data), "success");
    } catch (err) {
      setResult("route-result", `Error: ${err.message}`, "error");
    }
  });
}

function bindEventInjection() {
  const form = byId("event-form");
  if (!form) {
    return;
  }

  form.addEventListener("submit", async (event) => {
    event.preventDefault();
    if (!session.token) {
      setResult("event-result", "Login is required before injecting events.", "error");
      return;
    }

    setResult("event-result", "Sending event...");
    try {
      const body = {
        segment_id: byId("segment-id").value.trim(),
        congestion_level: Number(byId("congestion-level").value),
        incident: byId("incident").checked,
        source: "frontend-demo",
        timestamp_unix: Math.floor(Date.now() / 1000)
      };
      const data = await api("/events", { method: "POST", body: JSON.stringify(body) });
      setResult("event-result", pretty(data), "success");
    } catch (err) {
      setResult("event-result", `Error: ${err.message}`, "error");
    }
  });
}

function setPageHints() {
  const page = (document.body && document.body.dataset.page) || "home";
  if (page === "operations" || page === "admin") {
    if (session.token) {
      setGateMessage("Authenticated session active. API requests will use your token.", "success");
    } else {
      setGateMessage("You are in guest mode. Login first for protected actions.", "error");
    }
  }

  if (page === "login" && session.token) {
    setResult(
      "login-result",
      `Already signed in as ${session.username || "user"} (${session.role || "operator"}).`,
      "success"
    );
    const next = byId("login-next");
    if (next) {
      next.classList.remove("hidden");
    }
  }
}

function init() {
  updateHeaderUI();
  bindLogout();
  bindLogin();
  bindCongestion();
  bindRouteRecommendation();
  bindEventInjection();
  setPageHints();
}

document.addEventListener("DOMContentLoaded", init);
