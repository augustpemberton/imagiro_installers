#!/bin/sh

# load in apple creds for signing & notarization
source ~/apple_creds.sh

# build
./build.sh

# package
mkdir ../../output
./package.sh ../../output
