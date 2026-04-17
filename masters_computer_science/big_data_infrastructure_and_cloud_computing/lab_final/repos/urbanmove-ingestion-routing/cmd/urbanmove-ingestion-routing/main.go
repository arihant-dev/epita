package main

import (
	"context"
	"database/sql"
	"encoding/json"
	"log"
	"math/rand"
	"net"
	"net/http"
	"os"
	"sort"
	"strconv"
	"sync"
	"time"

	_ "github.com/jackc/pgx/v5/stdlib"
	"github.com/nats-io/nats.go"
	urbanmovev1 "github.com/urbanmove/contracts/gen/go/urbanmove/v1"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

const eventsSubject = "mobility.events"

type segmentState struct {
	Congestion int32
	Incident   bool
	Timestamp  int64
}

type mobilityServer struct {
	urbanmovev1.UnimplementedMobilityServiceServer
	mu       sync.RWMutex
	segments map[string]segmentState
	nc       *nats.Conn
	db       *sql.DB
}

func main() {
	grpcAddr := getenvDefault("MOBILITY_GRPC_ADDR", ":50052")
	httpAddr := getenvDefault("MOBILITY_HTTP_ADDR", ":8082")
	natsURL := getenvDefault("NATS_URL", "nats://localhost:4222")
	databaseURL := os.Getenv("DATABASE_URL")
	enableSimulator := getenvDefault("SIMULATOR_ENABLED", "true") == "true"
	intervalSec := getenvIntDefault("SIMULATOR_INTERVAL_SECONDS", 5)

	nc, err := nats.Connect(natsURL)
	if err != nil {
		log.Fatalf("connect nats: %v", err)
	}
	defer nc.Close()

	var db *sql.DB
	if databaseURL != "" {
		db, err = sql.Open("pgx", databaseURL)
		if err != nil {
			log.Fatalf("open postgres: %v", err)
		}
		if err := ensureSchema(db); err != nil {
			log.Fatalf("ensure schema: %v", err)
		}
		log.Println("postgres storage enabled")
	} else {
		log.Println("postgres storage disabled (DATABASE_URL not set)")
	}

	srv := &mobilityServer{
		segments: make(map[string]segmentState),
		nc:       nc,
		db:       db,
	}

	if _, err := nc.Subscribe(eventsSubject, func(msg *nats.Msg) {
		var ev urbanmovev1.MobilityEvent
		if err := json.Unmarshal(msg.Data, &ev); err != nil {
			log.Printf("invalid event payload: %v", err)
			return
		}
		srv.applyEvent(&ev)
	}); err != nil {
		log.Fatalf("subscribe nats: %v", err)
	}
	if err := nc.Flush(); err != nil {
		log.Fatalf("flush nats: %v", err)
	}

	if enableSimulator {
		go runSimulator(nc, time.Duration(intervalSec)*time.Second)
	}

	lis, err := net.Listen("tcp", grpcAddr)
	if err != nil {
		log.Fatalf("listen grpc: %v", err)
	}

	grpcServer := grpc.NewServer()
	urbanmovev1.RegisterMobilityServiceServer(grpcServer, srv)
	go func() {
		log.Printf("urbanmove-ingestion-routing gRPC listening on %s", grpcAddr)
		if err := grpcServer.Serve(lis); err != nil {
			log.Fatalf("serve grpc: %v", err)
		}
	}()

	mux := http.NewServeMux()
	mux.HandleFunc("/healthz", func(w http.ResponseWriter, _ *http.Request) {
		writeJSON(w, http.StatusOK, map[string]any{"status": "ok", "service": "urbanmove-ingestion-routing"})
	})
	mux.HandleFunc("/gov-feed/events", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodPost {
			writeJSON(w, http.StatusMethodNotAllowed, map[string]string{"error": "method not allowed"})
			return
		}
		var event urbanmovev1.MobilityEvent
		if err := json.NewDecoder(r.Body).Decode(&event); err != nil {
			writeJSON(w, http.StatusBadRequest, map[string]string{"error": "invalid json"})
			return
		}
		if event.TimestampUnix == 0 {
			event.TimestampUnix = time.Now().UTC().Unix()
		}
		if event.Source == "" {
			event.Source = "mock-gov-api"
		}
		payload, _ := json.Marshal(event)
		if err := nc.Publish(eventsSubject, payload); err != nil {
			writeJSON(w, http.StatusBadGateway, map[string]string{"error": "publish failed"})
			return
		}
		writeJSON(w, http.StatusAccepted, map[string]any{"accepted": true, "event": event})
	})

	log.Printf("urbanmove-ingestion-routing HTTP listening on %s", httpAddr)
	if err := http.ListenAndServe(httpAddr, mux); err != nil {
		log.Fatalf("serve http: %v", err)
	}
}

func (s *mobilityServer) IngestEvent(_ context.Context, req *urbanmovev1.MobilityEvent) (*urbanmovev1.IngestEventResponse, error) {
	if req.GetSegmentId() == "" {
		return nil, status.Error(codes.InvalidArgument, "segment_id is required")
	}
	if req.TimestampUnix == 0 {
		req.TimestampUnix = time.Now().UTC().Unix()
	}
	if req.Source == "" {
		req.Source = "grpc-client"
	}
	payload, err := json.Marshal(req)
	if err != nil {
		return nil, status.Errorf(codes.Internal, "marshal event: %v", err)
	}
	if err := s.nc.Publish(eventsSubject, payload); err != nil {
		return nil, status.Errorf(codes.Unavailable, "publish event: %v", err)
	}
	return &urbanmovev1.IngestEventResponse{Accepted: true, Message: "event queued"}, nil
}

