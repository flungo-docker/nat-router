FROM alpine:3.5

# Install the required packages
RUN apk add --update iptables

# Populate the tor-router configurations
COPY . /opt/nat-router

# Set the container's WORKDIR and ENTRYPOINT
WORKDIR /opt/nat-router
ENTRYPOINT ["/opt/nat-router/entrypoint.sh"]
