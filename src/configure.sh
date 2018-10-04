#!/bin/bash

set -eo pipefail

LC_ALL="C"
NODES=$1 && [ -z "${1}" ] && NODES="3" || true
MONGO_VER="3.6.8"
DATADIR="/usr/local/mongo/data"

echo
echo "Please supply some important configuration parameters below:"
echo "============================================================"
read -p "SSH user for cluster access [root]: " SSHUSER
[ -z "$SSHUSER" ] && SSHUSER="root" || true
read -p "SSH port for cluster access [22]: " SSHPORT
[ -z "$SSHPORT" ] && SSHPORT="22" || true
read -p "Root directory for your mongodb data [${DATADIR}]: " BASEDIR
[ -z "$BASEDIR" ] && BASEDIR=$DATADIR || true
read -p "Number of nodes for your shard [${NODES}]: " CFGNODES
[ -z "$CFGNODES" ] && CFGNODES=$NODES || true
read -p "MongoDB version [${MONGO_VER}]: " VERSION
[ -z "$VERSION" ] && VERSION=$MONGO_VER || true
echo
