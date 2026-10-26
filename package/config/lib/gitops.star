load("@ytt:data", "data")

# The labels set on all the GitOps resources.
def labels():
  return {"app.kubernetes.io/component": "gitops-configurer"}
end

# ###########
# SOURCE
# ###########

def is_git():
  return data.values.source == "git"
end

def is_oci():
  return data.values.source == "oci"
end

# The path within the source containing the manifests, empty for its root.
def source_path():
  return data.values.git.path if is_git() else data.values.oci.path
end

# The kind of the Flux source fetching the manifests.
def flux_source_kind():
  return "GitRepository" if is_git() else "OCIRepository"
end

# The reference of the OCI artifact, as a single-entry dictionary: `digest`, `semver`, or `tag`, in this order of precedence.
def oci_ref():
  if data.values.oci.digest != "":
    return {"digest": data.values.oci.digest}
  elif data.values.oci.semver != "":
    return {"semver": data.values.oci.semver}
  end
  return {"tag": data.values.oci.tag}
end
