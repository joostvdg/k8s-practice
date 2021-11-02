# Crossplane on GCP

## Configure

* install Crossplane
* install GCP provider
* apply GCP provider configuration
* apply credential to ensure GCP provider can talk to your GCP project

Taken from Crossplane's [introduction docs](https://crossplane.io/docs/v1.5/getting-started/install-configure.html).

### Install Crossplane

```sh
kubectl create namespace crossplane-system
```

```sh
helm repo add crossplane-stable https://charts.crossplane.io/stable
helm repo update
```

### Install GCP Provider

```sh
kubectl crossplane install configuration registry.upbound.io/xp/getting-started-with-gcp:v1.5.0
```

### Add Credentials

For how to create this credentials file, see [Crossplane's docs](https://crossplane.io/docs/v1.5/getting-started/install-configure.html#get-gcp-account-keyfile).

```sh
kubectl create secret generic gcp-creds -n crossplane-system --from-file=creds=./creds.json
```

## Composition

* https://crossplane.io/docs/v1.5/guides/composition-revisions.html