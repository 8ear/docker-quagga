## This Dockerfile creates a Quagga image that runs Zebra, OSPF (v4 and V6), and
## BGP daemons.
##
## Details available at https://bitbucket.org/arbiza/quagga-docker
## -----------------------------------------------------------------------------

## Use Debian image
FROM debian:stable-slim

RUN set -eu \
    ## Update the system and install required packages
    ;apt-get update && apt-get install -y \
        traceroute \
        telnet \
        bash \
        quagga \
    ;rm -rf /var/lib/apt/lists/*
    
RUN set -eu \    
    ## Directories
    ;mkdir /var/run/quagga \
    ;mkdir /var/log/quagga \
    ## Fix "the END problem" in Quagga vtysh
    ;echo VTYSH_PAGER=more >> /etc/environment \
    ## Enable IPv6 and IPv4 forwarding
    ;echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf \
    ;echo 'net.ipv6.conf.all.forwarding = 1' >> /etc/sysctl.conf \
    ;echo 'net.ipv6.conf.default.forwarding = 1' >> /etc/sysctl.conf \
    ## Enable vlan
    ;echo 8021q >> /etc/modules \
    ;ldconfig

## Exposing ports allows daemons to be telneted from the host
## Porst exposed: # zebra, bgp, ospf, ospf6
#EXPOSE 2601 2605 2604 2606

VOLUME ["/etc/quagga"]

ENV PATH "/sbin:/bin:/usr/sbin:/usr/bin"
#ENTRYPOINT ["/bin/bash", "/etc/run.bash"]


# Add s6-overlay
ADD https://github.com/just-containers/s6-overlay/releases/download/v1.21.8.0/s6-overlay-amd64.tar.gz /tmp/
RUN set -eu \
    ;tar xzf /tmp/s6-overlay-amd64.tar.gz -C / \
    ;rm /tmp/s6*.tar.gz

COPY 3-fix-attrs.d/ /etc/fix-attrs.d/
COPY 4-cont-init.d/ /etc/cont-init.d/
COPY 5-services.d/ /etc/services.d/
COPY 6-cont-finish.d/ /etc/cont-finish.d/

# # Install socklog-overlay
# ADD https://github.com/just-containers/socklog-overlay/releases/download/v3.1.0-1/socklog-overlay-amd64.tar.gz /tmp/
# RUN set -eu \
#     ;tar xzf /tmp/socklog-overlay-amd64.tar.gz -C / \
#     ;rm /tmp/socklog*.tar.gz


COPY etc/quagga /etc/quagga

ENTRYPOINT ["/init"]
CMD [ "/usr/bin/vtysh" ]


#####
ARG VENDOR="M. H."
ARG BUILD_DATE
ARG GIT_REPO
ARG VCS_REF
ARG RELEASE_DATE
ARG NAME="Quagga"
ARG DESCRIPTION="Quagga (OSPF, BGP) on Docker"
ARG DOCUMENTATION="https://github.com/8ear/docker-quagga"
ARG AUTHOR="M. H."
ARG LICENSE="BSD-3-Clause"

LABEL org.label-schema.build-date="${BUILD_DATE}" \
        org.label-schema.name="${NAME}" \
        org.label-schema.description="${DESCRIPTION}" \
        org.label-schema.vcs-ref="${VCS_REF}" \
        org.label-schema.vcs-url="${GIT_REPO}" \
        org.label-schema.url="${GIT_REPO}" \
        org.label-schema.vendor="${VENDOR}" \
        org.label-schema.version="${VERSION}" \
        org.label-schema.usage="${DOCUMENTATION}" \
        org.label-schema.schema-version="1.0.0-rc1"

LABEL   org.opencontainers.image.created="${BUILD_DATE}" \
        org.opencontainers.image.url="${GIT_REPO}" \
        org.opencontainers.image.source="${GIT_REPO}" \
        org.opencontainers.image.version="${VERSION}" \
        org.opencontainers.image.revision="${VCS_REF}" \
        org.opencontainers.image.vendor="${VENDOR}" \
        org.opencontainers.image.title="${NAME}" \
        org.opencontainers.image.description="${DESCRIPTION}" \
        org.opencontainers.image.documentation="${DOCUMENTATION}" \
        org.opencontainers.image.authors="${AUTHOR}" \
        org.opencontainers.image.licenses="${LICENSE}"
