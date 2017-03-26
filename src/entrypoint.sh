#!/bin/sh -e

# Configure environment variables
NAT_ROUTER_USER="tor-router"
NAT_ROUTER_UID="9001"
NAT_ROUTER_HOME="/opt/nat-router"

# Enable debug if requested
if [ "${DEBUG}" = "true" ]; then
  set -x
fi

# If command is provided run that
if [ "${1:0:1}" != '-' ]; then
  exec "$@"
fi

echo 'Verifying environment'

# TODO: Detect --net=host and fail

# Check for CAP_NET_ADMIN
if ! iptables -nL &> /dev/null; then
  >&2 echo 'Container requires CAP_NET_ADMIN, add using `--cap-add NET_ADMIN`.'
  exit 1
fi

# Ensure that the container only has eth0 and lo to start with
for interface in $(ip link show | awk '/^[0-9]*:/ {print $2}' | sed -e 's/:$//' -e 's/@.*$//'); do
  if [ "$interface" != "lo" ] && [ "$interface" != "eth0" ]; then
    >&2 echo 'Container should only have the `eth0` and `lo` interfaces'
    >&2 echo 'Additional interfaces should only be added once tor has been started'
    >&2 echo 'Killing to avoid accidental clobbering'
    exit 1
  fi
done

echo 'Setting up container'

# Setup the NAT_ROUTER_USER
adduser -h "${NAT_ROUTER_HOME}" -u "${NAT_ROUTER_UID}" -D "${NAT_ROUTER_USER}"

# Restore iptables
echo 'Configuring iptables'
iptables-restore "${NAT_ROUTER_HOME}/iptables.rules"

# wait as the NAT_ROUTER_USER until interupt is received
echo 'Sleeping forever'
exec sh
# exec su -c "./wait.sh" "${NAT_ROUTER_USER}"
