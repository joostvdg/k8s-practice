# Continuous Delivery for Kubernetes

These are my notes and practice files for the book [Continuous Delivery for Kubernetes](https://www.manning.com/books/continuous-delivery-for-kubernetes).

## Goal

> Deliver useful, working software to users as quickly as possible by organising teams to build and deploy in an automated way Cloud-Native applications that run in cloud-agnostix setup."

## Chapter 1

### Install App

```sh
helm repo add fmtok8s https://salaboy.github.io/helm/
```

```sh
helm repo update
```

```sh
helm install app fmtok8s/fmtok8s-app --namespace fmtok8s --create-namespace
```

Have to enable Call For Papers in the back office.
Can do that by giving the API Gateway component an environment variable for the feature:

* `FEATURE_C4P_ENABLED="true"` (for call for papers)
* `FEATURE_TICKETS_ENABLED="true"` (for tickets)

Add node selector for AMD64 arch, as it does not support anything else right now:

```yaml
      nodeSelector:
        kubernetes.io/arch: amd64
```

## Chapter 2?

Generate some test events:

```sh
curl -X POST http://localhost/api/test
```

This URL does not seem to exist?
https://github.com/salaboy/fmtok8s-api-gateway/blob/main/src/main/java/com/salaboy/conferences/site/ApiGatewayService.java

List of Approved/Reject is still visible in Admin frontend.
But they are no longer in the frontend agenda.

Not entirely clear if all that is addressed is easily relatable to CI/CD on Kubernetes.

Perhaps introduce some of the other parts of the application in later stages?

## Chapter 3

Diagram like InnerLoop + OuterLoop would be a good addition.
Is there a difference between your Environment Pipeline and tools such as ArgoCD and Flux?

## General Feedback

It seems we have CI/CD on multiple levels:

* applications (services)
* environments
* platform? <-- not mentioned in the book (until Chapter 3 at least)
  * might make sense to recognize as well

When installing tekton into the cluster, it is missing `helm repo update`.

Should we add the Task to the cluster prior to starting the task?

Full service pipeline link is wrong, should be: https://github.com/salaboy/from-monolith-to-k8s/blob/main/tekton/resources/service-pipeline.yaml

## Chapter 4

* Maybe mention Artifacthub.io for finding Helm charts?
* Maybe add some pointers what to look at for finding good quality Helm charts?

### Postgresql Datasource

The key reference in the secret is `postgres-password` and not `postgresql-password`.

`SPRING_DATASOURCE_DRIVERCLASSNAME` is misspelled, it should be `SPRING_DATASOURCE_DRIVER_CLASS_NAME`, see: https://stackoverflow.com/questions/36286287/is-it-possible-to-set-spring-datasource-driver-class-name-via-environment-variab


```yaml
- name: SPRING_DATASOURCE_PASSWORD
  valueFrom:
    secretKeyRef:
      key: postgres-password
      name: postgresql
```

```sh
Caused by: org.hibernate.HibernateException: Access to DialectResolutionInfo cannot be null when 'hibernate.dialect' not set
 at org.hibernate.engine.jdbc.dialect.internal.DialectFactoryImpl.determineDialect(DialectFactoryImpl.java:100) ~[hibernate-core-5.6.3.Final.jar!/:5.6.3.Final]
 at org.hibernate.engine.jdbc.dialect.internal.DialectFactoryImpl.buildDialect(DialectFactoryImpl.java:54) ~[hibernate-core-5.6.3.Final.jar!/:5.6.3.Final]
 at org.hibernate.engine.jdbc.env.internal.JdbcEnvironmentInitiator.initiateService(JdbcEnvironmentInitiator.java:138) ~[hibernate-core-5.6.3.Final.jar!/:5.6.3.Final]
 at org.hibernate.engine.jdbc.env.internal.JdbcEnvironmentInitiator.initiateService(JdbcEnvironmentInitiator.java:35) ~[hibernate-core-5.6.3.Final.jar!/:5.6.3.Final]
 at org.hibernate.boot.registry.internal.StandardServiceRegistryImpl.initiateService(StandardServiceRegistryImpl.java:101) ~[hibernate-core-5.6.3.Final.jar!/:5.6.3.Final]
 at org.hibernate.service.internal.AbstractServiceRegistryImpl.createService(AbstractServiceRegistryImpl.java:263) ~[hibernate-core-5.6.3.Final.jar!/:5.6.3.Final]
 ... 41 common frames omitted
 ```

```sh
spring.jpa.database-platform=org.hibernate.dialect.PostgreSQLDialect 
```

Which would translate to:

```yaml
- name: SPRING_JPA_DATABASE_PLATFORM
  value: org.hibernate.dialect.PostgreSQLDialect
```

And not `SPRING_DATASOURCE_PLATFORM`.



## Chapter 5

Command to patch knative serving to support header based routing fails:

```sh
zsh: command not found: kubectl patch cm config-features 
```

Might be just my ZSH shell?

But this worked for me:

```sh
kubectl patch cm config-features --patch-file tag-header-based-routing-patch.yaml --namespace knative-serving
```

### Knative

#### CRDs

```sh
kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.5.0/serving-crds.yaml
```

#### Core Components

```sh
kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.5.0/serving-core.yaml
```

#### Networking with Contour

Not installed (as Contour is already running):

```sh
kubectl apply -f https://github.com/knative/net-contour/releases/download/knative-v1.5.0/contour.yaml
```

Knative Contour Controller:

```sh
kubectl apply -f https://github.com/knative/net-contour/releases/download/knative-v1.5.0/net-contour.yaml
```

Patch knative serving to use contour.

```sh
kubectl patch configmap/config-network \
  --namespace knative-serving \
  --type merge \
  --patch '{"data":{"ingress-class":"contour.ingress.networking.knative.dev"}}'
```

Add default serving domain off `sslip.io`.

```sh
kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.5.0/serving-default-domain.yaml
```

To be able to use these addresses, you need the following:

* use one the ip addresses used by your LoadBalancer
  * example: `fmtok8s.192.168.178.95.sslip.io`
* let Chrome use a different DNS server for "secure DNS", for example CloudFlare


#### HPA

```sh
kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.5.0/serving-hpa.yaml
```

#### Another Fix?

```sh
kubectl patch configmap/config-domain \
  --namespace knative-serving \
  --type merge \
  --patch '{"data":{"192.168.178.95.sslip.io":""}}'
```

#### For Contour

For `Ingress` and `HTTPProxy` resources, you have to add an annotation:

```yaml
  annotations:
    projectcontour.io/ingress.class: contour-external
```

#### Enable Header Based Routing

```sh
kubectl patch cm config-features --patch '{"data":{"tag-header-based-routing":"Enabled"}}' --namespace knative-serving
```

Create `tag-header-based-routing-patch.yaml`

```yaml
{"data":{"tag-header-based-routing":"Enabled"}}
```

```sh
kubectl patch cm config-features --patch-file tag-header-based-routing-patch.yaml --namespace knative-serving
```

## Hey

```sh
export HEY_URL=
```

```sh
 kubectl run tmp-hey \
  --rm -i --tty --image ricoli/hey \
  --namespace test \
  --overrides='{"spec": { "nodeSelector": {"kubernetes.io/hostname": "watermelon"}}}' \
  ${HEY_URL}
```

```sh
kubectl run tmp-hey \
  --rm -i --tty --image ricoli/hey \
  --namespace test \
  --overrides='{"spec": { "nodeSelector": {"kubernetes.io/hostname": "watermelon"}}}' \
  --  -c 500 -z 5m http://go-demo.fmtok8s
```

## Chapter 6

* https://github.com/salaboy/from-monolith-to-k8s/tree/master/cloudevents
* https://github.com/salaboy/fmtok8s-java-cloudevents
* https://github.com/salaboy/fmtok8s-go-cloudevents
* https://github.com/cloudevents/sdk-go
* https://spring.io/blog/2020/12/10/cloud-events-and-spring-part-1
* https://tanzu.vmware.com/developer/tv/spring-live/0034/
* https://knative.dev/docs/install/

Shouldn't we install knative serving at some point?

Broker config does not seem to work?

### Install knative serving

* Installl CRDs
* Install Core

```sh
kubectl apply -f https://github.com/knative/eventing/releases/download/knative-v1.5.1/eventing-crds.yaml
```

```sh
kubectl apply -f https://github.com/knative/eventing/releases/download/knative-v1.5.1/eventing-core.yaml
```

```sh
kubectl get pods -n knative-eventing
```

### MT Channel

What does do/mean?

```sh
kubectl apply -f https://github.com/knative/eventing/releases/download/knative-v1.5.1/mt-channel-broker.yaml
```

### RabbitMQ

Install RabbitMQ as described here: https://github.com/knative-sandbox/eventing-rabbitmq/tree/main/docs/broker


* https://artifacthub.io/packages/helm/bitnami/rabbitmq-cluster-operator
* https://github.com/knative-sandbox/eventing-rabbitmq/tree/main/samples/broker-trigger/quick-setup
* https://artifacthub.io/packages/helm/bitnami/rabbitmq-cluster-operator
* create `rabbitmq-values.yaml`

```yaml
clusterOperator:
  nodeSelector: 
    kubernetes.io/arch: amd64
msgTopologyOperator:
  nodeSelector: 
    kubernetes.io/arch: amd64

global:
  storageClass: longhorn
```

```sh
kubectl create namespace rabbitmq
```

```sh
helm install -n rabbitmq rabbitmq bitnami/rabbitmq-cluster-operator --values rabbitmq-values.yaml
```

### RabbitMQ Broker

```sh
kubectl apply --filename https://github.com/knative-sandbox/eventing-rabbitmq/releases/latest/download/rabbitmq-broker.yaml
```

###  Broker Example

* patch existing services
* install sockey
* apply trigger
* install fmtok8s tickets

* https://github.com/salaboy/fmtok8s-tickets/blob/main/charts/fmtok8s-tickets/Chart.yaml
* https://github.com/salaboy/from-monolith-to-k8s/blob/main/knative/knative-eventing-example.md

#### Install Sockey

```sh
kubectl apply -f https://github.com/n3wscott/sockeye/releases/download/v0.7.0/release.yaml
```

#### API Gateway

```yaml
            - name: AGENDA_SERVICE
              value:  http://fmtok8s-agenda.fmtok8s.svc.cluster.local
            - name: C4P_SERVICE
              value: http://fmtok8s-c4p.fmtok8s.svc.cluster.local
            - name: EMAIL_SERVICE
              value: http://fmtok8s-email.fmtok8s.svc.cluster.local
            - name: EVENTS_ENABLED
              value: "true"
            - name: K_SINK
              value: http://default-broker-ingress.fmtok8s.svc.cluster.local
```

#### Agenda

```yaml
            - name: EVENTS_ENABLED
              value: "true"
            - name: K_SINK
              value: http://default-broker-ingress.fmtok8s.svc.cluster.local
```

#### C4P

```yaml
            - name: AGENDA_SERVICE
              value:  http://fmtok8s-agenda.fmtok8s.svc.cluster.local
            - name: EMAIL_SERVICE
              value: http://fmtok8s-email.fmtok8s.svc.cluster.local
            - name: EVENTS_ENABLED
              value: "true"
            - name: K_SINK
              value: http://default-broker-ingress.fmtok8s.svc.cluster.local
```

#### Email

```yaml
            - name: EVENTS_ENABLED
              value: "true"
            - name: K_SINK
              value: http://default-broker-ingress.fmtok8s.svc.cluster.local
```

#### Trigger

```yaml
apiVersion: eventing.knative.dev/v1
kind: Trigger
metadata:
  name: wildcard-trigger
  namespace: default
spec:
  broker: default
  subscriber:
    uri: http://sockeye.default.svc.cluster.local
```

#### Fmtok8s Tickets

```yaml
fmtok8s-tickets-service:
  knativeDeploy: true
fmtok8s-payments-service:
  knativeDeploy: true
fmtok8s-queue-service:
  knativeDeploy: true
```

```sh
helm install conference-tickets fmtok8s/fmtok8s-tickets --namespace fmtok8s --values fmtok8s-tickets-values.yaml
```

## Others

### Patch Knative Service To Allow NodeSelector

NodeSelectors and Affinity rules are disabled by default.
To enable them, you have to configure the enablement in your knative serving config map. As described here: https://github.com/knative/serving/issues/11388#issuecomment-845787934

```sh
kubectl edit configmap config-domain -n knative-serving
```

```yaml
apiVersion: v1
data:
  kubernetes.podspec-nodeselector: "enabled"
  kubernetes.podspec-tolerations: "enabled"
  _example: |-
```