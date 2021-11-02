# Tekton Tutorial

https://tanzu.vmware.com/developer/guides/tekton-gs-p1/

## Installation

Install Tekton

```sh
kubectl apply --filename https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
```

Create a dockerhub secret.

```sh
DHUB_USER=
DHUB_PASS=
DHUB_EMAIL=
```


```sh
kubectl create secret docker-registry dockercreds --docker-server=https://index.docker.io/v1/ --docker-username=${DHUB_USER} --docker-password=${DHUB_PASS} --docker-email ${DHUB_EMAIL}
```

## Cloud Native Build Packs

* https://tanzu.vmware.com/developer/guides/cnb-what-is/

## Dashboard

### Install

```sh
kubectl apply --filename https://github.com/tektoncd/dashboard/releases/latest/download/tekton-dashboard-release.yaml
```

### Proxy

```sh
kubectl proxy --port=8080
```

```sh
open http://localhost:8080/api/v1/namespaces/tekton-pipelines/services/tekton-dashboard:http/proxy/#/pipelineruns
```

## Tanzu Tekton + Build Packs Is Outdated

```yaml
completionTime: '2021-10-24T21:50:36Z'
conditions:
  - lastTransitionTime: '2021-10-24T21:50:36Z'
    message: >-
      invalid input resources for task buildpacks: TaskRun's declared resources
      didn't match usage in Task: [source]
    reason: TaskRunValidationFailed
    status: 'False'
    type: Succeeded
```

