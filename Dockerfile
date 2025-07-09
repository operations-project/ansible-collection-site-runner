# This is for testing and development only.
# SSHD must be installed before running the playbook.
# Thanks: https://stackoverflow.com/questions/71040681/qemu-x86-64-could-not-open-lib64-ld-linux-x86-64-so-2-no-such-file-or-direc
FROM --platform=linux/amd64 geerlingguy/docker-${MOLECULE_DISTRO:-ubuntu2404}-ansible:latest
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        git \
        openssh-server
