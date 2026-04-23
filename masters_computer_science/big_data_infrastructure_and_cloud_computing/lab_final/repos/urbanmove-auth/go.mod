module github.com/urbanmove/urbanmove-auth

go 1.24.0

require (
	github.com/golang-jwt/jwt/v5 v5.2.2
	github.com/urbanmove/contracts v0.0.0
	google.golang.org/grpc v1.79.3
)

require (
	golang.org/x/net v0.48.0 // indirect
	golang.org/x/sys v0.39.0 // indirect
	golang.org/x/text v0.32.0 // indirect
	google.golang.org/genproto/googleapis/rpc v0.0.0-20251202230838-ff82c1b0f217 // indirect
	google.golang.org/protobuf v1.36.10 // indirect
)

replace github.com/urbanmove/contracts => ../contracts
