#!/bin/bash

set -eo pipefail

#global vars
LC_ALL="C"
K8S_CLI="oc"  # could be kubectl or oc

i=1
while read p; do
	NODE=$(printf %02d "${i}")
  	NAME=$(echo $p | cut -d / -f2)
  	echo "Delete Deployment on machine ${NAME} (node${NODE})..."
  	$K8S_CLI delete -f ./build/node${NODE}-deployment.yaml
  	i=$((i+1))
done < ./tmp/nodefile