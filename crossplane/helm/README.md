# Crossplane and Helm

## Tanzu

Tanzu's community edition comes with the following tools:

* cert-manager
* Contour
* ExternalDNS
* Fluent Bit
* Gatekeeper
* Grafana
* Knative Serving
* Multus CNI (Calico?)
* Prometheus
* Velero

Source: https://tanzucommunityedition.io/packages/

## Fluent Bit

### Installation

* https://docs.fluentbit.io/manual/installation/kubernetes#installation

NOTE: for Kubernetes < 1.22

```sh
kubectl create namespace logging
kubectl create -f https://raw.githubusercontent.com/fluent/fluent-bit-kubernetes-logging/master/fluent-bit-service-account.yaml
kubectl create -f https://raw.githubusercontent.com/fluent/fluent-bit-kubernetes-logging/master/fluent-bit-role.yaml
kubectl create -f https://raw.githubusercontent.com/fluent/fluent-bit-kubernetes-logging/master/fluent-bit-role-binding.yaml
kubectl create -f https://raw.githubusercontent.com/fluent/fluent-bit-kubernetes-logging/master/output/elasticsearch/fluent-bit-configmap.yaml
```

## Gotchas

### Cannot create namespaces

The default installation of Crossplane does not give it permissions to create new namespaces.
Which sounds like and essential permission for managing Helm charts?

```sh
Warning  CannotCreateExternalResource  2m51s (x17 over 8m54s)  managed/release.helm.crossplane.io  failed to create namespace for release: namespaces is forbidden: User "system:serviceaccount:crossplane-system:crossplane-provider-helm-17449053f350" cannot create resource "namespaces" in API group "" at the cluster scope
```

#### ClusterRoleBinding - Admin

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: crossplane-helm-admin-creator
subjects:
- kind: ServiceAccount
  name: crossplane-provider-helm-17449053f350
  namespace: crossplane-system
roleRef:
  kind: ClusterRole
  name: admin
  apiGroup: rbac.authorization.k8s.io
```
