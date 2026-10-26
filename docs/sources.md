# Sources

The manifests are fetched from a Git repository or an OCI artifact, selected via the `source` value. Credentials are referenced by name from a Secret in the package namespace.

## Git

With `source: git` (the default), Flux checks out a branch of the Git repository and reconciles the manifests in a path within it, or its root.

```yaml
source: git
git:
  url: https://github.com/kadras-io/my-gitops-repo
  branch: main
  path: clusters/staging
  secret_name: git-credentials
```

### Credentials

For a private repository, set `git.secret_name` to a Secret with read-only credentials.

The Secret uses the [GitRepository format](https://fluxcd.io/flux/components/source/gitrepositories/#secret-reference): `username` and `password` for HTTPS, `identity` and `known_hosts` for SSH.

```shell
kubectl create secret generic git-credentials -n kadras-system \
  --from-literal=username=git \
  --from-literal=password=${GITHUB_TOKEN}
```

## OCI

With `source: oci`, Flux pulls an OCI artifact and reconciles the manifests in a path within it, or its root. The URL uses the `oci://` scheme.

```yaml
source: oci
oci:
  url: oci://ghcr.io/kadras-io/my-gitops-artifact
  semver: 1.x
  path: clusters/staging
```

The artifact is a Flux artifact, pushed with [`flux push artifact`](https://fluxcd.io/flux/cheatsheets/oci-artifacts/).

### Artifact version

The artifact is selected by one of:

* `oci.tag`, `latest` by default.
* `oci.semver`, a semver range. Flux pulls the highest matching tag, and checks for new tags every `interval`.
* `oci.digest`, which pins an immutable version.

`oci.digest` and `oci.semver` take precedence over `oci.tag`, and they can't be set together.

### Credentials

For a private registry, set `oci.secret_name` to a Secret with read-only credentials.

The Secret is of type `kubernetes.io/dockerconfigjson`.

```shell
kubectl create secret docker-registry registry-credentials -n kadras-system \
  --docker-server=ghcr.io \
  --docker-username=${GITHUB_USER} \
  --docker-password=${GITHUB_TOKEN}
```

Alternatively, `oci.service_account` uses the image pull secrets of a ServiceAccount.

### Workload identity

The OCIRepository can authenticate with the registry of a cloud provider via workload identity instead of static credentials. Set `oci.provider` to `aws`, `azure`, or `gcp`.

```yaml
source: oci
oci:
  url: oci://123456789012.dkr.ecr.eu-west-1.amazonaws.com/my-gitops-artifact
  provider: aws
```

Without `oci.service_account`, the identity of the source controller is used. With it, the identity of that ServiceAccount, which requires the `ObjectLevelWorkloadIdentity` feature gate on the source controller. See [OCIRepository provider](https://fluxcd.io/flux/components/source/ocirepositories/#provider).
