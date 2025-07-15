#!/usr/bin/env bash

# default password is admin@123
scp -O ./r1.* admin@192.0.2.11:/var/tmp
ssh admin@192.0.2.11 "request security pki local-certificate load certificate-id r1-cert filename /var/tmp/r1.pem key /var/tmp/r1.key"
