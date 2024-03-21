# This is for testing and development only.
# SSHD must be installed before running the playbook.
FROM geerlingguy/docker-${MOLECULE_DISTRO:-rockylinux8}-ansible:latest
RUN yum install openssh-server git -y
