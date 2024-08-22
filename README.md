[![Validate Docker Compose files](https://github.com/indigo423/opennms-playground/actions/workflows/validate-docker-compose.yml/badge.svg)](https://github.com/indigo423/opennms-playground/actions/workflows/validate-docker-compose.yml)

# 🕹️ Playground for OpenNMS Horizon

This is a collection of deployment scenarios for OpenNMS Horizon.
It can be used to learn and test functions and features of the network monitoring stack OpenNMS Horizon.
This is not a production ready deployment, but it will help you understand which components are required and how need to think about 3rd party service dependencies and data persistence.

## How can I create a secure credential vault

The following commands will create a `scv.jce` file in your current working directoy with credentials for connecting to the PostgreSQL database.
There will be two credential sets created, the user for the OpenNMS Horizon database with the user `opennms` and a PostgreSQL admin user which can manipulate an create schemas during initialization and updates `postgres`.

```
docker run --rm -v $(pwd):/opt/opennms/etc \
  --entrypoint /opt/opennms/bin/scvcli \
  quay.io/labmonkeys/onms-horizon:33.0.7 \
  set postgres opennms "change_me!_Cux2j4WEA59j28WF5Kt%"

docker run --rm -v $(pwd):/opt/opennms/etc \
  --entrypoint /opt/opennms/bin/scvcli \
  quay.io/labmonkeys/onms-horizon:33.0.7 \
  set postgres-admin postgres "change_me!_VRL7FhR@mGw@djhS2A4"
```
> [!IMPORTANT]
> Don't use the passwords above, they are just an example.

# Credits

* @agalue
* @deejgregor
* @j-white
* @jeffgdotorg
* @mhuot
* @mvrueden
