# Upgrading

Upgrade the package with the new version, and the same values file.

```shell
kctrl package installed update -i gitops-configurer -v ${VERSION} -n kadras-system --values-file values.yml
```

## Uninstalling

```shell
kctrl package installed delete -i gitops-configurer -n kadras-system
```

> **Warning**
> Uninstalling the package deletes all the workloads it reconciled.

With `prune: true` (the default), deleting the Kustomization deletes all the resources it applied.

To keep the workloads, set `prune: false` and wait for the Kustomization to reconcile before uninstalling.
