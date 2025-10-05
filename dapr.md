```sh
npm install -g @anthropic-ai/claude-code

git clone https://github.com/vfarcic/dot-ai-demo

cd dot-ai-demo

git pull

git fetch
```

FIXME: Create a branch

```sh
# git switch dapr

devbox shell
```

FIXME: Switch to newer tags

```sh
./dot.nu setup --dot-ai-tag 0.105.0 \
    --qdrant-run false --qdrant-tag 0.5.0
```

FIXME: Add to `dot.nu`

```sh
helm repo add dapr https://dapr.github.io/helm-charts/

helm repo update

helm upgrade --install dapr dapr/dapr \
    --version=1.16.0 \
    --namespace dapr-system \
    --create-namespace \
    --wait
```

FIXME: Switch to dot-ai

```sh
echo "
apiVersion: v1
kind: ConfigMap
metadata:
  name: pizza-init-sql
data:
  init.sql: |- 
    CREATE DATABASE dapr;
" | kubectl apply --filename -

# FIXME: Fuck it up
helm upgrade --install postgresql \
    oci://registry-1.docker.io/bitnamicharts/postgresql \
    --version 12.5.7 \
    --set "image.debug=true" \
    --set "primary.initdb.user=postgres" \
    --set "primary.initdb.password=postgres" \
    --set "primary.initdb.scriptsConfigMap=pizza-init-sql" \
    --set "global.postgresql.auth.postgresPassword=postgres" \
    --set "primary.persistence.size=1Gi" \
    --set "image.repository=bitnamilegacy/postgresql"

helm upgrade --install kafka \
    oci://registry-1.docker.io/bitnamicharts/kafka \
    --version 22.1.5 \
    --set "provisioning.topics[0].name=events-topic" \
    --set "provisioning.topics[0].partitions=1" \
    --set "persistence.size=1Gi" \
    --set "image.repository=bitnamilegacy/kafka"

echo '
apiVersion: apps/v1
kind: Deployment
metadata:
  name: pizza-kitchen-deployment
spec:
  selector:
    matchLabels:
      app: pizza-kitchen-service
  template:
    metadata:
      annotations:  
        dapr.io/app-id: kitchen-service
        dapr.io/app-port: "8080"
        dapr.io/enabled: "true"
        dapr.io/log-level: "debug"
      labels:
        app: pizza-kitchen-service
        app.kubernetes.io/name: pizza-kitchen-service
        app.kubernetes.io/part-of: pizza-kitchen-service
        app.kubernetes.io/version: 0.1.0
    spec:
      containers:
      - name: pizza-kitchen-service
        image: salaboy/pizza-kitchen:1.0.0-agentic-amd64
        imagePullPolicy: Always
        env:
        - name: SERVER_PORT
          value: "8080"
        - name: JAVA_OPTS
          value: "-XX:+UseParallelGC -XX:ActiveProcessorCount=1 -XX:MaxRAMPercentage=75 -XX:TieredStopAtLevel=1"   
        - name: PUB_SUB_NAME
          value: pubsub       
        - name: PUB_SUB_TOPIC
          value: topic  
        livenessProbe:
          httpGet:
            path: /actuator/health
            port: 8080
        readinessProbe:
          httpGet:
            path: /actuator/health
            port: 8080
        resources:
          limits:
            cpu: "1"
            memory: "2Gi"
          requests:
            cpu: "1"
            memory: "2Gi"
        ports:
        - containerPort: 8080
' | kubectl apply --filename -

echo '
apiVersion: apps/v1
kind: Deployment
metadata:
  name: pizza-delivery-deployment
spec:
  selector:
    matchLabels:
      app: pizza-delivery-service
  template:
    metadata:
      annotations:  
        dapr.io/app-id: delivery-service
        dapr.io/app-port: "8080"
        dapr.io/enabled: "true"
        dapr.io/log-level: "debug"
      labels:
        app: pizza-delivery-service
        app.kubernetes.io/name: pizza-delivery-service
        app.kubernetes.io/part-of: pizza-delivery-service
        app.kubernetes.io/version: 0.1.0
    spec:
      containers:
      - name: pizza-delivery-service
        image: salaboy/pizza-delivery:1.0.0-agentic-amd64
        imagePullPolicy: Always
        env:
        - name: SERVER_PORT
          value: "8080"
        - name: JAVA_OPTS
          value: "-XX:+UseParallelGC -XX:ActiveProcessorCount=1 -XX:MaxRAMPercentage=75 -XX:TieredStopAtLevel=1"   
        - name: PUB_SUB_NAME
          value: pubsub       
        - name: PUB_SUB_TOPIC
          value: topic    
        livenessProbe:
          httpGet:
            path: /actuator/health
            port: 8080
        readinessProbe:
          httpGet:
            path: /actuator/health
            port: 8080
        resources:
          limits:
            cpu: "1"
            memory: "2Gi"
          requests:
            cpu: "1"
            memory: "2Gi"
        ports:
        - containerPort: 8080
' | kubectl apply --filename -

# Replace [...] with your OpenAPI API key.
export OPENAI_API_KEY=[...]

echo "
apiVersion: apps/v1
kind: Deployment
metadata:
  name: pizza-store-deployment
spec:
  selector:
    matchLabels:
      app: pizza-store-service
  template:
    metadata:
      annotations:  
        dapr.io/app-id: pizza-store
        dapr.io/app-port: \"8080\"
        dapr.io/enabled: \"true\"
        dapr.io/log-level: \"debug\"
      labels:
        app: pizza-store-service
        app.kubernetes.io/name: pizza-store-service
        app.kubernetes.io/part-of: pizza-store-service
        app.kubernetes.io/version: 0.1.1
    spec:
      containers:
      - name: pizza-store-service
        image: salaboy/pizza-store:1.0.12-agentic-amd64
        imagePullPolicy: Always
        env:
        - name: SERVER_PORT
          value: \"8080\"
        - name: JAVA_OPTS
          value: \"-XX:+UseParallelGC -XX:ActiveProcessorCount=1 -XX:MaxRAMPercentage=75 -XX:TieredStopAtLevel=1\"
        - name: PUBLIC_IP
          value: localhost:8080
        - name: STATESTORE_NAME
          value: kvstore
        - name: OPENAI_API_KEY
          value: \"$OPENAI_API_KEY\"
        - name: DAPR_GRPC_ENDPOINT
          value: http://localhost:50001
        - name: DAPR_HTTP_ENDPOINT
          value: http://localhost:3500
        livenessProbe:
          httpGet:
            path: /actuator/health
            port: 8080
        readinessProbe:
          httpGet:
            path: /actuator/health
            port: 8080
        resources:
          limits:
            cpu: \"1\"
            memory: \"2Gi\"
          requests:
            cpu: \"1\"
            memory: \"2Gi\"
        ports:
        - containerPort: 8080
" | kubectl apply --filename -

echo '
apiVersion: v1
kind: Service
metadata:
  name: pizza-store
spec:
  selector:
    app: pizza-store-service
  ports:
  - port: 80
    targetPort: 8080
' | kubectl apply --filename -

echo '
apiVersion: dapr.io/v1alpha1
kind: Component
metadata:
  name: pubsub
spec:
  type: pubsub.kafka
  version: v1
  metadata:
  - name: brokers # Required. Kafka broker connection setting
    value:  kafka.default.svc.cluster.local:9092
  - name: authType
    value: "none"  
' | kubectl apply --filename -

echo '
apiVersion: dapr.io/v1alpha1
kind: Component
metadata:
  name: kvstore
spec:
  type: state.postgresql
  version: v1
  metadata:
  - name: connectionString
    value: "host=postgresql.default.svc.cluster.local user=postgres password=postgres port=5432 connect_timeout=10 database=dapr"
  - name: actorStateStore
    value: "true"  
' | kubectl apply --filename -

echo '
apiVersion: dapr.io/v1alpha1
kind: Subscription
metadata:
  name: pizza-store-subscription
spec:
  topic: topic
  route: /events
  pubsubname: pubsub
scopes: 
- pizza-store  
' | kubectl apply --filename -

kubectl port-forward svc/pizza-store 8080:80

open "http://localhost:8080"
```

```sh
source .env

claude
```
