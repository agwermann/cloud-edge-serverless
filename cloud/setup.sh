kind create cluster --name edge-cluster --config kind-edge-cluster-config.yaml

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

kubectl apply -f broker/rabbitmq/rabbitmq-cluster.yaml
kubectl apply -f broker/rabbitmq/rabbitmq-broker.yaml

kubectl get brokers