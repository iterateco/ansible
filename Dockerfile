# https://github.com/docker/for-linux/issues/59
ARG IMAGE
FROM ${IMAGE}

ARG IMAGE
ARG PLAYBOOK
ARG DEBIAN_FRONTEND=noninteractive

RUN echo "building from ${IMAGE} using ${PLAYBOOK}"

RUN apt-get -y update
RUN apt-get -y install git wget sudo software-properties-common
RUN apt-add-repository -y ppa:ansible/ansible
RUN apt-get -y update
RUN apt-get -y install ansible

RUN mkdir /tmp/ansible

COPY ./roles /tmp/ansible/roles
COPY ${PLAYBOOK} /tmp/ansible/docker.yml

RUN ansible-playbook /tmp/ansible/docker.yml
RUN rm -rf /tmp/ansible