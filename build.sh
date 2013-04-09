#!/bin/bash
# Build the UI.
# This script is written to be run on any system, especially a Jenkins
# build server. It will install node.js (only if running on jenkins)
# and any necessary NPMs, then run grunt to build the UI.

set -e
set -x

# This is the latest stable version that cloudbees has
NODE_VERSION=0.8.8

is_cloudbees(){
    case "$JENKINS_URL" in
        *\.ci\.cloudbees\.com*) return 0;;
        *) return 1;;
    esac
}

cwd=`pwd`
PATH=$PATH:$cwd/node_bin

set +e
node=`which node 2>&1`
ret=$?
set -e
if [ $ret -ne 0 ] || [ ! -x "$node" ]; then
    if is_cloudbees; then
        # Install node.js on cloudbees
        curl -s -o use-node https://repository-cloudbees.forge.cloudbees.com/distributions/ci-addons/node/use-node
        source ./use-node
        rm -f ./use-node
        ls
        env
        pwd
    else
        # TODO:  Pick the right node executable for the environment!!!
        mkdir node_bin
        curl -o node_bin/node.exe http://nodejs.org/dist/v${NODE_VERSION}/x64/node.exe
    fi
fi

set +e
npm=`which npm 2>&1`
ret=$?
set -e
if [ $ret -ne 0 ] || [ ! -x "$npm" ] || is_cloudbees; then
    # Note, this must always be run on Cloudbees for some reason, the
    # built-in npm doesn't work.
    export clean=yes
    export skipclean=no
    curl https://npmjs.org/install.sh | sh
fi

# install all the packages defined in package.json
npm install

# run the actual UI build
make bootstrap-css

# Just make sure this sucker exists and is in the expected format
# tar tzf assets.tgz >/dev/null

# Display sha256sum, which is used by chef
# set +e; which sha256sum >/dev/null && sha256sum assets.tgz; set -e


