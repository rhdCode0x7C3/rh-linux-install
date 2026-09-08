FROM ghcr.io/void-linux/void-glibc-full

RUN xbps-install -S && \
xbps-install -y bash
