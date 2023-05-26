FROM gcr.io/k8s-staging-test-infra/kubekins-e2e:latest-master

ARG USER_ID
ARG GROUP_ID
ARG USERNAME

RUN groupadd --gid ${GROUP_ID} ${USERNAME} \
    && useradd --uid ${USER_ID} --gid ${GROUP_ID} --shell /bin/bash --create-home ${USERNAME}
USER ${USERNAME}
