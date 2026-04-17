# urbanmove contracts

Shared protobuf contracts for all services.

## Generate stubs

```bash
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

export PATH="$PATH:$(go env GOPATH)/bin"
protoc \
  --proto_path=proto \
  --go_out=. \
  --go-grpc_out=. \
  proto/urbanmove.proto
```
