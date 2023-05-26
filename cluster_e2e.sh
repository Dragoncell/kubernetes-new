 
mkdir -p "/tmp/e2e-node-results"
 
UUID="1234"
TMPDIR="/tmp/e2e-node-results/${UUID}"
mkdir -p "${TMPDIR}"
 
echo "TMPDIR= ${TMPDIR}"
 
PROJECT="jiamingxu-gke-dev"
ZONE="us-central1-c"
 
 
SSH_KEY="${HOME}/.ssh/google_compute_engine"
 
KUBE_MASTER_EXTRA_METADATA="user-data=/workspace/github.com/containerd/containerd/test/e2e/master.yaml,containerd-configure-sh=/workspace/github.com/containerd/containerd/cluster/gce/configure.sh,containerd-env=/workspace/test-infra/jobs/e2e_node/containerd/containerd-main/env"

KUBE_NODE_EXTRA_METADATA="user-data=/workspace/github.com/containerd/containerd/test/e2e/node.yaml,containerd-configure-sh=/workspace/github.com/containerd/containerd/cluster/gce/configure.sh,containerd-env=/workspace/test-infra/jobs/e2e_node/containerd/containerd-main/env" 
 
KUBELET_TEST_ARGS="--runtime-cgroups=/system.slice/containerd.service --cgroup-driver=systemd"
 
ARTIFACTS="${TMPDIR}" JENKINS_GCE_SSH_PRIVATE_KEY_FILE="${SSH_KEY}" kubetest \
  --up \
  --down \
  --test \
  --gcp-project="${PROJECT}" \
  --gcp-zone="${ZONE}" \
  --provider=gce \
  --gcp-node-image=ubuntu \
  --image-family=ubuntu-2204-lts \
  --image-project=ubuntu-os-cloud \
  --gcp-nodes=4 \
  --ginkgo-parallel=30 \
  --test_args="--ginkgo.focus=.*Summary API.* --minStartupPods=8" \
  --timeout=300m 2>&1 | tee -i "${TMPDIR}/build-log.txt"
