---
layout: post  
title: How to build OpenStack dev packages with custom patches  
tags: linux openstack deb build
---


### Intro  
At some point, you will need building procedure for openstack packages (deb in our case). You can do it with following commands (I use Jenkins job for that).    

### Script  
``#!/bin/bash -ex
rm * || true
pushd sources
git clean -fdx
for remote in `git branch -r`; do git checkout --track $remote || true; done
git checkout patch-queue/master
git reset --hard origin/patch-queue/master
git checkout master
git reset --hard origin/master
git clean -fdx
rm debian/gbp.conf || true
[[ `head -n 1 debian/changelog` =~ .*\((.*)\).* ]]
last_version=${BASH_REMATCH[1]}
new_version=$last_version"+itkey"$BUILD_NUMBER
gbp pq export --commit
#git add --all debian/patches
#git commit -m "Adding patches"
gbp dch -a --upstream-tag=trusty --git-author -R  --spawn-editor=never -N $new_version --commit
gbp buildpackage --git-pbuilder --git-dist=trusty --git-no-purge  --git-ignore-new
debsign``  
