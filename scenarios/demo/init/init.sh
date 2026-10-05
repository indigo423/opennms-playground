#!/bin/sh
# Copyright 2026 Ronny Trommer <ronny@no42.org>
# SPDX-License-Identifier: Apache-2.0
#
# Bring the demo to life in one pass: create the Berlin CLOS fabric in nl6,
# provision the whole inventory with onmsctl and upload the GraphML topology.
set -e

NL6_API=${NL6_API:-http://nl6-berlin:8080/api/v1}
MINION=${MINION:-172.32.0.12}
ONMS=${ONMS:-http://core:8980/opennms/rest}
AUTH=${AUTH:-admin:${ONMS_PASSWORD}}

# Berlin fabric: k=4 fat-tree with 4 core, 8 aggregation and 8 edge switches
# in 4 pods, each edge switch serves 2 hosts. Links come from nl6's
# examples/large-clos/gen-clos.py with CLOS_K=4. The switches export IPFIX and
# SNMP traps to the Berlin Minion.
EXPORT=",\"flow\":{\"collector\":\"${MINION}:9999\",\"protocol\":\"ipfix\"},\"traps\":{\"collector\":\"${MINION}:1162\",\"mode\":\"trap\"}"

until curl -sf "${NL6_API}/version" > /dev/null; do
  echo "Waiting for nl6 API ..."
  sleep 2
done

create() {
  curl -sf -X POST "${NL6_API}/devices" -H 'Content-Type: application/json' \
       -d "{\"start_ip\":\"$1\",\"device_count\":$2,\"netmask\":\"16\",\"resource_file\":\"$3\"$4}"
  echo
}

if curl -sf "${NL6_API}/devices" | grep -q '"ip":"10.42.0.1"'; then
  echo "Fabric already exists"
else
  create 10.42.0.1 4 cisco_crs_x.json "${EXPORT}"
  create 10.42.4.1 8 arista_7280r3.json "${EXPORT}"
  create 10.42.8.1 8 cisco_catalyst_9500.json "${EXPORT}"
  create 10.42.16.1 16 linux_server.json
  curl -sf -X POST "${NL6_API}/topology" -H 'Content-Type: application/json' -d @/init/nl6-topology.json
  echo
fi

# Every requisition in init/inventory, Stuttgart, Fulda and Berlin
onmsctl apply -f /init/inventory

# Two Minions registering at once on a fresh database can leave one of them
# in the Minions requisition without a node, import it again to catch up.
onmsctl requisition import Minions

# Replace the GraphML topology, the DELETE fails harmlessly on a fresh start
curl -s -o /dev/null -u "${AUTH}" -X DELETE "${ONMS}/graphml/opennms-demo"
curl -sf -u "${AUTH}" -X POST -H 'Content-Type: application/xml' \
     -d @/init/topology.xml "${ONMS}/graphml/opennms-demo"
echo "Topology opennms-demo uploaded"
