ARG BASE_VERSION=3.30-1787764814
FROM registry.redhat.io/devspaces/udi-rhel9:${BASE_VERSION}

# Local transport wrapper only. A real remote workspace platform supplies
# the connection plumbing.
USER root

RUN dnf install -y openssh-server \
    && dnf clean all \
    && mkdir -p /run/sshd /etc/ssh/authorized_keys /home/user/.bashrc.d \
    && useradd -o -u 10001 -g 0 -d /home/user -s /bin/bash -M developer \
    && usermod -p x developer \
    && chown -R 10001:0 /home/user /projects

COPY lab_authorized_key.pub /etc/ssh/authorized_keys/developer
COPY sshd_config /etc/ssh/sshd_config
COPY lab04-node.sh /home/user/.bashrc.d/20-lab04-node.sh

RUN chmod 600 /etc/ssh/authorized_keys/developer \
    && chown 10001:0 /etc/ssh/authorized_keys/developer \
    && chown 10001:0 /home/user/.bashrc.d/20-lab04-node.sh \
    && ssh-keygen -A

EXPOSE 2226 3000 9229

ENTRYPOINT []
CMD ["/usr/sbin/sshd", "-D", "-e", "-f", "/etc/ssh/sshd_config"]
