# Clean up
./scripts/clean_ports.sh

# Build nowis executable file
go build -o bin/nowis cmd/nowis/main.go
./bin/nowis

wait
