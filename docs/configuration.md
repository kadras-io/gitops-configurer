# Configuration

The package values cover the decisions most installations need to make: the source, how often to reconcile, and how Flux applies the manifests. Everything else can be customized via ytt overlays applied to the generated resources.

## ytt overlays

kapp-controller applies the [ytt overlays](https://carvel.dev/ytt/docs/latest/ytt-overlays/) stored in a Secret on top of the package configuration, when the PackageInstall references it with the `ext.packaging.carvel.dev/ytt-paths-from-secret-name.<n>` annotation. See [PackageInstall](https://carvel.dev/kapp-controller/docs/latest/package-install-extensions/).

For example, to apply the manifests only after another Kustomization is ready:

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
      dependsOn:
        - name: infrastructure
```

Reference the Secret from the PackageInstall:

```shell
kubectl annotate packageinstall gitops-configurer -n kadras-system \
  ext.packaging.carvel.dev/ytt-paths-from-secret-name.0=gitops-configurer-overlays
```

The generated resources are named after `name`, in the `namespace` of the values: a `GitRepository` or `OCIRepository` and a `Kustomization`. See [controllers.md](controllers.md).
