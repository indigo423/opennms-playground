#!/usr/bin/env bash

OPENNMS_HOST=localhost
OPENNMS_USER=admin
OPENNMS_PASS=admin
OPENNMS_PORT=8980

#
# Setup inventory with requisitions and policies and detectors
#
for fs in $(ls policies/*.xml); do
  echo -n "Create ${fs}          ..."
  curl -s -u ${OPENNMS_USER}:${OPENNMS_PASS} \
       -X POST \
       -H "Content-Type: application/xml" \
       -H "Accept: application/xml" \
       -d "@${fs}" \
       "http://${OPENNMS_HOST}:${OPENNMS_PORT}/opennms/rest/foreignSources"
  echo " [ DONE ]"
done
echo ""

for req in $(ls requisitions/*.xml); do
  echo -n "Upload ${req}      ..."
  curl -s -u ${OPENNMS_USER}:${OPENNMS_PASS} \
       -X POST \
       -H "Content-Type: application/xml" \
       -H "Accept: application/xml" \
       -d "@${req}" \
       "http://${OPENNMS_HOST}:${OPENNMS_PORT}/opennms/rest/requisitions"
  echo " [ DONE ]"
done
echo ""

for req in $(ls requisitions/*.xml); do
  reqName=$(basename $req .xml)
  echo -n "Import ${req}      ..."
  curl -s -u ${OPENNMS_USER}:${OPENNMS_PASS} \
       -X PUT \
       "http://${OPENNMS_HOST}:${OPENNMS_PORT}/opennms/rest/requisitions/$(basename $req .xml)/import"
  echo " [ DONE ]"
done
echo ""
