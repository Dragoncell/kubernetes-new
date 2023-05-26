#!/bin/bash

set -x

LOCAL_KUBEKINS_IMAGE="kubekinsjiamingxu:latest"

# Build local kubekins
docker build \
    --build-arg USER_ID=$(id \
    -u ${USER}) \
    --build-arg GROUP_ID=$(id \
    -g ${USER}) \
    --build-arg USERNAME=${USER} \
    -t "${LOCAL_KUBEKINS_IMAGE}" ${HOME}/dev_scripts/kubekins/image

#make clean

mkdir -p "/tmp/e2e-node-results"
UUID="4321"
ARTIFACTS="/tmp/e2e-node-results/${UUID}"
mkdir -p "${ARTIFACTS}"
echo "ARTIFACTS= ${ARTIFACTS}"

PROJECT="jiamingxu-gke-dev"
ZONE="us-west1-c"

IMAGE_CONFIG="/workspace/test-infra/jobs/e2e_node/containerd/image-config-serial.yaml"
SSH_KEY="/home/jiamingxu/.ssh/google_compute_engine"

# '--test_args=--nodes=1 --focus="\[porterdavid\]" --skip="\[Flaky\]" --no-color --repeat=10 --flake-attempts=10' \

# --repeat=3 --flake-attempts=3
docker run \
    --rm \
    --entrypoint=kubetest \
    -it \
    -e ARTIFACTS="${ARTIFACTS}" \
    -e JENKINS_GCE_SSH_PRIVATE_KEY_FILE="${SSH_KEY}" \
    -e KUBE_SSH_USER="${USER}" \
    -e WORKSPACE="/go/src/k8s.io/kubernetes" \
    -w /go/src/k8s.io/kubernetes \
    -v ${HOME}/go/src/k8s.io/kubernetes:/go/src/k8s.io/kubernetes \
    -v ${HOME}/go/src/k8s.io/test-infra:/workspace/test-infra:ro \
    -v ${HOME}/go/src/k8s.io/test-infra:/home/prow/go/src/k8s.io/test-infra:ro \
    -v ~/.config/gcloud:/home/jiamingxu/.config/gcloud \
    -v ${HOME}/.ssh/google_compute_engine:/home/jiamingxu/.ssh/google_compute_engine:ro \
    -v ${HOME}/.ssh/google_compute_engine.pub:/home/jiamingxu/.ssh/google_compute_engine.pub:ro \
    -v ${HOME}/go/src/github.com/containerd/containerd:/home/prow/go/src/github.com/containerd/containerd:ro \
    -v ${ARTIFACTS}:${ARTIFACTS} "${LOCAL_KUBEKINS_IMAGE}" \
    kubetest \
      --up \
      --down \
      --test \
      --provider=gce \
      --deployment=node \
      --gcp-project="${PROJECT}" \
      --gcp-zone="${ZONE}" \
      "--node-args=--image-config-file="${IMAGE_CONFIG} \
      '--node-test-args=--container-runtime-endpoint=unix:///run/containerd/containerd.sock --container-runtime-process-name=/usr/bin/containerd --container-runtime-pid-file= --kubelet-flags="--cgroups-per-qos=true --cgroup-root=/ --cgroup-driver=systemd --runtime-cgroups=/system.slice/containerd.service" --extra-log="{\"name\":\"containerd.log\", \"journalctl\": [\"-u\", \"containerd*\"]}"' \
      --node-tests=true \
      '--test_args=--nodes=1 --focus=".*Summary API.*" --skip="\[Flaky\]|\[Benchmark\]|\[NodeSpecialFeature:.+\]|\[NodeSpecialFeature\]|\[NodeAlphaFeature:.+\]|\[NodeAlphaFeature\]|\[NodeFeature:Eviction\]" --timeout=240m --no-color -v' \
      '--timeout=220m' 2>&1 | tee -i "${ARTIFACTS}/build-log.txt"
