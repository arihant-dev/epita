package main

import (
	"context"
	"encoding/json"
	"errors"
	"log"
	"net"
	"net/http"
	"os"
	"time"

	"github.com/golang-jwt/jwt/v5"
	urbanmovev1 "github.com/urbanmove/contracts/gen/go/urbanmove/v1"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

type userRecord struct {
	Password string
	Role     string
}

type authServer struct {
	urbanmovev1.UnimplementedAuthServiceServer
	jwtSecret []byte
	users     map[string]userRecord
}

func newAuthServer(secret string) *authServer {
	return &authServer{
		jwtSecret: []byte(secret),
		users: map[string]userRecord{
			"operator1": {Password: "operator123", Role: "operator"},
			"admin1":    {Password: "admin123", Role: "admin"},
			"user1":     {Password: "user123", Role: "user"},
		},
	}
}

func (s *authServer) IssueToken(_ context.Context, req *urbanmovev1.LoginRequest) (*urbanmovev1.LoginResponse, error) {
	rec, ok := s.users[req.GetUsername()]
	if !ok || rec.Password != req.GetPassword() {
		return nil, status.Error(codes.Unauthenticated, "invalid credentials")
	}

	expiresAt := time.Now().UTC().Add(1 * time.Hour)
	claims := jwt.MapClaims{
		"sub":  req.GetUsername(),
		"role": rec.Role,
		"exp":  expiresAt.Unix(),
		"iat":  time.Now().UTC().Unix(),
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	signed, err := token.SignedString(s.jwtSecret)
	if err != nil {
		return nil, status.Errorf(codes.Internal, "sign token: %v", err)
	}

	return &urbanmovev1.LoginResponse{
		AccessToken:   signed,
		Role:          rec.Role,
		ExpiresAtUnix: expiresAt.Unix(),
	}, nil
}

func (s *authServer) ValidateToken(_ context.Context, req *urbanmovev1.TokenValidationRequest) (*urbanmovev1.TokenValidationResponse, error) {
	claims := jwt.MapClaims{}
	token, err := jwt.ParseWithClaims(req.GetToken(), claims, func(t *jwt.Token) (any, error) {
		if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, errors.New("unexpected signing method")
		}
		return s.jwtSecret, nil
	})
	if err != nil || !token.Valid {
		return &urbanmovev1.TokenValidationResponse{Valid: false}, nil
	}

	sub, _ := claims["sub"].(string)
	role, _ := claims["role"].(string)
	return &urbanmovev1.TokenValidationResponse{
		Valid:  true,
		UserId: sub,
		Role:   role,
	}, nil
}

func main() {
	grpcAddr := getenvDefault("AUTH_GRPC_ADDR", ":50051")
	httpAddr := getenvDefault("AUTH_HTTP_ADDR", ":8081")
	secret := getenvDefault("JWT_SECRET", "change-this-in-prod")

	srv := newAuthServer(secret)

	lis, err := net.Listen("tcp", grpcAddr)
	if err != nil {
		log.Fatalf("listen grpc: %v", err)
	}

	grpcServer := grpc.NewServer()
	urbanmovev1.RegisterAuthServiceServer(grpcServer, srv)

	go func() {
		log.Printf("urbanmove-auth gRPC listening on %s", grpcAddr)
		if err := grpcServer.Serve(lis); err != nil {
			log.Fatalf("serve grpc: %v", err)
		}
	}()

	mux := http.NewServeMux()
	mux.HandleFunc("/healthz", func(w http.ResponseWriter, _ *http.Request) {
		writeJSON(w, http.StatusOK, map[string]any{"status": "ok", "service": "urbanmove-auth"})
	})

	log.Printf("urbanmove-auth HTTP listening on %s", httpAddr)
	if err := http.ListenAndServe(httpAddr, mux); err != nil {
		log.Fatalf("serve http: %v", err)
	}
}

func getenvDefault(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}

func writeJSON(w http.ResponseWriter, code int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(code)
	_ = json.NewEncoder(w).Encode(v)
}
