# Configuration

The package values cover the decisions most installations need to make: the controller, the source, and how often to reconcile. Everything else can be customized via ytt overlays applied to the generated resources.

## ytt overlays

kapp-controller applies the [ytt overlays](https://carvel.dev/ytt/docs/latest/ytt-overlays/) stored in a Secret on top of the package configuration, when the PackageInstall references it with the `ext.packaging.carvel.dev/ytt-paths-from-secret-name.<n>` annotation. See [PackageInstall](https://carvel.dev/kapp-controller/docs/latest/package-install-extensions/).

For example, to apply the manifests to a given namespace and only after another Kustomization is ready:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: gitops-configurer-overlays
  namespace: kadras-system
stringData:
  kustomization.yml: |
    #@ load("@ytt:overlay", "overlay")
    #@overlay/match by=overlay.subset({"kind":"Kustomization", "metadata":{"name":"gitops-configurer"}})
    ---
    spec:
      #@overlay/match missing_ok=True
      targetNamespace: apps
      #@overlay/match missing_ok=True
      dependsOn:
        - name: infrastructure
```

Reference the Secret from the PackageInstall:

```shell
kubectl annotate packageinstall gitops-configurer -n kadras-system \
  ext.packaging.carvel.dev/ytt-paths-from-secret-name.0=gitops-configurer-overlays
```

The generated resources are named after `name`, in the `namespace` of the values: an `App`, or a `GitRepository` or `OCIRepository` and a `Kustomization`. See [controllers.md](controllers.md).

### Keeping the workloads on deletion

For example, to keep the resources deployed by the Carvel App when it's deleted, including when uninstalling the package:

```yaml
#@ load("@ytt:overlay", "overlay")
#@overlay/match by=overlay.subset({"kind":"App", "metadata":{"name":"gitops-configurer"}})
---
spec:
  #@overlay/match missing_ok=True
  noopDelete: true
```

With the Flux controller, set `flux.prune: false` instead. See [upgrade.md](upgrade.md).
