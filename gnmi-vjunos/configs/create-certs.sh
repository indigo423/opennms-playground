#!/usr/bin/env bash

R1_CERTS="./configs"

clab tools cert ca create -p ${R1_CERTS}
clab tools cert sign --hosts 192.0.2.11 --ca-key "${R1_CERTS}/ca.key" --ca-cert "${R1_CERTS}/ca.pem" -p "${R1_CERTS}/r1" -n "r1"
