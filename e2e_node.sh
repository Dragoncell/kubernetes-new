#!/bin/bash
 
mkdir -p "/tmp/e2e-node-results"
 
UUID="1134"
TMPDIR="/tmp/e2e-node-results/${UUID}"
mkdir -p "${TMPDIR}"
 
echo "TMPDIR= ${TMPDIR}"
 
PROJECT="jiamingxu-gke-dev"
ZONE="us-central1-c"
 
 
SSH_KEY="${HOME}/.ssh/google_compute_engine"
 
IMAGE_CONFIG="${GOPATH}/src/k8s.io/test-infra/jobs/e2e_node/containerd/image-config-serial.yaml"
IMAGE_CONFIG_OUT="${TMPDIR}/image-config.yaml"
cp "${IMAGE_CONFIG}" "${TMPDIR}/image-config.yaml"
sed -i -e s:/go:${GOPATH}:g -e s:/workspace:${GOPATH}/src/k8s.io:g "${IMAGE_CONFIG_OUT}"
 
ARTIFACTS="${TMPDIR}" JENKINS_GCE_SSH_PRIVATE_KEY_FILE="${SSH_KEY}" kubetest \
  --up \
  --down \
  --test \
  --provider=gce \
  --deployment=node \
  --gcp-project="${PROJECT}" \
  --gcp-zone="${ZONE}" \
  "--node-args=--image-config-file="${IMAGE_CONFIG_OUT} \
  '--node-test-args=--container-runtime-endpoint=unix:///run/containerd/containerd.sock --container-runtime-process-name=/usr/bin/containerd --container-runtime-pid-file= --kubelet-flags="--cgroups-per-qos=true --cgroup-root=/ --runtime-cgroups=/system.slice/containerd.service" --extra-log="{\"name\":\"containerd.log\", \"journalctl\": [\"-u\", \"containerd*\"]}"' \
  --node-tests=true \
  '--test_args=--nodes=1 --focus=".*Summary API.*" --skip="\[Flaky\]"' \
  '--timeout=60m' 2>&1 | tee -i "${TMPDIR}/build-log.txt"
