# This is for testing and development only.
# SSHD must be installed before running the playbook.
# Thanks: https://stackoverflow.com/questions/71040681/qemu-x86-64-could-not-open-lib64-ld-linux-x86-64-so-2-no-such-file-or-direc
FROM geerlingguy/docker-${MOLECULE_DISTRO:-rockylinux8}-ansible:latest
RUN yum install \
  openssh-server \
  git \
  gpg \
    -y

# https://github.com/geerlingguy/docker-rockylinux9-ansible/issues/6#issuecomment-2676248714
RUN chmod 0400 /etc/shadow
