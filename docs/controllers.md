# Controllers

GitOps Configurer creates the resources that make a controller reconcile the manifests in the source with the cluster. The controller is selected via the `controller` value.

## Flux

With `controller: flux` (the default), the package creates a Flux source, a `GitRepository` or an `OCIRepository`, and a `Kustomization` applying the manifests it fetches. It requires the Flux source and kustomize controllers, available in the [Flux package](https://github.com/kadras-io/package-for-flux).

```yaml
controller: flux
interval: 5m
git:
  url: https://github.com/kadras-io/my-gitops-repo
  path: clusters/staging
flux:
  prune: true
  wait: true
  timeout: 3m
```

* `interval` sets how often the source is fetched and the manifests applied, even when the source didn't change, which reverts the changes made directly to the cluster.
* `flux.prune` deletes the resources removed from the source. It also means that deleting the Kustomization, including when uninstalling the package, deletes all the resources it applied. See [upgrade.md](upgrade.md).
* `target_namespace` deploys all the manifests in the given namespace. Without it, each manifest of a namespaced resource must set its namespace.
* `flux.wait` makes the Kustomization ready only once all the resources it applied are ready, within `flux.timeout`.

The manifests can be plain Kubernetes resources or a [Kustomize](https://kustomize.io) overlay, with a `kustomization.yaml` file. See [Kustomization](https://fluxcd.io/flux/components/kustomize/kustomizations/).

## Carvel

With `controller: carvel`, the package creates a kapp-controller `App`. It fetches the source, renders the manifests with [ytt](https://carvel.dev/ytt) and [kbld](https://carvel.dev/kbld), and deploys them with [kapp](https://carvel.dev/kapp), every `interval`. The manifests can use ytt templates, and kbld resolves the image tags to digests. kapp-controller is already a prerequisite of the package, so there are no other dependencies.

```yaml
controller: carvel
service_account: gitops-deployer
git:
  url: https://github.com/kadras-io/my-gitops-repo
  path: clusters/staging
```

kapp tracks the resources of the App, deletes the ones removed from the source, and waits for the resources to be ready. Deleting the App, including when uninstalling the package, deletes all the resources it deployed. See [upgrade.md](upgrade.md).

The manifests are rendered with `ignoreUnknownComments`, so plain YAML comments don't need to follow the ytt syntax. A `kustomization.yaml` file isn't supported: kapp would try to deploy it as a resource.

See [App](https://carvel.dev/kapp-controller/docs/latest/app-spec/).

## Permissions

The controller deploys the manifests with the permissions of the ServiceAccount in `service_account`, in the package namespace. It must be allowed to manage all the resources in the source.

* With the `carvel` controller, it's required. kapp-controller doesn't deploy with its own permissions.
* With the `flux` controller, it's optional. When empty, the kustomize controller uses its own permissions, which are cluster-admin by default.

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
