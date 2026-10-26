load("@ytt:regexp", "regexp")

# Validation helpers used by the values schema, and by the templates to interpret the values they validate.
# They must not depend on data values, since they run while the schema is evaluated.

_dns_label = "[a-z0-9]([-a-z0-9]*[a-z0-9])?"

def is_dns_label(value):
  return len(value) <= 63 and regexp.match("^" + _dns_label + "$", value)
end

def is_dns_subdomain(value):
  return len(value) <= 253 and regexp.match("^" + _dns_label + "(\\." + _dns_label + ")*$", value)
end

# A Go duration, like `1m0s` or `1h30m`, as accepted by Flux.
def is_duration(value):
  return regexp.match("^([0-9]+(\\.[0-9]+)?(ns|us|µs|ms|s|m|h))+$", value)
end

def is_digest(value):
  return regexp.match("^sha256:[a-f0-9]{64}$", value)
end
