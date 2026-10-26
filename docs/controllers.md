# Controllers

GitOps Configurer creates the resources that make Flux reconcile the manifests in the source with the cluster.

## Flux

The package creates a Flux source, a `GitRepository` or an `OCIRepository`, and a `Kustomization` applying the manifests it fetches. It requires the Flux source and kustomize controllers, available in the [Flux package](https://github.com/kadras-io/package-for-flux).

```yaml
interval: 5m
git:
  url: https://github.com/kadras-io/my-gitops-repo
  path: clusters/staging
prune: true
wait: true
timeout: 3m
```

* `interval` sets how often the source is fetched and the manifests applied, even when the source didn't change, which reverts the changes made directly to the cluster.
* `prune` deletes the resources removed from the source. It also means that deleting the Kustomization, including when uninstalling the package, deletes all the resources it applied. See [upgrade.md](upgrade.md).
* `target_namespace` deploys all the manifests in the given namespace. Without it, each manifest of a namespaced resource must set its namespace.
* `wait` makes the Kustomization ready only once all the resources it applied are ready, within `timeout`.

The manifests can be plain Kubernetes resources or a [Kustomize](https://kustomize.io) overlay, with a `kustomization.yaml` file. See [Kustomization](https://fluxcd.io/flux/components/kustomize/kustomizations/).

## Permissions

The kustomize controller deploys the manifests with the permissions of the ServiceAccount in `service_account`, in the package namespace. It must be allowed to manage all the resources in the source. It's optional: when empty, the kustomize controller uses its own permissions, which are cluster-admin by default.

A dedicated ServiceAccount limits what the source can change in the cluster, for example only some namespaces. For a cluster-wide setup, bind it to the `cluster-admin` ClusterRole.

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: gitops-deployer
  namespace: kadras-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: gitops-deployer
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: gitops-deployer
  namespace: kadras-system
```
