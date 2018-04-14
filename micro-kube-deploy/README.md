# Micro on Kubernetes [![License](https://img.shields.io/:license-apache-blue.svg)](https://opensource.org/licenses/Apache-2.0) [![GoDoc](https://godoc.org/github.com/micro/kubernetes/go/micro?status.svg)](https://godoc.org/github.com/micro/kubernetes) [![Travis CI](https://api.travis-ci.org/micro/kubernetes.svg?branch=master)](https://travis-ci.org/micro/kubernetes) [![Go Report Card](https://goreportcard.com/badge/micro/kubernetes)](https://goreportcard.com/report/github.com/micro/kubernetes)

Micro on Kubernetes is kubernetes native micro.

Micro is a microservice toolkit. Kubernetes is a container orchestrator.

Together they provide the foundations for a microservice platform.

## Features

- No external dependencies
- K8s native services
- Service mesh integration
- gRPC communication protocol
- Pre-initialised micro images
- Healthchecking sidecar

## Getting Started

- [Installing Micro](#installing-micro)
- [Writing a Service](#writing-a-service)
- [Deploying a Service](#deploying-a-service)
- [Writing a Web Service](#writing-a-web-service)
- [Healthchecking](#healthchecking-sidecar)
- [Load Balancing](#load-balancing)
- [Using Service Mesh](#using-service-mesh)
- [Contribute](#contribute)

## Installing Micro


```
go get github.com/micro/kubernetes/cmd/micro
```

or

```
docker pull microhq/micro:kubernetes
```

For go-micro

```
import "github.com/micro/kubernetes/go/micro"
```

## Writing a Service

Write a service as you would any other [go-micro](https://github.com/micro/go-micro) service.

```go
import (
	"github.com/micro/go-micro"
	k8s "github.com/micro/kubernetes/go/micro"
)

func main() {
	service := k8s.NewService(
		micro.Name("greeter")
	)
	service.Init()
	service.Run()
}
```

## Deploying a Service

Here's an example k8s deployment for a micro service

### Create a Deployment

```
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  namespace: default
  name: greeter
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: greeter-srv
    spec:
      containers:
        - name: greeter
          command: [
		"/greeter-srv",
		"--server_address=0.0.0.0:8080",
		"--broker_address=0.0.0.0:10001"
	  ]
          image: microhq/greeter-srv:kubernetes
          imagePullPolicy: Always
          ports:
          - containerPort: 8080
            name: greeter-port
```

Deploy with kubectl

```
kubectl create -f greeter.yaml
```

### Create a Service

```
apiVersion: v1
kind: Service
metadata:
  name: greeter
  labels:
    app: greeter
spec:
  ports:
  - port: 8080
    protocol: TCP
  selector:
    app: greeter
```

Deploy with kubectl

```
kubectl create -f greeter-svc.yaml
```

## Writing a Web Service

Write a web service as you would any other [go-web](https://github.com/micro/go-web) service.

```go
import (
	"net/http"

	"github.com/micro/go-web"
	k8s "github.com/micro/kubernetes/go/web"
)

func main() {
	service := k8s.NewService(
		web.Name("greeter"),
	)

	service.HandleFunc("/greeter", func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte(`hello world`))
	})

	service.Init()
	service.Run()
}
```

## Healthchecking Sidecar

The healthchecking sidecar exposes `/health` as a http endpoint and calls the rpc endpoint `Debug.Health` on a service. 
Every go-micro service has a built in Debug.Health endpoint.

### Install

```
go get github.com/micro/health
```

or

```
docker pull microhq/health:kubernetes
```

### Run

Run e.g healthcheck greeter service with address localhost:9091

```
health --server_name=greeter --server_address=localhost:9091
```

Call the healthchecker on localhost:8080

```
curl http://localhost:8080/health
```

### K8s Deployment

Add the healthchecking sidecar to a kubernetes deployment

```
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  namespace: default
  name: greeter
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: greeter-srv
    spec:
      containers:
        - name: greeter
          command: [
		"/greeter-srv",
		"--server_address=0.0.0.0:8080",
		"--broker_address=0.0.0.0:10001"
	  ]
          image: microhq/greeter-srv:kubernetes
          imagePullPolicy: Always
          ports:
          - containerPort: 8080
            name: greeter-port
        - name: health
          command: [
		"/health",
                "--health_address=0.0.0.0:8081",
		"--server_name=greeter",
		"--server_address=0.0.0.0:8080"
	  ]
          image: microhq/health:kubernetes
          livenessProbe:
            httpGet:
              path: /health
              port: 8081
            initialDelaySeconds: 3
            periodSeconds: 3
```

## Load Balancing

Micro includes client side load balancing by default but kubernetes also provides Service load balancing strategies. 
In **micro on kubernetes** we offload load balancing to k8s by using the [static selector](https://github.com/micro/go-plugins/tree/master/selector/static) and k8s services.

Rather than doing address resolution, the static selector returns the service name plus a fixed port e.g greeter returns greeter:8080. 
Read about the [static selector](https://github.com/micro/go-plugins/tree/master/selector/static).

This approach handles both initial connection load balancing and health checks since Kubernetes services stop routing traffic to unhealthy services, but if you want to use long lived connections such as the ones in gRPC protocol, a service-mesh like [Conduit](https://conduit.io/), [Istio](https://istio.io) and [Linkerd](https://linkerd.io/) should be prefered to handle service discovery, routing and failure. 

Note: The static selector is enabled by default.

### Usage

To manually set the static selector when running your service specify the flag or env var 

Note: This is already enabled by default

```
MICRO_SELECTOR=static ./service
```

or

```
./service --selector=static
```

### Deployment

An example deployment

```
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  namespace: default
  name: greeter
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: greeter-srv
    spec:
      containers:
        - name: greeter
          command: [
		"/greeter-srv",
		"--server_address=0.0.0.0:8080",
		"--broker_address=0.0.0.0:10001"
	  ]
          image: microhq/greeter-srv:kubernetes
          imagePullPolicy: Always
          ports:
          - containerPort: 8080
            name: greeter-port
```

Deploy with kubectl

```
kubectl create -f deployment-static-selector.yaml
```

### Service

The static selector offloads load balancing to k8s services. So ensure you create a k8s Service for each micro service. 

Here's a sample service

```
apiVersion: v1
kind: Service
metadata:
  name: greeter
  labels:
    app: greeter
spec:
  ports:
  - port: 8080
    protocol: TCP
  selector:
    app: greeter
```

Deploy with kubectl

```
kubectl create -f service.yaml
```

Calling micro service "greeter" from your service will route to the k8s service greeter:8080.

## Using Service Mesh

[Conduit](https://conduit.io/) is a service mesh which can be easily integrated with Micro on Kubernetes.

Note: Conduit is under heavy development and is not currently production ready.

### Install

In order to install conduit in your cluster you should first install Conduit CLI using

```curl https://run.conduit.io/install | sh```

And finaly add Conduit CLI binary to your $PATH.

```export PATH=$PATH:$HOME/.conduit/bin```

To install conduit you need a kubernetes cluster running version 1.8 or later. To setup RBAC clusterroles for conduit-controller, web dashboard, prometheus and grafana deployments run

```conduit install | kubectl apply -f -```

To check for conduit status run

```conduit check```

Once every component have been started you are able to start running services using conduit service mesh. To access conduit web dashboard where you can see your service mesh run 

```conduit dashboard```

### Deploy

To start deploying apps to use conduit it is important to use [static selector](https://github.com/micro/go-plugins/tree/master/selector/static) because conduit and other service meshes use kubernetes services as a service discovery mechanism.

To deploy greeter service with health checking and conduit sidecar you will not need to change anything. Use the same deployment as above.

```
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  namespace: default
  name: greeter
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: greeter-srv
    spec:
      containers:
        - name: greeter
          command: [
		"/greeter-srv",
		"--server_address=0.0.0.0:8080",
		"--broker_address=0.0.0.0:10001"
	  ]
          image: microhq/greeter-srv:kubernetes
          imagePullPolicy: Always
          ports:
          - containerPort: 8080
            name: greeter-port
        - name: health
          command: [
		"/health",
                "--health_address=0.0.0.0:8081",
		"--server_name=greeter",
		"--server_address=0.0.0.0:8080"
	  ]
          image: microhq/health:kubernetes
          livenessProbe:
            httpGet:
              path: /health
              port: 8081
            initialDelaySeconds: 3
            periodSeconds: 3
```

Use conduit inject to inject conduit-init container that will setup conduit-proxy's sidecar. Kubernetes will start to proxy traffic throught conduit-proxy that will handle discovery, visibility, failures..

```
conduit inject deployment.yaml | kubectl apply -f -
```

Now lets create a kubernetes service

```
apiVersion: v1
kind: Service
metadata:
  name: greeter
  labels:
    app: greeter
spec:
  ports:
  - port: 8080
    protocol: TCP
  selector:
    app: greeter
```

Deploy with kubectl

```
kubectl create -f service.yaml
```

Now your deployment is complete. Go to conduit's dashboard to look for this deployment and to check for inbound and outbound connections.

*If your service uses Websockets, MySQL and other protocols please read [conduit docs](https://conduit.io/adding-your-service/).*


## Contribute

We're looking for contributions from the community to help guide the development of Micro on Kubernetes

### TODO

- Add example multi-service application
- Add [go-config](https://github.com/micro/go-config) with k8s config map support
- Add k8s api extension for micro api
- Integrate [metaparticle](https://github.com/metaparticle-io/package)
- Add deployment command - `micro run app`
- Support for micro functions
