kind create cluster --name edge-cluster --config kind-edge-cluster-config.yaml

# Build microservices
docker build -t dev.local/edge-service:0.1 .

# Load containers into kubernetes cluster (kind)
kind load docker-image dev.local/edge-service:0.1 --name edge-cluster

# Configure Knative Serving
kubectl apply -f https://github.com/knative/serving/releases/download/v0.26.0/serving-crds.yaml --wait
kubectl apply -f https://github.com/knative/serving/releases/download/v0.26.0/serving-core.yaml
kubectl get pods --namespace knative-serving

# Configure Knative Istio Service Mesh
kubectl apply -f https://github.com/knative/net-istio/releases/download/v0.26.0/istio.yaml
kubectl apply -f https://github.com/knative/net-istio/releases/download/v0.26.0/net-istio.yaml
kubectl apply -f https://github.com/knative/net-istio/releases/download/v0.26.0/net-istio.yaml
kubectl --namespace istio-system get service istio-ingressgateway
kubectl get pods --namespace knative-serving

# Configure Knative Eventing
kubectl apply -f https://github.com/knative/eventing/releases/download/v0.26.0/eventing-crds.yaml
kubectl apply -f https://github.com/knative/eventing/releases/download/v0.26.0/eventing-core.yaml
kubectl get pods --namespace knative-eventing

# Configure RabbitMQ Serverless Broker
# https://github.com/knative-sandbox/eventing-rabbitmq/blob/main/broker/README.md
kubectl apply -f https://github.com/rabbitmq/cluster-operator/releases/download/v1.9.0/cluster-operator.yml
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.5.4/cert-manager.yaml
kubectl apply -f https://github.com/rabbitmq/messaging-topology-operator/releases/download/v1.2.0/messaging-topology-operator-with-certmanager.yaml
kubectl apply -f https://github.com/rabbitmq/messaging-topology-operator/releases/download/v1.2.0/messaging-topology-operator-with-certmanager.yaml
kubectl apply -f https://github.com/knative-sandbox/eventing-rabbitmq/releases/download/v0.26.0/rabbitmq-broker.yaml

kubectl apply -f - << EOF
apiVersion: rabbitmq.com/v1beta1
kind: RabbitmqCluster
metadata:
  name: rokn
  namespace: default
spec:
  replicas: 1
EOF

kubectl apply -f - << EOF
  apiVersion: eventing.knative.dev/v1
  kind: Broker
  metadata:
    name: default
    annotations:
      eventing.knative.dev/broker.class: RabbitMQBroker
  spec:
    config:
      apiVersion: rabbitmq.com/v1beta1
      kind: RabbitmqCluster
      name: rokn
EOF

kubectl get brokers

# Read logs
kubectl logs subscriber-00001-deployment-67b7d4c556-gvslq -c user-container

kubectl logs edge-service-subscriber-00001-deployment-67f77b7b8c-z7x6c -c user-container

kubectl logs -l name=subscriber


# Install mosquitto broker
kubectl create namespace mqtt
kubectl apply -f broker/mosquitto/mosquitto.yaml --namespace mqtt
kubectl get pods,deployments,services -n mqtt
kubectl logs -l app=gateway-bridge -f --all-containers

kubectl port-forward --address 0.0.0.0 deployment.apps/mosquitto 1883:1883 -n mqtt

# Configure Kamelets
#kubectl create namespace camel-k
#kamel install -n camel-k --registry-insecure true --registry localhost:32000/v1
#kubectl get all -n camel-k

kubectl -n default create secret docker-registry external-registry-secret --docker-username agwermann --docker-password "Xande@100"
kamel install --olm=false -n default --global --registry docker.io --organization agwermann --registry-secret external-registry-secret

# logged on any namespace (--global flag)
#kamel init example.yaml
#kamel run example.yaml --dev

# Create Service Sink
kubectl apply -f services/edge-service-eventing-sink.yaml
kubectl apply -f resources/edge-event-handler-mqtt-source.yaml

# Edge Service
kubectl logs edge-service-v1-deployment-7756945f78-4jzkb edge-service

# Configure Apache Kamel resources
kubectl apply -f resources/mqtt-device-data-source-binding.yaml
kubectl apply -f resources/mqtt-service-data-source-binding.yaml
kubectl get pods --namespace mqtt

# Configure Broker Trigger and Sink
kubectl apply -f services/edge-service-eventing-sink.yaml
kubectl apply -f services/edge-service-eventing-trigger.yaml

kind delete cluster --name edge-cluster

# Channel
kubectl apply -f channel/channel.yaml
kubectl apply -f channel/kamelet-binding-channel.yaml 
kubectl apply -f channel/channel-subscription.yaml 

kamel describe integration mqtt-source-binding


kubectl delete -f - << EOF
apiVersion: camel.apache.org/v1alpha1
kind: KameletBinding
metadata:
  name: mqtt-source-binding
spec:
  source:
    ref:
      kind: Kamelet
      apiVersion: camel.apache.org/v1alpha1
      name: mqtt-source
    properties:
      brokerUrl: "tcp://mosquitto:1883"
      topic: "mytopic"
  sink:
    ref:
      kind: Broker
      apiVersion: messaging.knative.dev/v1
      name: default
    properties:
      type: "dev.knative.sources.ping"
EOF

kubectl apply -f - << EOF
apiVersion: camel.apache.org/v1alpha1
kind: KameletBinding
metadata:
  name: mqtt-source-binding
spec:
  source:
    ref:
      kind: Kamelet
      apiVersion: camel.apache.org/v1alpha1
      name: mqtt-source
    properties:
      brokerUrl: "tcp://mosquitto:1883"
      topic: "mytopic"
  sink:
    ref:
      kind: Broker
      apiVersion: messaging.knative.dev/v1
      name: default
EOF


kubectl apply -f - << EOF
apiVersion: camel.apache.org/v1alpha1
kind: KameletBinding
metadata:
  name: mqtt-source-binding
spec:
  source:
    ref:
      kind: Kamelet
      apiVersion: camel.apache.org/v1alpha1
      name: mqtt-source
    properties:
      brokerUrl: mosquitto:1883
      topic: mytopic
  sink:
    ref:
      kind: Broker
      apiVersion: messaging.knative.dev/v1
      name: default
    properties:
      type: mqtt
EOF

kubectl apply -f - << EOF
apiVersion: camel.apache.org/v1alpha1
kind: KameletBinding
metadata:
  name: mqtt-source-binding
spec:
  source:
    ref:
      kind: Kamelet
      apiVersion: camel.apache.org/v1alpha1
      name: mqtt-source
    properties:
      brokerUrl: "tcp://mosquitto:1883"
      topic: "mytopic"
  sink:
    ref:
      kind: Service
      apiVersion: serving.knative.dev/v1
      name: subscriber
EOF
