=============================
Plone cartridge for OpenShift
=============================

This package provides a Plone 4.2 cartridge for OpenShift. 

Features:

* Single instance zope server
* Includes Plone 4.2 with plone.app.dexterity by default
* Shared download-cache directory in /var/cache/plone-4.2/
* stores data in OPENSHIFT_DATA_DIR
* stores log in OPENSHIFT_LOG_DIR

Installation
=============

This cartridge was tested on a vm created using OpenShift LiveCD 
with `stickshift-broker-0.6.5`. Following this guide:
https://openshift.redhat.com/community/wiki/build-your-own-paas-from-the-openshift-origin-livecd-using-liveinst

You will need tito to build this RPM::

  yum install tito

Checkout and build::
  
  git clone https://github.com/kagesenshi/cartridge-plone.git
  cd cartridge-plone
  tito build --rpm --test

Copy the generated RPM to your OpenShift server and install it

Edit 
/usr/lib/ruby/gems/1.8/gems/stickshift-controller-0.10.2/lib/stickshift-controller/app/models/cartridge_cache.rb and add 'plone-4.2' in FRAMEWORK_CART_NAMES

Clear the broker cache::
  
  rm -rf /var/www/stickshift/broker/tmp/cache/*

Restart the broker::
  
  service stickshift-broker restart

If everything is setup property, you should have 'plone-4.2' in the cartridge
list

Creating an app
================

Create a app using this command::
  
  rhc app create -a myplonesite -t plone-4.2

To first-run buildout, edit something in your git checkout of myplonesite,
commit and push
