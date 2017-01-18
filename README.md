# Docker image intended for use with LyX CI system

The primary purpose of this repository is to:

* Build a Docker image for use with the LyX project's continous
  integration (CI) system.
* The Docker image is run as a Docker container on a CI worker.
* The container contains the tools neccessary to build the LyX
  application and is used for this purpose.

See the ./Dockerfile for more information and details.

Note: A developer could use this Docker image to perform a similar
build on his local machine.

# References

* The LyX project - http://www.lyx.org



