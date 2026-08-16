# GitOps Configurer

![Test Workflow](https://github.com/kadras-io/gitops-configurer/actions/workflows/test.yml/badge.svg)
![Release Workflow](https://github.com/kadras-io/gitops-configurer/actions/workflows/release.yml/badge.svg)
[![The SLSA Level 3 badge](https://slsa.dev/images/gh-badge-level3.svg)](https://slsa.dev/spec/v1.0/levels)
[![The Apache 2.0 license badge](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Follow us on Bluesky](https://img.shields.io/static/v1?label=Bluesky&message=Follow&color=1DA1F2)](https://bsky.app/profile/kadras.bsky.social)

A Carvel package providing GitOps configuration (Carvel or Flux) for the Kadras Engineering Platform.
Currently, it supports a single-tenant monorepo approach where all Kubernetes manifests are stored in a single Git repository or packaged as a single OCI artifact.

Three setups are available via the `type` configuration value:

| `type` | Resources | Source |
|--------|-----------|--------|
| `carvel-app` | Carvel `App` | Git |
| `flux-kustomization` | Flux `GitRepository` + `Kustomization` | Git |
| `flux-oci-kustomization` | Flux `OCIRepository` + `Kustomization` | OCI registry |

## 🚀&nbsp; Getting Started

### Prerequisites

* Kubernetes 1.34+
* Carvel [`kctrl`](https://carvel.dev/kapp-controller/docs/latest/install/#installing-kapp-controller-cli-kctrl) CLI.
* Carvel [kapp-controller](https://carvel.dev/kapp-controller) deployed in your Kubernetes cluster. You can install it with Carvel [`kapp`](https://carvel.dev/kapp/docs/latest/install) (recommended choice) or `kubectl`.

  ```shell
  kapp deploy -a kapp-controller -y \
    -f https://github.com/carvel-dev/kapp-controller/releases/latest/download/release.yml
  ```

### Installation

Add the Kadras [package repository](https://github.com/kadras-io/kadras-packages) to your Kubernetes cluster:

  ```shell
  kctrl package repository add -r kadras-packages \
    --url ghcr.io/kadras-io/kadras-packages \
    -n kadras-system --create-namespace
  ```

<details><summary>Installation without package repository</summary>
The recommended way of installing the GitOps Configurer package is via the Kadras <a href="https://github.com/kadras-io/kadras-packages">package repository</a>. If you prefer not using the repository, you can add the package definition directly using <a href="https://carvel.dev/kapp/docs/latest/install"><code>kapp</code></a> or <code>kubectl</code>.

  ```shell
  kubectl create namespace kadras-system
  kapp deploy -a gitops-configurer-package -n kadras-system -y \
    -f https://github.com/kadras-io/gitops-configurer/releases/latest/download/metadata.yml \
    -f https://github.com/kadras-io/gitops-configurer/releases/latest/download/package.yml
  ```
</details>

Install the GitOps Configurer package:

  ```shell
  kctrl package install -i gitops-configurer \
    -p gitops-configurer.packages.kadras.io \
    -v ${VERSION} \
    -n kadras-system
  ```

> **Note**
> You can find the `${VERSION}` value by retrieving the list of package versions available in the Kadras package repository installed on your cluster.
> 
>   ```shell
>   kctrl package available list -p gitops-configurer.packages.kadras.io -n kadras-system
>   ```

Verify the installed packages and their status:

  ```shell
  kctrl package installed list -n kadras-system
  ```

## 📙&nbsp; Documentation

Documentation, tutorials and examples for this package are available in the [docs](docs) folder.

## 🎯&nbsp; Configuration

The GitOps Configurer package can be customized via a `values.yml` file.

  ```yaml
  type: flux-kustomization
  git:
    url: "https://github.com/kadras-io/my-gitops-repo"
    path: "clusters/staging"
    secret_name: "github-token-secret"
  ```

Reference the `values.yml` file from the `kctrl` command when installing or upgrading the package.

  ```shell
  kctrl package install -i gitops-configurer \
    -p gitops-configurer.packages.kadras.io \
    -v ${VERSION} \
    -n kadras-system
    --values-file values.yml
  ```

### Values

The GitOps Configurer package has the following configurable properties.

<details><summary>Configurable properties</summary>

| Config | Default | Description |
|-------|-------------------|-------------|
| `namespace` | `kadras-system` | The namespace where the GitOps resource should be installed. |
| `name` | `gitops-configurer` | The name of the GitOps resource. |
| `type` | `carvel-app` | The type of GitOps controller to use. Options: `carvel-app`, `flux-kustomization`, `flux-oci-kustomization`. |
| `service_account` | `""` | The `ServiceAccount` used by the GitOps controller to reconcile changes to the cluster. |
| `git.url` | `""` | The URL of the Git repository to synchronize in the cluster. |
| `git.branch` | `main` | The Git branch to check out and synchronize. |
| `git.path` | `""` | The path within the Git repository containing the manifests to reconcile with the cluster. |
| `git.secret_name` | `""` | The name of the Secret in the same namespace holding the credentials to access the Git server. The credentials should provide read-only access to the Git server. |
| `oci.url` | `""` | The URL of the OCI artifact to synchronize in the cluster. It must use the `oci://` scheme. Example: `oci://ghcr.io/kadras-io/my-gitops-artifact`. |
| `oci.tag` | `latest` | The OCI artifact tag to pull and synchronize. Ignored when either `oci.semver` or `oci.digest` is configured. |
| `oci.semver` | `""` | The semver range used to select which OCI artifact tag to pull and synchronize. Example: `1.x`. Ignored when `oci.digest` is configured. |
| `oci.digest` | `""` | The digest of the OCI artifact to pull and synchronize. Example: `sha256:5f2f...`. It takes precedence over `oci.tag` and `oci.semver`. |
| `oci.path` | `""` | The path within the OCI artifact containing the manifests to reconcile with the cluster. |
| `oci.secret_name` | `""` | The name of the Secret in the same namespace holding the credentials to access the OCI registry. The credentials should provide read-only access to the OCI registry. |
| `oci.provider` | `generic` | The provider used for authenticating with the OCI registry. Use `generic` for static credentials via `oci.secret_name`, or a cloud provider for workload identity. Options: `generic`, `aws`, `azure`, `gcp`. |
| `oci.service_account` | `""` | The name of the ServiceAccount in the same namespace used to authenticate with the OCI registry. With the `generic` provider, its image pull secrets are used. With a cloud provider, it is used for workload identity. |
| `sync_period` | `1m0s` | The interval at which the GitOps controller should synchronize changes from Git. The format is a Go duration string. Example: `1m0s`. |

</details>

## 🛡️&nbsp; Security

The security process for reporting vulnerabilities is described in [SECURITY.md](SECURITY.md).

## 🖊️&nbsp; License

This project is licensed under the **Apache License 2.0**. See [LICENSE](LICENSE) for more information.
