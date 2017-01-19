#!/bin/bash

# Change directory to folder with cloned LyX repository
cd "$1"

function failed() {
    printf "Command '%s' failed, exiting\n" "$*"
    exit -1
}

function do_or_fail() {
    printf "# Executing: %s\n" "$*"
    "$@" || failed "$@"
}

# Add a directory out-of-source for building
mkdir -p build
cd build
CMAKE_OPTS=( 
    -DLYX_USE_QT=QT5
    -DLYX_CPACK=ON
    -DCPACK_BINARY_DEB:BOOL=ON
    -DCPACK_SOURCE_TGZ:BOOL=ON
    -DLYX_NLS=ON
    -DLYX_EXTERNAL_Z=ON
    -DLYX_EXTERNAL_ICONV=ON
    -DLYX_EXTERNAL_BOOST=OFF
)

# CMAKE_OPTS=( -DLYX_USE_QT=QT5  -DLYX_CPACK=ON  -DCPACK_SOURCE_TGZ:BOOL=ON )

do_or_fail cmake "${CMAKE_OPTS[@]}" ..
do_or_fail make package
do_or_fail make package_source
