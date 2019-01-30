#!/bin/bash -ex

SOURCE_DIR=/opt/codedeploy-agent/deployment-root/$DEPLOYMENT_GROUP_ID/$DEPLOYMENT_ID/deployment-archive

TARGET_DIR=/etc/nginx

cp $SOURCE_DIR/azlits.key $TARGET_DIR
cp $SOURCE_DIR/azlits.pem $TARGET_DIR

if [[ "$DEPLOYMENT_GROUP_NAME" == *"Build"* ]]; then
	STAGE=Build
elif [[ "$DEPLOYMENT_GROUP_NAME" == *"Prod"* ]]; then
	STAGE=Prod 
else
	echo Error: expected substring Build or Prod in variable DEPLOYMENT_GROUP_NAME. Got "$DEPLOYMENT_GROUP_NAME" instead.;
	exit 1
fi

APP=jil
PAR_KEY=PAR${STAGE}${APP}INSNodePrivateIp
FRONTEND_HOST=$(aws ssm get-parameters --names $PAR_KEY --region us-east-1 --query "Parameters[0].{Value:Value}" | grep Value | cut -f 2 -d : | tr -d '"' | tr -d ' ')
test ! -z $FRONTEND_HOST

PAR_KEY=PAR${STAGE}${APP}INSTomcatPrivateIp
BACKEND_HOST=$(aws ssm get-parameters --names $PAR_KEY --region us-east-1 --query "Parameters[0].{Value:Value}" | grep Value | cut -f 2 -d : | tr -d '"' | tr -d ' ')
test ! -z $BACKEND_HOST

. $SOURCE_DIR/${STAGE}.env
test ! -z $FRONTEND_PORT
test ! -z $BACKEND_PORT

cp $SOURCE_DIR/nginx.template.conf $SOURCE_DIR/nginx.conf

sed -i "s/FRONTEND_HOST/$FRONTEND_HOST/g" $SOURCE_DIR/nginx.conf
sed -i "s/FRONTEND_PORT/$FRONTEND_PORT/g" $SOURCE_DIR/nginx.conf
sed -i "s/BACKEND_HOST/$BACKEND_HOST/g" $SOURCE_DIR/nginx.conf
sed -i "s/BACKEND_PORT/$BACKEND_PORT/g" $SOURCE_DIR/nginx.conf

mv $SOURCE_DIR/nginx.conf $TARGET_DIR

