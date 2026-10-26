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

The controllers clean up after the resources the package creates:

* With the `carvel` controller, deleting the App deletes all the resources it deployed.
* With the `flux` controller and `flux.prune: true` (the default), deleting the Kustomization deletes all the resources it applied.

To keep the workloads, before uninstalling:

* With the `flux` controller, set `flux.prune: false` and wait for the Kustomization to reconcile.
* With the `carvel` controller, set `spec.noopDelete: true` on the App via a ytt overlay. See [configuration.md](configuration.md#keeping-the-workloads-on-deletion).
