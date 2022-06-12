# Kubernetes Developer Platform

* https://www.thoughtworks.com/radar
* https://modernapps.ninja/tkoplaceholder_tk8606/docs/tko-overview/tko-intro/
* https://tanzu.vmware.com/application-platform
* Progressive Delivery
    * Canary Releases
    * Feature Flags
    * Knative (Up & Running book?!)
* Preview Environments
* "DevSecOps"
* Observability (Platform vs. Application)
* DORA metrics

## Required Capabilities


## Processes & Techniques


## Technologies & Packages

## Mini Setup

* Longhorn
* Docker Registry
* Chartmuseum
* Sonatype Nexus?
* Gitea
* Cert-manager
* Flux
* Tekton
* Knative
* Trivy
* SBOM thingy?
* LDAP + Keycloak?
    * Is Keycloak light now?

## Event Tracker

* Cartographer Events
* Tekton Events
* TAP Events
* Others?

Give collect and track events, so even if you don't know how things relate you have an idea what is going on.

## Tracker Requirements

### Application

* unique ID
* certificate?
* metadata
    * labels
    * owner
    * display name
* annotations
* one or more URIs for source
* parent reference
* zero or more references for environments
    * with metadata
    * when
    * how
    * owner (of the binding)
* SBOM

### Environment

* unique ID
* certificate?
* metadata
    * labels
    * owner
    * display name
* annotations
* one or more URIs for source
* parent reference
* zero or more references for applications
    * with metadata
    * when
    * how
    * owner (of the binding)
* SBOM