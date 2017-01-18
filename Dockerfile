# Docker image to build LyX, using Qt5.
# Intended for use on a CI worker (CI node) triggered by a CI server (Jenkins).
#
FROM ubuntu:latest
MAINTAINER Christian Ridderström <chr@lyx.org>

RUN apt-get update						\
        && DEBIAN_FRONTEND=noninteractive apt-get install -y	\
                build-essential					\
		perl						\
		python						\
		bison						\
		flex						\
		"^libxcb.*" libx11-xcb-dev libglu1-mesa-dev libxrender-dev	\
		gperf libicu-dev libxslt-dev ruby		\
		libasound2-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev	\
		libxkbcommon-dev libxkbcommon-x11-dev		\
		libpulse-dev libpci-dev				\
                automake                                        \
                autoconf					\
                zlib1g-dev					\
                pkg-config

#        && rm -rf /var/lib/apt/lists/*

RUN apt-get update						\
        && DEBIAN_FRONTEND=noninteractive apt-get install -y	\
                qtbase5-dev					\
		qt5-default					\
		libqt5svg5-dev					\
		cmake


# Add script that'll do autogen.sh && ./configure && make
ADD ./build_lyx.sh /usr/src

# Start folder
WORKDIR /usr/src

# Default location for LyX repository, as seen/expected by docker image.
ENV LYX_DEFAULT_DIR=/usr/src/lyx

# Default command for docker image, if not given by 'docker run ...'
# CMD /usr/src/build_lyx.sh $LYX_DEFAULT_DIR

# Assuming the LyX source has been cloned to the folder $WORKSPACE
# on e.g. a CI worker with docker, the following docker command builds LyX:
#	docker run -v $WORKSPACE:/usr/src/lyx lyxproject/build-lyx-ubuntu-latest-qt5
# Where options
#	-v  $WORKSPACE:/usr/src/lyx
# mounts the CI worker's folder $WORKSPACE to /usr/src/lyx for the docker image.
#
# For this to work, the '/usr/src/lyx' must match the definition of the
# $LYX_DEFAULT_DIR above, as that is what's used in the default command.
#
# The default command then invokes the script 'build_lyx.sh', that will
# change directory to $LYX_DEFAULt_DIR and build the LyX application.
