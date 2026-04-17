module github.com/urbanmove/urbanmove-auth

go 1.24

require (
	github.com/golang-jwt/jwt/v5 v5.2.2
	github.com/urbanmove/contracts v0.0.0
	google.golang.org/grpc v1.75.1
)

require (
	golang.org/x/net v0.41.0 // indirect
	golang.org/x/sys v0.33.0 // indirect
	golang.org/x/text v0.26.0 // indirect
	google.golang.org/genproto/googleapis/rpc v0.0.0-20250707201910-8d1bb00bc6a7 // indirect
	google.golang.org/protobuf v1.36.10 // indirect
)

replace github.com/urbanmove/contracts => ../contracts
