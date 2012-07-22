#!/bin/bash

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

if `echo $OPENSHIFT_GEAR_DNS | grep -q .stg.rhcloud.com` || `echo $OPENSHIFT_GEAR_DNS | grep -q .dev.rhcloud.com`
then 
	OPENSHIFT_PYTHON_MIRROR="http://mirror1.stg.rhcloud.com/mirror/python/web/simple"
elif `echo $openshift_gear_dns | grep -q .rhcloud.com`
then
	OPENSHIFT_PYTHON_MIRROR="http://mirror1.prod.rhcloud.com/mirror/python/web/simple"
fi

# Run when jenkins is not being used or run when inside a build
if [ -f "${OPENSHIFT_REPO_DIR}/.openshift/markers/force_clean_build" ]
then
    echo ".openshift/markers/force_clean_build found!  Recreating virtenv" 1>&2
    rm -rf "${OPENSHIFT_GEAR_DIR}"/virtenv/*
fi

if [ ! -f ${OPENSHIFT_GEAR_DIR}/virtenv/bin/python ]
then
    echo "setting up virtualenv"
    cd ~/${OPENSHIFT_GEAR_NAME}/virtenv

    # Hack to fix symlink on rsync issue
    /bin/rm -f lib64
    virtualenv --no-site-packages ~/${OPENSHIFT_GEAR_NAME}/virtenv

fi

if [ ! -f ${OPENSHIFT_REPO_DIR}/bin/buildout ]
then
    pushd ${OPENSHIFT_REPO_DIR}
        cat >> openshift-buildout.cfg << EOF
[buildout]
extends = buildout.cfg
eggs-directory = ${BUILDOUT_CACHE_DIR}/eggs/
download-cache = /var/cache/plone-4.2/
extends-cache = ${BUILDOUT_CACHE_DIR}
effective-user = ${OPENSHIFT_APP_UUID}
log-directory = ${OPENSHIFT_LOG_DIR}
data-directory = ${OPENSHIFT_DATA_DIR}
http-address = ${OPENSHIFT_INTERNAL_IP}:${OPENSHIFT_INTERNAL_PORT}
pyeggcache-directory = ${PYTHON_EGG_CACHE}
host = ${OPENSHIFT_APP_DNS}
EOF
        ~/${OPENSHIFT_GEAR_NAME}/virtenv/bin/python bootstrap.py
        ./bin/buildout -vvvv -c openshift-buildout.cfg
    popd
fi

# Run build
user_build.sh
