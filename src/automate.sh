#!/bin/bash

set -eo pipefail

#global vars
LC_ALL="C"
K8S_CLI="oc"  # could be kubectl or oc
MONGOSPORT="27017"
CFGPORT="27018"
PORT=$1 && [ -z "${1}" ] && PORT="27020" || true

$K8S_CLI get pods -l role=mongoshard -o name > ./tmp/podfile

i=1
while read p; do
	  ii=$(printf %02d "${i}")
  	POD=$(echo $p | cut -d / -f2)
  	NODE=$(echo $POD | cut -d'-' -f3 | cut -b 5-6)
  	JSFILE=$(ls ./build/node${NODE}-rs*)
  	RSNUM=$(echo $JSFILE | cut -d'-' -f2 | cut -b 3-4)
  	CONTAINER="rsp${RSNUM}-node${NODE}"
  	echo "${ii}: Initialize replication set rs${RSNUM} on node ${NODE}"
  	echo "Execute command on pod ${POD} and container ${CONTAINER}"
  	$K8S_CLI exec -ti ${POD} -c ${CONTAINER} -- mongo --verbose 127.0.0.1:${PORT} <${JSFILE}
  	if [ -e "./build/cfg${ii}-init.js" ]; then
  		echo "Initialize Config Server Replication Set"
  		$K8S_CLI exec -ti ${POD} -c ${CONTAINER} -- mongo --verbose 127.0.0.1:${CFGPORT} <./build/cfg${ii}-init.js
  	fi	
  	i=$((i+1))
done < ./tmp/podfile

sleep 15
echo "Initialize Shard..."
$K8S_CLI exec -ti ${POD} -c ${CONTAINER} -- mongo --verbose 127.0.0.1:${MONGOSPORT} <./build/shard-init.js

# sleep 15
# echo "Initialize database collections for sharding ..."
# $K8S_CLI exec -ti ${POD} -c ${CONTAINER} -- mongo --verbose 127.0.0.1:${MONGOSPORT} <./js-templates/shardkeys.js
