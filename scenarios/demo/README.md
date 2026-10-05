# OpenNMS Horizon Demo

OpenNMS Horizon demo environment with Docker and Docker Compose.

# Usage

Clone the repository and start the stack with the following command:

```
cd demo
docker compose up -d
```

# Inventory and topology

`docker compose up -d` provisions the whole demo, no manual step needed.
The one-shot `init` service runs `init/init.sh` once core and both Minions are healthy.
Its image is `curlimages/curl` with the [onmsctl](https://github.com/no42-org/onmsctl) binary copied in.
The script does the following:

* Creates the Berlin CLOS fabric in nl6 from `init/nl6-topology.json`, unless it already exists
* Runs `onmsctl apply -f` against every requisition in `init/inventory`
* Imports the `Minions` requisition again, two Minions registering at once on a fresh database can leave one of them without a node
* Uploads the GraphML topology _OpenNMS Demo_ from `init/topology.xml`

| File | Requisition | Nodes |
| --- | --- | --- |
| `init/inventory/demo-environment.yaml` | `demo-environment` | Stuttgart services and servers, Fulda servers |
| `init/inventory/berlin.yaml` | `berlin` | nl6 CLOS fabric |

Each requisition pins a foreign source without detectors.
To change the inventory, edit the YAML and rerun `docker compose run --rm init`.
onmsctl only writes and imports a requisition that differs from the server.
The onmsctl context lives in `init/onmsctl/config.yaml`.

# Berlin: simulated CLOS fabric with nl6

The `net.berlin` network (`172.32.0.0/16`) runs an [nl6](https://github.com/labmonkeys-space/nl6) simulator and a dedicated Minion at location _Berlin_.
Everything in Berlin comes up and gets provisioned with `docker compose up -d`, no manual step needed.

| Service | Address | Purpose |
| --- | --- | --- |
| `minion-berlin` | `172.32.0.12` | Minion _Berlin_, receives IPFIX on `9999/udp` and SNMP traps on `1162/udp` |
| `nl6-berlin` | `172.32.0.20` | nl6 simulator, web UI on http://localhost:8080 |
| `minion-berlin-route` | | One-shot, routes `10.42.0.0/16` from the Minion to nl6 |

The fabric has 2 spines and 3 leaves, every leaf links to every spine and nl6 announces the links over LLDP.

| Node | Management IP | nl6 profile |
| --- | --- | --- |
| `spine-01`, `spine-02` | `10.42.0.1`, `10.42.0.2` | `cisco_nexus_9500` |
| `leaf-01` to `leaf-03` | `10.42.0.3` to `10.42.0.5` | `arista_7280r3` |

Each device exports IPFIX and SNMP traps to the Berlin Minion with its management IP as source address.
The `berlin` requisition in `init/inventory/berlin.yaml` sets ICMP and SNMP on the management IP, which is the SNMP primary interface.
The `init` service creates the fabric in nl6.

If you restart `minion-berlin` on its own, its network namespace loses the route. Rerun it with `docker compose up -d minion-berlin-route`.

# Enabling LLDP

Forwarding _LLDPDU_ is not enabled by default on Linux _bridges_.
To enable _LLDPDU_ forwarding it is required to change the `group_fwd_mask` for a given _bridge_.

Using `docker-compose up -d` will create two additional bridges from this repository.
One bridge simulating a local area network and second bridge for a isolated network in a remote office.

To enable _LLDPDU_ forwarding it is required to identify the _bridge_ on the docker host system with:

    docker network ls

    a0713f06e511        lldp_branch         bridge              local
    2bde8ffcb81b        lldp_default        bridge              local
    bb562d6d9e30        lldp_local          bridge              local

The _NETWORK ID_ is part of the _bridge name_ on the host system.
To enable _LLDPDU_ forwarding for the _local_ network a _bridge_ is created.

    brctl show | grep bb562d6d9e30

    br-bb562d6d9e30		8000.0242deaee63c	no		veth067f1fa

The filter can be set with

    echo 16384 > /sys/class/net/br-bb562d6d9e30/bridge/group_fwd_mask

_LLDPDU_ forwarding is now enabled and works immediately.
