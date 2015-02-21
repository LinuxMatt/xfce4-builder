#!/bin/bash

GITHUB_URL="https://github.com/xfce-mirror"
BUILD_FILE="build-order.conf"
DEBS_FILE="deb-dependencies.conf"
TARGET_DIR="/usr/local"
FILTERCMD="grep -v #"
GEN_SCRIPT="./autogen.sh"
GEN_OPTIONS="--enable-debug=yes  --prefix=${TARGET_DIR} \
--sysconfdir=${TARGET_DIR}/etc --localstatedir=/var"

action_title() {
	echo "##"
	echo "##"
	echo "##     ${1}"
	echo "##"
}
action_gitup() {
	if [ ! -d "${1}" ]; then
		echo -e "\nGit Project ${1} is missing. Cloning it first."
		git clone ${GITHUB_URL}/${2}${1}.git || exit 1
	fi
	if [ ! -d "${1}" ]; then
		echo "Git Project ${1} is still missing. Abort."
		exit 1
	fi
	cd "${1}"
	if [ "x${?}" != "x0" ]; then
		echo "Change directory FAILED"
		exit 1
	fi
	action_title "UPDATING directory ${1}"
	git pull
	if [ "x${?}" != "x0" ]; then
		echo "Git pull FAILED"
		exit 1
	fi
	cd -
}
action_update_all() {
	for d in $($FILTERCMD $BUILD_FILE)
	do
		action_gitup "${d}"
	done
}
action_installpkg() {
	action_title "INSTALLING ${1}"
	sudo apt-get install -y ${1}
	if [ "x${?}" != "x0" ]; then
		[ "x${2}" = "xforce" ] || exit 1
	fi
}
action_installdeps() {
	action_title "INSTALLING DEPENDENCIES..."
	for d in $(${FILTERCMD} ${DEBS_FILE})
	do
		action_installpkg "${d}" ${1}
	done
}
action_pause() {
	echo -e "\nPress any key to continue...\n";
	read k
}
action_build() {
	if [ ! -d "${1}" ]; then
		action_gitup "${1}"
	fi
	cd ${1}
	if [ ! -f "${GEN_SCRIPT}" ]; then
		action_title "File ${GEN_SCRIPT} is MISSING. Abort."
		exit 1
	fi
	action_title "BUILDING ${1}"
	echo "==== PREPARING."
	${GEN_SCRIPT} ${GEN_OPTIONS} || exit 2
	echo "==== READY TO MAKE."
	[ "x${2}" = "xauto" ] || action_pause
	make || exit 2
	echo "==== READY TO INSTALL."
	[ "x${2}" = "xauto" ] || action_pause
	sudo /usr/bin/make install || exit 2
	cd -
}
action_build_all() {
	for d in $(${FILTERCMD} $BUILD_FILE)
	do
		action_build "${d}"
	done
}
action_build_from() {
	for d in $(${FILTERCMD} "${1}")
	do
		action_build "${d}"
	done
}
action_autobuild_from() {
	for d in $(${FILTERCMD} "${1}")
	do
		action_build "${d}" auto
	done
}
action_build_auto() {
	for d in $(${FILTERCMD} $BUILD_FILE)
	do
		action_build "${d}" auto
	done
}
action_clean() {
	if [ ! -d "${1}" ]; then
		action_title "${1} directory is MISSING."
	else
		cd ${1}
		action_title "CLEANING ${1}"
		make maintainer-clean
		cd -
	fi
}
action_clean_all() {
	for d in $(${FILTERCMD} $BUILD_FILE)
	do
		action_clean "${d}"
	done
}
usage() {
	echo -e "\nUSAGE: ${0} <setup|setup-force|update|update-all|clean|clean-all>"
	echo -e "\t\t\t<(auto)build|(auto)build-all|(auto)build-from>\n"
	echo -e "\tsetup        : install required deb packages for building"
	echo -e "\tupdate <dir> : fetch and update from Github"
	echo -e "\tbuild  <dir> : configure, compile and install to ${TARGET_DIR}"
	echo -e "\tclean  <dir> : remove the files created by the 'build' action"
	echo -e "\n\tOptional keywords:"
	echo -e "\tall   : process all projects from file ${BUILD_FILE}"
	echo -e "\tfrom  : read list of projects from given <file>"
	echo -e "\tauto  : automatic build without user interaction"
	echo -e "\tforce : script will not stop on errors"
	echo -e ""
	exit 2
}

if [ -z ${1} ] ; then
	usage
fi

ACTION=${1}
case "x${ACTION}" in
	"xsetup")
		action_installdeps
		;;
	"xsetup-force")
		action_installdeps force
		;;
	"xupdate")
		[ -z ${2} ] && usage
		action_gitup "${2}"
		;;
	"xupdate-all")
		action_update_all
		;;
	"xbuild")
		[ -z ${2} ] && usage
		action_build "${2}"
		;;
	"xautobuild")
		[ -z ${2} ] && usage
		action_build "${2}" auto
		;;
	"xautobuild-all")
		action_build_auto
		;;
	"xbuild-all")
		action_build_all
		;;
	"xbuild-from")
		[ -z ${2} ] && usage
		action_build_from "${2}"
		;;
	"xautobuild-from")
		[ -z ${2} ] && usage
		action_autobuild_from "${2}"
		;;
	"xclean")
		[ -z ${2} ] && usage
		action_clean "${2}"
		;;
	"xclean-all")
		action_clean_all
		;;
	*)
		usage
		;;
esac

