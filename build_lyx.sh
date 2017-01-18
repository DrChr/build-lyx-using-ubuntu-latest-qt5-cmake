#!/bin/sh
cd "$1"

# Add a directory out-of-source for building
mkdir -p build
cd build
cmake -DLYX_USE_QT=QT5 .. && make
