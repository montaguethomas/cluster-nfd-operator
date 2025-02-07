# Build the manager binary
FROM registry.ci.openshift.org/ocp/builder:rhel-9-golang-1.20-openshift-4.15 AS builder
WORKDIR /go/src/github.com/openshift/cluster-nfd-operator

# Build
COPY . .
RUN make build

# Create production image for running the operator
FROM registry.ci.openshift.org/ocp/4.15:base-rhel9

ARG CSV=4.14
COPY --from=builder /go/src/github.com/openshift/cluster-nfd-operator/node-feature-discovery-operator /

RUN mkdir -p /opt/nfd
COPY build/assets /opt/nfd
COPY manifests /manifests

# Run as unprivileged user
USER 65534:65534

ENTRYPOINT ["/node-feature-discovery-operator"]
LABEL io.k8s.display-name="node-feature-discovery-operator" \
      io.k8s.description="This is the image for the Node Feature Discovery Operator."
