package network

import (
	"context"
	"nowis/pkg/configs"
	"crypto/tls"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials"
	"google.golang.org/grpc/credentials/insecure"
	"log"
	"net"
	"os"
	"time"
)

// CreateGrpcClientConnection
// The code below is extracted from grpcurl repository.
// GitHub: https://github.com/fullstorydev/grpcurl/blob/fae58803d92722e2004fe42fb541ae593f5464dd/grpcurl.go
func CreateGrpcClientConnection(ctx context.Context, service string) (*grpc.ClientConn, error) {
	config := configs.GetConfig()

	if config.Env == "debug" {
		return grpc.Dial(service, grpc.WithTransportCredentials(insecure.NewCredentials()))
	}

	dialTime := 10 * time.Second
	ctx, cancel := context.WithTimeout(ctx, dialTime)
	defer cancel()
	var opts []grpc.DialOption
	var creds credentials.TransportCredentials
	tlsConf := tls.Config{}

	sslKeylogFile := os.Getenv("SSLKEYLOGFILE")
	if sslKeylogFile != "" {
		w, err := os.OpenFile(sslKeylogFile, os.O_WRONLY|os.O_CREATE|os.O_APPEND, 0600)
		if err != nil {
			log.Fatalf("Could not open SSLKEYLOGFILE %s", sslKeylogFile)
		}
		tlsConf.KeyLogWriter = w
	}

	creds = credentials.NewTLS(&tlsConf)

	opts = append(opts, grpc.WithAuthority(service))

	opts = append(opts, grpc.WithUserAgent("api.sofluffy.io/1.0.0"))

	network := "tcp"

	result := make(chan interface{}, 1)

	writeResult := func(res interface{}) {
		// non-blocking write: we only need the first result
		select {
		case result <- res:
		default:
		}
	}

	dialer := func(ctx context.Context, address string) (net.Conn, error) {
		// NB: We *could* handle the TLS handshake ourselves, in the custom
		// dialer (instead of customizing both the dialer and the credentials).
		// But that requires using insecure.NewCredentials() dial transport
		// option (so that the gRPC library doesn't *also* try to do a
		// handshake). And that would mean that the library would send the
		// wrong ":scheme" metaheader to servers: it would send "http" instead
		// of "https" because it is unaware that TLS is actually in use.
		conn, err := (&net.Dialer{}).DialContext(ctx, network, address)
		if err != nil {
			writeResult(err)
		}
		return conn, err
	}

	// Even with grpc.FailOnNonTempDialError, this call will usually timeout in
	// the face of TLS handshake errors. So we can't rely on grpc.WithBlock() to
	// know when we're done. So we run it in a goroutine and then use result
	// channel to either get the connection or fail-fast.
	go func() {
		// We put grpc.FailOnNonTempDialError *before* the explicitly provided
		// options so that it could be overridden.
		opts = append([]grpc.DialOption{grpc.FailOnNonTempDialError(true)}, opts...)
		// But we don't want caller to be able to override these two, so we put
		// them *after* the explicitly provided options.
		opts = append(opts, grpc.WithBlock(), grpc.WithContextDialer(dialer))

		if creds == nil {
			opts = append(opts, grpc.WithTransportCredentials(insecure.NewCredentials()))
		} else {
			opts = append(opts, grpc.WithTransportCredentials(creds))
		}
		conn, err := grpc.DialContext(ctx, service, opts...)
		var res interface{}
		if err != nil {
			res = err
		} else {
			res = conn
		}
		writeResult(res)
	}()

	select {
	case res := <-result:
		if conn, ok := res.(*grpc.ClientConn); ok {
			return conn, nil
		}
		return nil, res.(error)
	case <-ctx.Done():
		return nil, ctx.Err()
	}
}
