#!/bin/sh -e

trap 'trap - TERM; kill -s TERM -- -$$' TERM

tail -f /dev/null & wait

exit 0
