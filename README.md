# GitOps Configurer

![Test Workflow](https://github.com/kadras-io/gitops-configurer/actions/workflows/test.yml/badge.svg)
![Release Workflow](https://github.com/kadras-io/gitops-configurer/actions/workflows/release.yml/badge.svg)
[![The SLSA Level 3 badge](https://slsa.dev/images/gh-badge-level3.svg)](https://slsa.dev/spec/v1.0/levels)
[![The Apache 2.0 license badge](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Follow us on Bluesky](https://img.shields.io/static/v1?label=Bluesky&message=Follow&color=1DA1F2)](https://bsky.app/profile/kadras.bsky.social)

A Carvel package that onboards a cluster to GitOps. It configures [Carvel kapp-controller](https://carvel.dev/kapp-controller) or [Flux](https://fluxcd.io) to keep the cluster in sync with the Kubernetes manifests stored in a Git repository or packaged as an OCI artifact, following a single-tenant monorepo approach.

## ✨&nbsp; What's Included

* **Two controllers**. The manifests are reconciled either by a kapp-controller `App`, which renders them with ytt and kbld and deploys them with kapp, or by a Flux `Kustomization`.
* **Two sources**. The manifests are fetched from a Git repository or from an OCI artifact, selected by tag, semver range, or digest.

| `controller` | `source` | Resources |
|--------------|----------|-----------|
| `flux` (default) | `git` (default) | Flux `GitRepository` and `Kustomization` |
| `flux` | `oci` | Flux `OCIRepository` and `Kustomization` |
| `carvel` | `git` | kapp-controller `App` fetching the Git repository |
| `carvel` | `oci` | kapp-controller `App` fetching an imgpkg bundle |

## 🚀&nbsp; Getting Started

### Prerequisites

* Kubernetes 1.35+
* Carvel [`kctrl`](https://carvel.dev/kapp-controller/docs/latest/install/#installing-kapp-controller-cli-kctrl) CLI.
* Carvel [kapp-controller](https://carvel.dev/kapp-controller) deployed in your Kubernetes cluster. You can install it with Carvel [`kapp`](https://carvel.dev/kapp/docs/latest/install) (recommended choice) or `kubectl`.

```shell
kapp deploy -a kapp-controller -y \
  -f https://github.com/carvel-dev/kapp-controller/releases/latest/download/release.yml
```

### Dependencies

With the `flux` controller, GitOps Configurer requires the Flux source and kustomize controllers. You can install them with the [Flux](https://github.com/kadras-io/package-for-flux) package from the [Kadras package repository](https://github.com/kadras-io/kadras-packages). The `carvel` controller has no dependencies beyond kapp-controller.

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

The package requires the location of the manifests, so create a `values.yml` file first. See [Configuration](#configuration).

```yaml
git:
  url: https://github.com/kadras-io/my-gitops-repo
  path: clusters/staging
```

Install the GitOps Configurer package:

```shell
kctrl package install -i gitops-configurer \
  -p gitops-configurer.packages.kadras.io \
  -v ${VERSION} \
  -n kadras-system \
  --values-file values.yml
```

> **Note**
> You can find the `${VERSION}` value by retrieving the list of package versions available in the Kadras package repository installed on your cluster.
> 
> ```shell
> kctrl package available list -p gitops-configurer.packages.kadras.io -n kadras-system
> ```

Verify the installed packages and their status:

```shell
kctrl package installed list -n kadras-system
```

### Try It Out

With Flux installed, deploy the [podinfo](https://github.com/stefanprodan/podinfo) application from its OCI artifact:

```shell
cat > values.yml <<EOF
source: oci
oci:
  url: oci://ghcr.io/stefanprodan/manifests/podinfo
  semver: ">=6.0.0"
EOF

kctrl package install -i gitops-configurer \
  -p gitops-configurer.packages.kadras.io \
  -v ${VERSION} \
  -n kadras-system \
  --values-file values.yml
```

Check that the Kustomization is ready and the application is running:

```shell
kubectl get kustomization gitops-configurer -n kadras-system
kubectl get deployment podinfo -n kadras-system
```

## 📙&nbsp; Documentation

Documentation, tutorials and examples for this package are available in the [docs](docs) folder.
For documentation specific to the controllers, check out [carvel.dev](https://carvel.dev/kapp-controller/docs/latest/) and [fluxcd.io](https://fluxcd.io/flux).

* [Controllers](docs/controllers.md)
* [Sources and credentials](docs/sources.md)
* [Configuration and ytt overlays](docs/configuration.md)
* [Upgrading and uninstalling](docs/upgrade.md)
* [Verifying the release](docs/verify-release.md)

## 🎯&nbsp; Configuration

The GitOps Configurer package can be customized via a `values.yml` file.

```yaml
controller: flux
source: git
interval: 5m
git:
  url: https://github.com/kadras-io/my-gitops-repo
  branch: main
  path: clusters/staging
  secret_name: git-credentials
```

Reference the `values.yml` file from the `kctrl` command when installing or upgrading the package.

```shell
kctrl package install -i gitops-configurer \
  -p gitops-configurer.packages.kadras.io \
  -v ${VERSION} \
  -n kadras-system \
  --values-file values.yml
```

The generated resources can be customized beyond the values via ytt overlays. See [configuration.md](docs/configuration.md).

### Values

The GitOps Configurer package has the following configurable properties.

<details><summary>Configurable properties</summary>

<!-- values-table:start -->

| Config | Default | Description |
|--------|---------|-------------|
| `namespace` | `"kadras-system"` | The namespace in which to create the GitOps resources. It must exist. |
| `name` | `"gitops-configurer"` | The name of the GitOps resources. |
| `controller` | `"flux"` | The controller reconciling the manifests with the cluster: `carvel` creates a kapp-controller App, `flux` a Flux source and Kustomization. |
| `service_account` | `""` | The ServiceAccount in the same namespace whose permissions are used to deploy the manifests. Required with the `carvel` controller. With the `flux` controller, the kustomize controller uses its own permissions when empty. |
| `interval` | `"1m0s"` | The interval at which the source is fetched and the manifests reconciled with the cluster, as a Go duration. |
| `flux.prune` | `true` | Whether to delete the resources removed from the source. It also deletes all the resources applied by the Kustomization when it's deleted, including when uninstalling the package. |
| `flux.wait` | `true` | Whether to wait for the applied resources to become ready before marking the Kustomization as ready. |
| `flux.timeout` | `"1m0s"` | The timeout for applying the manifests and, with `flux.wait`, for the resources to become ready, as a Go duration. |
| `source` | `"git"` | Where the manifests are fetched from: `git` for a Git repository, `oci` for an OCI artifact (a Flux artifact with the `flux` controller, an imgpkg bundle with the `carvel` controller). |
| `git.url` | `""` | The URL of the Git repository. Required with the `git` source. |
| `git.branch` | `"main"` | The Git branch to check out. |
| `git.path` | `""` | The path within the Git repository containing the manifests. The root of the repository when empty. |
| `git.secret_name` | `""` | The name of the Secret in the same namespace holding the credentials to access the Git repository. See docs/sources.md for the format expected by each controller. |
| `oci.url` | `""` | The URL of the OCI artifact, with the `oci://` scheme. Required with the `oci` source. |
| `oci.tag` | `"latest"` | The tag of the OCI artifact. Ignored when `oci.semver` or `oci.digest` is set. |
| `oci.semver` | `""` | The semver range selecting the tag of the OCI artifact, like `1.x` or `>=1.0.0`. The highest matching tag is used. |
| `oci.digest` | `""` | The digest of the OCI artifact, like `sha256:5f2f...`. It takes precedence over `oci.tag`. |
| `oci.path` | `""` | The path within the OCI artifact containing the manifests. The root of the artifact when empty. |
| `oci.secret_name` | `""` | The name of the Secret in the same namespace holding the credentials to access the OCI registry. See docs/sources.md for the format expected by each controller. |
| `oci.provider` | `"generic"` | The provider used to authenticate with the OCI registry: `generic` for the credentials in `oci.secret_name`, or a cloud provider for workload identity. Cloud providers require the `flux` controller. |
| `oci.service_account` | `""` | The ServiceAccount in the same namespace used to authenticate with the OCI registry: its image pull secrets with the `generic` provider, its workload identity with a cloud provider. It requires the `flux` controller. |

<!-- values-table:end -->

</details>

## 🛠️&nbsp; Development

The development environment is defined with [devenv](https://devenv.sh). Enter it with `devenv shell`, or automatically with [direnv](https://direnv.net) after running `direnv allow`. Run `task --list` to see all the available tasks.

```shell
# Run the unit tests, which render the package and check the result without a cluster.
task test:config

# Create a local kind cluster and run the integration tests on it.
task cluster:setup
task test:integration

# Deploy the package from the local sources to the current cluster.
task dev

# Update the table of configurable values in this README after changing the values schema.
task docs:values
```

The unit tests are described in [test/unit/README.md](test/unit/README.md).

## 🛡️&nbsp; Security

The security process for reporting vulnerabilities is described in [SECURITY.md](SECURITY.md).

## 🖊️&nbsp; License

This project is licensed under the **Apache License 2.0**. See [LICENSE](LICENSE) for more information.
