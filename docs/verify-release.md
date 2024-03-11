# Verifying the Package Release

This package is published as an OCI artifact, signed with Sigstore [Cosign](https://docs.sigstore.dev/cosign/overview), and associated with a [SLSA Provenance](https://slsa.dev/provenance) attestation.

Using `cosign`, you can display the supply chain security related artifacts for the `ghcr.io/kadras-io/gitops-configurer` images. Use the specific digest you'd like to verify.

```shell
cosign tree ghcr.io/kadras-io/gitops-configurer
```

The result:

```shell
📦 Supply Chain Security Related artifacts for an image: ghcr.io/kadras-io/gitops-configurer
└── 💾 Attestations for an image tag: ghcr.io/kadras-io/gitops-configurer:sha256-de2b5c420187564a7bf85dfed086bd6d90830c2d3e7807422864956ffd57079c.att
   └── 🍒 sha256:168c3ff7833364cfdb1ee29d0d0751a4daec6fb0001e497ad0ad2e36e667e309
└── 🔐 Signatures for an image tag: ghcr.io/kadras-io/gitops-configurer:sha256-de2b5c420187564a7bf85dfed086bd6d90830c2d3e7807422864956ffd57079c.sig
   └── 🍒 sha256:42c104040c56cc2d4f4263234e8d1f6515457895805b1f0efb19c1c7ff5ae4d1
```

You can verify the signature and its claims:

```shell
cosign verify \
   --certificate-identity-regexp https://github.com/kadras-io \
   --certificate-oidc-issuer https://token.actions.githubusercontent.com \
   ghcr.io/kadras-io/gitops-configurer | jq
```

You can also verify the SLSA Provenance attestation associated with the image.

```shell
cosign verify-attestation --type slsaprovenance \
   --certificate-identity-regexp https://github.com/slsa-framework \
   --certificate-oidc-issuer https://token.actions.githubusercontent.com \
   ghcr.io/kadras-io/gitops-configurer | jq .payload -r | base64 --decode | jq
```
