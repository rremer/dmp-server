#!/bin/bash
mkdir -p /var/lib/ksp/backups
tar -czf /var/lib/ksp/backups/$(date +%m-%d-%Y_%A-%H-%M).tgz /var/lib/ksp/Universe
/usr/bin/s3cmd sync /var/lib/ksp/backups/ s3://s3_bucket/
