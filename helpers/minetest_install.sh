#!/bin/bash

MINETEST_VERSION="5.8.0"
IRRLICHT_VERSION="1.9.0mt13"

MINETEST_GIT="https://github.com/minetest/minetest.git"
IRRLICHT_GIT="https://github.com/minetest/irrlicht.git"

BASE_SRC_DIR="/home/shared/.minetest"
MINETEST_DIR="$BASE_SRC_DIR/minetest"


echo "needs the following packages:"
echo "apt-get install g++ make libc6-dev cmake libpng-dev libjpeg-dev libgl1-mesa-dev libsqlite3-dev libogg-dev libvorbis-dev libopenal-dev libcurl4-gnutls-dev libfreetype6-dev zlib1g-dev libgmp-dev libjsoncpp-dev libzstd-dev libluajit-5.1-dev gettext libsdl2-dev"
read -p "Press <ENTER> to continue…"

mkdir -p $BASE_SRC_DIR

cd $BASE_SRC_DIR

if [ ! -d minetest ]; then
    git clone --depth 1 $MINETEST_GIT
fi

cd $MINETEST_DIR

git fetch --all --tags --prune

git pull

git checkout tags/$MINETEST_VERSION -b $MINETEST_VERSION

git clone --depth=1 $IRRLICHT_GIT lib/irrlichtmt

cd $MINETEST_DIR/lib/irrlichtmt

git fetch --all --tags --prune

git checkout tags/$IRRLICHT_VERSION -b $IRRLICHT_VERSION

git pull

cd $MINETEST_DIR

cmake . -DRUN_IN_PLACE=FALSE
make -j$(nproc)

/home/shared/set_rights.sh