func (s *mobilityServer) GetBestRoute(_ context.Context, req *urbanmovev1.RouteRequest) (*urbanmovev1.RouteResponse, error) {
	if req.GetOrigin() == "" || req.GetDestination() == "" {
		return nil, status.Error(codes.InvalidArgument, "origin and destination are required")
	}

	candidates := []struct {
		ID       string
		Segments []string
	}{
		{ID: "route-A", Segments: []string{"seg-a", "seg-b", "seg-c"}},
		{ID: "route-B", Segments: []string{"seg-d", "seg-e", "seg-f"}},
		{ID: "route-C", Segments: []string{"seg-g", "seg-h", "seg-i"}},
	}

	bestID := ""
	bestSegments := []string{}
	bestScore := int32(-1)

	for _, c := range candidates {
		score := s.scoreRoute(c.Segments)
		if score > bestScore {
			bestScore = score
			bestID = c.ID
			bestSegments = c.Segments
		}
	}

	return &urbanmovev1.RouteResponse{
		RouteId:  bestID,
		Summary:  "best route computed from latest congestion + incident signals",
		Score:    bestScore,
		Segments: bestSegments,
	}, nil
}

func (s *mobilityServer) GetCongestionSummary(_ context.Context, req *urbanmovev1.CongestionSummaryRequest) (*urbanmovev1.CongestionSummaryResponse, error) {
	limit := int(req.GetLimit())
	if limit <= 0 {
		limit = 5
	}

	s.mu.RLock()
	defer s.mu.RUnlock()

	segments := make([]*urbanmovev1.CongestionSegment, 0, len(s.segments))
	for id, st := range s.segments {
		segments = append(segments, &urbanmovev1.CongestionSegment{
			SegmentId:       id,
			CongestionLevel: st.Congestion,
			Incident:        st.Incident,
			TimestampUnix:   st.Timestamp,
		})
	}

	sort.Slice(segments, func(i, j int) bool {
		return segments[i].CongestionLevel > segments[j].CongestionLevel
	})

	if limit < len(segments) {
		segments = segments[:limit]
	}

	return &urbanmovev1.CongestionSummaryResponse{
		Segments:        segments,
		GeneratedAtUnix: time.Now().UTC().Unix(),
	}, nil
}

func (s *mobilityServer) applyEvent(ev *urbanmovev1.MobilityEvent) {
	if ev.GetSegmentId() == "" {
		return
	}
	if ev.GetTimestampUnix() == 0 {
		ev.TimestampUnix = time.Now().UTC().Unix()
	}

	s.mu.Lock()
	s.segments[ev.GetSegmentId()] = segmentState{
		Congestion: ev.GetCongestionLevel(),
		Incident:   ev.GetIncident(),
		Timestamp:  ev.GetTimestampUnix(),
	}
	s.mu.Unlock()

	if s.db != nil {
		_, err := s.db.Exec(`
			INSERT INTO mobility_events (segment_id, congestion_level, incident, source, timestamp_unix)
			VALUES ($1, $2, $3, $4, $5)
		`, ev.GetSegmentId(), ev.GetCongestionLevel(), ev.GetIncident(), ev.GetSource(), ev.GetTimestampUnix())
		if err != nil {
			log.Printf("insert event failed: %v", err)
		}
	}
}

func (s *mobilityServer) scoreRoute(segments []string) int32 {
	s.mu.RLock()
	defer s.mu.RUnlock()

	if len(segments) == 0 {
		return 0
	}
	var congestionTotal int32
	var incidentPenalty int32
	for _, seg := range segments {
		state, ok := s.segments[seg]
		if !ok {
			congestionTotal += 40
			continue
		}
		congestionTotal += state.Congestion
		if state.Incident {
			incidentPenalty += 25
		}
	}
	avgCongestion := congestionTotal / int32(len(segments))
	score := int32(100) - avgCongestion - incidentPenalty
	if score < 0 {
		return 0
	}
	return score
}

func runSimulator(nc *nats.Conn, interval time.Duration) {
	segments := []string{"seg-a", "seg-b", "seg-c", "seg-d", "seg-e", "seg-f", "seg-g", "seg-h", "seg-i"}
	ticker := time.NewTicker(interval)
	defer ticker.Stop()

	for range ticker.C {
		event := urbanmovev1.MobilityEvent{
			SegmentId:       segments[rand.Intn(len(segments))],
			CongestionLevel: int32(rand.Intn(100)),
			Incident:        rand.Intn(8) == 0,
			Source:          "simulator",
			TimestampUnix:   time.Now().UTC().Unix(),
		}
		payload, _ := json.Marshal(event)
		if err := nc.Publish(eventsSubject, payload); err != nil {
			log.Printf("simulator publish failed: %v", err)
		}
	}
}

func ensureSchema(db *sql.DB) error {
	_, err := db.Exec(`
		CREATE TABLE IF NOT EXISTS mobility_events (
			id BIGSERIAL PRIMARY KEY,
			segment_id TEXT NOT NULL,
			congestion_level INTEGER NOT NULL,
			incident BOOLEAN NOT NULL,
			source TEXT NOT NULL,
			timestamp_unix BIGINT NOT NULL,
			created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
		)
	`)
	return err
}

func getenvDefault(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}

func getenvIntDefault(key string, fallback int) int {
	raw := os.Getenv(key)
	if raw == "" {
		return fallback
	}
	v, err := strconv.Atoi(raw)
	if err != nil {
		return fallback
	}
	return v
}

func writeJSON(w http.ResponseWriter, code int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(code)
	_ = json.NewEncoder(w).Encode(v)
}
