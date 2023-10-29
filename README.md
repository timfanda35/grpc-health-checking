# GRPC Health Checking

A GRPC Health Checking Test Application

Based on source:
- https://github.com/kubernetes/kubernetes/blob/master/test/images/agnhost/grpc-health-checking/grpc-health-checking.go

See blog for more information:
- https://kubernetes.io/blog/2022/05/13/grpc-probes-now-in-beta/#trying-the-feature-out 

## What does this repository do?

- Just use the `grpc-health-checking` command of `agnhost`
- Add HTTP health check path
- Support GRPC Reflection for `grpcurl` convenience

A Sample test yaml for kubernetes would be:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-grpc
spec:
  containers:
  - name: grpc-health-checking
    image: ghcr.io/timfanda35/grpc-health-checking:v0.1.0
    ports:
    - name: grpc
      containerPort: 8000
    - name: http
      containerPort: 8080
    readinessProbe:
      grpc:
        port: 8000
```

You could use the `httpGet` for readiness:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-grpc
spec:
  containers:
  - name: grpc-health-checking
    image: ghcr.io/timfanda35/grpc-health-checking:v0.1.0
    ports:
    - name: grpc
      containerPort: 8000
    - name: http
      containerPort: 8080
    readinessProbe:
      httpGet:
        scheme: HTTP
        path: /healthcheck
        port: 8080
```

## Usage

Compile

```bash
make compile
```

Execute

```bash
./target/grpc-health-checking
```

It shows logs:

```
I1029 15:02:02.769553   85361 log.go:245] Http server starting to listen on :8080
I1029 15:02:02.770155   85361 log.go:245] gRPC server starting to listen on :8000
```

You can use `-h` to see the help:

```
Usage:
  grpc-health-checking [flags]

Flags:
      --delay-unhealthy-sec int        Number of seconds to delay before start reporting NOT_SERVING, negative value indicates never. (default -1)
  -h, --help                           help for grpc-health-checking
      --http-port int                  Port number for the /make-serving, /make-not-serving and /healthcheck. (default 8080)
      --log-flush-frequency duration   Maximum number of seconds between log flushes (default 5s)
      --port int                       Port number. (default 8000)
      --service string                 Service name to register the health check for.
  -v, --v Level                        number for the log level verbosity
      --vmodule moduleSpec             comma-separated list of pattern=N settings for file-filtered logging (only works for the default text log format)
```
 
## Access the endpoints

Set the HOST environment variable for convenience

```bash
HOST=localhost
```
We can use the `curl` to access HTTP Endpoint.

We can use the [grpcurl](https://github.com/fullstorydev/grpcurl) to access GRPC Endpoint.

### HTTP Endpoint: `/healthcheck`

Access HTTP Health Check

```bash
curl $HOST:8080/healthcheck
```

Output should be like:

```
2m55.563755666s 
```

### HTTP Endpoint: `/make-serving`

Make GRPC Health Check serving

```bash
curl $HOST:8080/make-serving
```

### HTTP Endpoint: `/make-not-serving`

Make GRPC Health Check not serving

```bash
curl $HOST:8080/make-not-serving
```

### GRPC Endpoint: `Services List`

List GRPC Services with reflection.

```bash
grpcurl -plaintext $HOST:8000 list
```

Output should be:

```
grpc.health.v1.Health
grpc.reflection.v1.ServerReflection
grpc.reflection.v1alpha.ServerReflection
```

### GRPC Endpoint: `grpc.health.v1.Health/Check`

Check GRPC Service Healthy status.

```bash
grpcurl -plaintext $HOST:8000 grpc.health.v1.Health/Check
```

If serving:

```
{
  "status": "SERVING"
}
```

Otherwise:

```
{
  "status": "NOT_SERVING"
}
```

## Containerize

Build image

```bash
docker build -t grpc-health-checking .
```

Run image with default expose ports

```bash
docker run -it \
  -p 8000:8000 \
  -p 8080:8080 \
  grpc-health-checking
```

Run image with customize ports

```bash
docker run -it \
  -p 18000:18000 \
  -p 18080:18080 \
  grpc-health-checking --port 18000 --http-port 18080
```

You can also use the pre-build amd64 container image

```
ghcr.io/timfanda35/grpc-health-checking
```
