#!/bin/bash

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

rm -rf ${SCRIPT_DIR}/build
mkdir ${SCRIPT_DIR}/build
BUILD_DIR=${SCRIPT_DIR}/build

cp -r lambda/dashboard_prep/* $BUILD_DIR
cd $BUILD_DIR

zip -r dashboard_prep.zip .

cd ..

cp $BUILD_DIR/dashboard_prep.zip terraform/modules/files/dashboard_prep.zip


rm -rf $BUILD_DIR