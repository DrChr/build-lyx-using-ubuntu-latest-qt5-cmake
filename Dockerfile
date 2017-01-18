# Docker image to build LyX
#
# This Dockerfile is used to build a Docker image containing a set of
# tools and libraries that can be used to build LyX from source.
#
# The Docker image is intended to be deployed on a continuous
# integration (CI) worker, a.k.a CI node or slave. See the end of
# this file for further details.
#
FROM ubuntu:latest
MAINTAINER Christian Ridderström <chr@lyx.org>

# Install tools and libraries needed to build LyX
RUN apt-get update						\
        && DEBIAN_FRONTEND=noninteractive apt-get install -y	\
                build-essential					\
		qt5-default					\
                qtbase5-dev					\
		libqt5svg5-dev					\
		python						\
		cmake						\
        && rm -rf /var/lib/apt/lists/*

# Add script that'll be run in the container to build LyX
ADD ./build_lyx.sh /usr/src

# Set default starting direcory and command for the container.
# Mainly useful for interactive troubleshooting.
WORKDIR /usr/src
CMD /bin/bash

#
# 	Usage of Docker image
#
# The Docker image is intended to be used on a CI worker, typically
# through a CI job on a CI server, where the CI job would e.g.:
#
# 1) Clone the source repository to a folder on the CI worker
# 2) Start a Docker container (process), using the Docker image as a
#    template.
# 3) "Bind-mount" the folder with the LyX source to the container,
#    making the folder and LyX source available to the container.
# 4) Make the container run the script that builds LyX
#
# A Docker command to do the above is given at the end.
#
# When the build is done, the build script will exit and the container
# will stop. The build results are then available to the CI worker in
# the folder that was bind mounted.
#
# For troubleshooting the containerr, it's useful to start it in
# interactive mode with a working terminal as follows:
#	docker run -i -t  $CONTAINER /bin/bash
#
# The rows below are suitable for the command section of CI job
# (uncomment the last two rows):
# ----------------------------------------------------------------------
#
# With the source repository cloned to a folder $WORKSPACE, and
# $CONTAINER set to the name of the Docker image, the following
# commands will:
# - Start a Docker container (process), with $WORKSPACE bind-mounted
#   to $SRC in the container, and
# - Make the container execute the script 'build_lyx.sh' that builds LyX
# Note: Once the build script is done, it exits and the container stops
# but is not automatically removed.
#
# SRC=/usr/src/lyx  # Destination of bind-mounted $WORKSPACE in the container
# docker run -v $WORKSPACE:$SRC  $CONTAINER  /usr/src/build_lyx.sh $SRC
