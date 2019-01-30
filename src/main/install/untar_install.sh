#!/bin/bash -ex

SOURCE_DIR=/opt/codedeploy-agent/deployment-root/$DEPLOYMENT_GROUP_ID/$DEPLOYMENT_ID/deployment-archive
for tar in $(ls $SOURCE_DIR/*.tar.gz); do
  tar xvfz $tar -C $SOURCE_DIR
done

