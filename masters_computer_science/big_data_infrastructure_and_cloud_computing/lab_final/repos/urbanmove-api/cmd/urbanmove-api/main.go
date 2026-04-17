package main

import (
	"context"
	"encoding/json"
	"log"
	"net/http"
	"os"
	"strconv"
	"strings"
	"time"

	urbanmovev1 "github.com/urbanmove/contracts/gen/go/urbanmove/v1"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

type app struct {
	authClient     urbanmovev1.AuthServiceClient
	mobilityClient urbanmovev1.MobilityServiceClient
}

func main() {
	httpAddr := getenvDefault("API_HTTP_ADDR", ":8080")
	authAddr := getenvDefault("AUTH_GRPC_ADDR", "localhost:50051")
	mobilityAddr := getenvDefault("MOBILITY_GRPC_ADDR", "localhost:50052")

	authConn, err := grpc.NewClient(authAddr, grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		log.Fatalf("auth grpc connect: %v", err)
	}
	defer authConn.Close()

	mobilityConn, err := grpc.NewClient(mobilityAddr, grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		log.Fatalf("mobility grpc connect: %v", err)
	}
	defer mobilityConn.Close()

	a := &app{
		authClient:     urbanmovev1.NewAuthServiceClient(authConn),
		mobilityClient: urbanmovev1.NewMobilityServiceClient(mobilityConn),
	}

	mux := http.NewServeMux()
	healthHandler := func(w http.ResponseWriter, _ *http.Request) {
		writeJSON(w, http.StatusOK, map[string]any{"status": "ok", "service": "urbanmove-api"})
	}
	for _, path := range []string{"/healthz", "/health", "/api/healthz", "/api/health", "/api/v1/healthz", "/v1/healthz"} {
		registerRoute(mux, path, healthHandler)
	}

	for _, prefix := range []string{"/api/v1", "/v1", "/api", ""} {
		registerRoute(mux, routePath(prefix, "/auth/login"), a.handleLogin)
		registerRoute(mux, routePath(prefix, "/congestion"), a.withAuth(a.handleCongestion))
		registerRoute(mux, routePath(prefix, "/routes/recommendation"), a.withAuth(a.handleRouteRecommendation))
		registerRoute(mux, routePath(prefix, "/events"), a.withAuth(a.handleIngestEvent))
	}

	log.Printf("urbanmove-api HTTP listening on %s", httpAddr)
	if err := http.ListenAndServe(httpAddr, mux); err != nil {
		log.Fatalf("serve http: %v", err)
	}
}

func (a *app) handleLogin(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		writeJSON(w, http.StatusMethodNotAllowed, map[string]string{"error": "method not allowed"})
		return
	}

	var body struct {
		Username string `json:"username"`
		Password string `json:"password"`
	}
	if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
		writeJSON(w, http.StatusBadRequest, map[string]string{"error": "invalid json"})
		return
	}

	ctx, cancel := context.WithTimeout(r.Context(), 4*time.Second)
	defer cancel()

	resp, err := a.authClient.IssueToken(ctx, &urbanmovev1.LoginRequest{
		Username: body.Username,
		Password: body.Password,
	})
	if err != nil {
		writeJSON(w, http.StatusUnauthorized, map[string]string{"error": "invalid credentials"})
		return
	}
	writeJSON(w, http.StatusOK, resp)
}

func (a *app) handleCongestion(w http.ResponseWriter, r *http.Request, principal *urbanmovev1.TokenValidationResponse) {
	_ = principal
	if r.Method != http.MethodGet {
		writeJSON(w, http.StatusMethodNotAllowed, map[string]string{"error": "method not allowed"})
		return
	}

	limit := int32(5)
	if raw := r.URL.Query().Get("limit"); raw != "" {
		v, err := strconv.Atoi(raw)
		if err == nil && v > 0 {
			limit = int32(v)
		}
	}

	ctx, cancel := context.WithTimeout(r.Context(), 4*time.Second)
	defer cancel()
	resp, err := a.mobilityClient.GetCongestionSummary(ctx, &urbanmovev1.CongestionSummaryRequest{Limit: limit})
	if err != nil {
		writeJSON(w, http.StatusBadGateway, map[string]string{"error": "mobility service unavailable"})
		return
	}
	writeJSON(w, http.StatusOK, resp)
}

