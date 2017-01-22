#!/bin/bash
# Example:
# 	build_lyx_extended.sh /usr/src/lyx
# where '/usr/src/lyx' is a folder containing a clone (or export) of
# the LyX repository.
#
function failed() {
    printf "Command '%s' failed, exiting\n" "$*"
    exit -1
}
function do_or_fail() {
    printf "# Executing: %s\n" "$*"
    "$@" || failed "$@"
}
function get_absolute_dir() {
    echo "$(cd "$1" && pwd)"
}
function show_desc() {
    local folder_name="$1"
    local folder_description="$2"
    printf "%-32s %s\n" "$folder_name" "$folder_description"
}

# Define folders:
clone_dir="$(get_absolute_dir "$1")"
build_dir="$clone_dir/build"
src2_dir="$build_dir/src_pkg" 
build2_dir="$build_dir/build2" 
show_desc "Folder:"     "Folder is used as follows:"
show_desc "$clone_dir"  "Clone (or export) of LyX repository"
show_desc "$build_dir"  "Build folder used by CMake and make"
show_desc "$src2_dir"   "To contain source extracted from generated source pkg"
show_desc "$build2_dir" "Build folder for test to generate Debian pkg from generated src pkg"

version=2.3
name=LyX-$version
printf "\nName of LyX source package is: %s\n" "$name.tar.gz"

do_or_fail cd "$clone_dir"
do_or_fail mkdir -p "$build_dir"
# do_or_fail rm -rf "$build_dir"	# Q: Should this script first clear build/
do_or_fail cd       "$build_dir"

# Notes on CMake configuration options:
# (1) Configure for creation of Debian .deb-package,
#     e.g. via 'make package', where the package can later
#     be installed with 'dpkg -i $packagename'
# (2) Configure for creation of source package,
#     e.g. via 'make package_source'
# (3) Use xgettext, msgfmt, msgmerge etc for creation of .gmo files
# (4) Use external libz because of conflicts with our supplied sources
#     (valid for windows? only)
# (5) Use external libiconv because of conflicts with our supplied
#     sources (valid for windows? only)
# (6) Use source code for Boost that's supplied with LyX
CMAKE_OPTS=( 
    -DLYX_USE_QT=QT5 		# Use Qt5
    -DLYX_CPACK=ON 		# Use the cpack macros
    -DCPACK_BINARY_DEB:BOOL=ON 	# (1) Configure to create Debian package
    -DCPACK_SOURCE_TGZ:BOOL=ON 	# (2) Configure to create source package
    -DLYX_NLS=ON 		# (3) Use xgettext, msgfmt, msgmerge etc
    -DLYX_EXTERNAL_Z=ON		# (4) Use external libz
    -DLYX_EXTERNAL_ICONV=ON 	# (5) Use external libiconv
    -DLYX_EXTERNAL_BOOST=OFF 	# (6) Use Boost source code supplied with LyX
)
do_or_fail cmake .. "${CMAKE_OPTS[@]}" 	# Generate Makefile(s) etc
do_or_fail make package 	# (Build LyX and) generate Debian package (.deb)
do_or_fail make package_source 	# Generate source package (.tar.gz)

# Test making Debian package based on the previously generated source pkg.
# First extract source package to $src2_dir/$name/
do_or_fail mkdir -p "$src2_dir"
do_or_fail rm   -rf "$src2_dir/$name"
do_or_fail tar   -C "$src2_dir"  -x -f "$build_dir/$name.tar.gz"
# Next test making a Debian package based on the extracted source
do_or_fail mkdir -p "$build2_dir"
do_or_fail rm   -rf "$build2_dir/*"
do_or_fail cd       "$build2_dir"
do_or_fail cmake    "$src2_dir/$name"  "${CMAKE_OPTS[@]}"
do_or_fail make package 		

