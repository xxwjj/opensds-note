#!/usr/bin/env bash

set -o xtrace
set -o errexit

OPENSDS_AUTH_STRATEGY=${OPENSDS_AUTH_STRATEGY:-keystone}
OPENSDS_BRANCH=${OPENSDS_BRANCH:-development}
GITHUB_USER_NAME=xxwjj
HOST_IP=${HOST_IP:-127.0.0.1}


get_token(){
    source /opt/stack/devstack/openrc admin admin &> /dev/null
    openstack token issue | awk '{if($2 == "id")print $4}'
}

probe_hotpot() {
    curl -sSL $HOST_IP:50040 &> /dev/null
    return $?
}

probe_gelato(){
    TOKEN=$(get_token)
    curl -sSL $HOST_IP:8089/v1/adminTenant/plans -H "X-Auth-Token:$TOKEN" &> /dev/null
    return $?
}

probe_dashbord(){
    curl -sSL $HOST_IP:8088 &> /dev/null
    return $?
}

# git configuration
git config --global alias.co checkout
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.br branch
git config --global user.email "jay_wcom@163.com"
git config --global user.name "jerry"

# Hotpot installation
curl -sSL https://raw.githubusercontent.com/opensds/opensds/master/script/devsds/bootstrap.sh | sudo bash
source /etc/profile
HOTPOT_DIR=$GOPATH/src/github.com/opensds/opensds
DEVSDS_DIR=$GOPATH/src/github.com/opensds/opensds/script/devsds
if ! probe_hotpot; then
    sed -i "s,OPENSDS_AUTH_STRATEGY=.*$,OPENSDS_AUTH_STRATEGY=$OPENSDS_AUTH_STRATEGY," $DEVSDS_DIR/local.conf
    $DEVSDS_DIR/install.sh
fi
cd $HOTPOT_DIR
git remote |grep $GITHUB_USER_NAME -wiq || git remote add $GITHUB_USER_NAME https://github.com/$GITHUB_USER_NAME/opensds.git
cd -

# Gelato installation
GELATO_DIR=$GOPATH/src/github.com/opensds/multi-cloud
if ! probe_gelato ; then
    curl -sSL https://raw.githubusercontent.com/opensds/multi-cloud/master/script/bootstrap.sh | sudo bash
fi

cd $GELATO_DIR
git remote |grep $GITHUB_USER_NAME -wiq || git remote add $GITHUB_USER_NAME https://github.com/$GITHUB_USER_NAME/multi-cloud.git
cd -

#Dashborad
if ! probe_dashbord ; then
docker run -d --net=host --name opensds-dashborad opensdsio/dashboard:latest
fi

set +o xtrace