func (a *app) handleRouteRecommendation(w http.ResponseWriter, r *http.Request, principal *urbanmovev1.TokenValidationResponse) {
	_ = principal
	if r.Method != http.MethodGet && r.Method != http.MethodPost {
		writeJSON(w, http.StatusMethodNotAllowed, map[string]string{"error": "method not allowed"})
		return
	}

	origin := r.URL.Query().Get("origin")
	destination := r.URL.Query().Get("destination")
	if (origin == "" || destination == "") && r.Method == http.MethodPost {
		var body struct {
			Origin      string `json:"origin"`
			Destination string `json:"destination"`
		}
		if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
			writeJSON(w, http.StatusBadRequest, map[string]string{"error": "invalid json"})
			return
		}
		if origin == "" {
			origin = body.Origin
		}
		if destination == "" {
			destination = body.Destination
		}
	}
	if origin == "" || destination == "" {
		writeJSON(w, http.StatusBadRequest, map[string]string{"error": "origin and destination are required"})
		return
	}

	ctx, cancel := context.WithTimeout(r.Context(), 4*time.Second)
	defer cancel()
	resp, err := a.mobilityClient.GetBestRoute(ctx, &urbanmovev1.RouteRequest{
		Origin:      origin,
		Destination: destination,
	})
	if err != nil {
		writeJSON(w, http.StatusBadGateway, map[string]string{"error": "mobility service unavailable"})
		return
	}
	writeJSON(w, http.StatusOK, resp)
}

func (a *app) handleIngestEvent(w http.ResponseWriter, r *http.Request, principal *urbanmovev1.TokenValidationResponse) {
	if principal.GetRole() != "admin" && principal.GetRole() != "operator" {
		writeJSON(w, http.StatusForbidden, map[string]string{"error": "admin or operator role required"})
		return
	}
	if r.Method != http.MethodPost {
		writeJSON(w, http.StatusMethodNotAllowed, map[string]string{"error": "method not allowed"})
		return
	}

	var body urbanmovev1.MobilityEvent
	if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
		writeJSON(w, http.StatusBadRequest, map[string]string{"error": "invalid json"})
		return
	}

	ctx, cancel := context.WithTimeout(r.Context(), 4*time.Second)
	defer cancel()
	resp, err := a.mobilityClient.IngestEvent(ctx, &body)
	if err != nil {
		writeJSON(w, http.StatusBadGateway, map[string]string{"error": "mobility service unavailable"})
		return
	}
	writeJSON(w, http.StatusAccepted, resp)
}

func (a *app) withAuth(next func(http.ResponseWriter, *http.Request, *urbanmovev1.TokenValidationResponse)) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		token := bearerToken(r.Header.Get("Authorization"))
		if token == "" {
			writeJSON(w, http.StatusUnauthorized, map[string]string{"error": "missing bearer token"})
			return
		}

		ctx, cancel := context.WithTimeout(r.Context(), 4*time.Second)
		defer cancel()
		principal, err := a.authClient.ValidateToken(ctx, &urbanmovev1.TokenValidationRequest{Token: token})
		if err != nil || !principal.GetValid() {
			writeJSON(w, http.StatusUnauthorized, map[string]string{"error": "invalid token"})
			return
		}
		next(w, r, principal)
	}
}

func bearerToken(authHeader string) string {
	parts := strings.SplitN(authHeader, " ", 2)
	if len(parts) != 2 || !strings.EqualFold(parts[0], "Bearer") {
		return ""
	}
	return strings.TrimSpace(parts[1])
}

func getenvDefault(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}

func routePath(prefix, suffix string) string {
	if prefix == "" {
		return suffix
	}
	return prefix + suffix
}

func registerRoute(mux *http.ServeMux, path string, handler http.HandlerFunc) {
	mux.HandleFunc(path, handler)
	if path != "/" {
		mux.HandleFunc(path+"/", handler)
	}
}

func writeJSON(w http.ResponseWriter, code int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(code)
	_ = json.NewEncoder(w).Encode(v)
}
