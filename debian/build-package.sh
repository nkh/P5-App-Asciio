#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_URL="https://github.com/nkh/P5-App-Asciio.git"
WORK_DIR="${SCRIPT_DIR}/build"
REPO_DIR="${WORK_DIR}/P5-App-Asciio"

usage()
	{
	cat <<EOF
Usage: $0 [OPTIONS]

Build Debian package for Asciio from GitHub repository.

OPTIONS:
	-h, --help          Show this help message
	-c, --clean         Clean build directory before building
	-i, --install       Install package after building
	-s, --sign          Sign the package (requires GPG key)
	-b, --branch BRANCH Clone specific branch (default: main)

EXAMPLES:
	$0                  Build package
	$0 --clean          Clean and build
	$0 --clean --install Build and install
	$0 --sign           Build and sign package

EOF
	exit 0
	}

clean_build()
	{
	echo "Cleaning build directory..."
	rm -rf "${WORK_DIR}"
	}

check_dependencies()
	{
	echo "Checking build dependencies..."
	
	local missing_deps=()
	local required_packages=(
	"debhelper"
	"devscripts"
	"build-essential"
	"libmodule-build-perl"
	"perl"
	"cpanminus"
	)
	
	for pkg in "${required_packages[@]}"
		{
		if ! dpkg -l | grep -q "^ii  ${pkg}"
			{
			missing_deps+=("$pkg")
			}
		}
	
	if [ ${#missing_deps[@]} -gt 0 ]
		{
		echo "Missing dependencies: ${missing_deps[*]}"
		echo "Install with: sudo apt-get install ${missing_deps[*]}"
		exit 1
		}
	
	echo "All build dependencies satisfied."
	}

clone_repository()
	{
	local branch="$1"
	
	echo "Cloning repository..."
	mkdir -p "${WORK_DIR}"
	
	if [ -n "$branch" ]
		{
		git clone --branch "$branch" "$REPO_URL" "$REPO_DIR"
		}
	else
		{
		git clone "$REPO_URL" "$REPO_DIR"
		}
	}

copy_debian_files()
	{
	echo "Copying Debian packaging files..."
	cp -r "${SCRIPT_DIR}/debian" "${REPO_DIR}/"
	}

build_package()
	{
	local sign_flag=""
	
	if [ "$SIGN_PACKAGE" = "false" ]
		{
		sign_flag="-us -uc"
		}
	
	echo "Building Debian package..."
	cd "${REPO_DIR}"
	
	dpkg-buildpackage $sign_flag -b
	
	echo "Package built successfully!"
	echo "Package location: ${WORK_DIR}/"
	ls -lh "${WORK_DIR}/"*.deb
	}

install_package()
	{
	echo "Installing package..."
	local deb_file=$(ls "${WORK_DIR}"/*.deb | head -1)
	
	if [ -z "$deb_file" ]
		{
		echo "Error: No .deb file found!"
		exit 1
		}
	
	sudo dpkg -i "$deb_file"
	
	echo "Fixing dependencies if needed..."
	sudo apt-get install -f -y
	
	echo "Package installed successfully!"
	}

CLEAN=false
INSTALL=false
SIGN_PACKAGE=false
BRANCH=""

while [[ $# -gt 0 ]]
	{
	case $1 in
	-h|--help)
	usage
	;;
	-c|--clean)
	CLEAN=true
	shift
	;;
	-i|--install)
	INSTALL=true
	shift
	;;
	-s|--sign)
	SIGN_PACKAGE=true
	shift
	;;
	-b|--branch)
	BRANCH="$2"
	shift 2
	;;
	*)
	echo "Unknown option: $1"
	usage
	;;
	esac
	}

echo "=== Asciio Debian Package Builder ==="
echo

if [ "$CLEAN" = true ]
	{
	clean_build
	}

check_dependencies
clone_repository "$BRANCH"
copy_debian_files
build_package

if [ "$INSTALL" = true ]
	{
	install_package
	}

echo
echo "=== Build Complete ==="
echo "Build directory: ${WORK_DIR}"
echo "Package files:"
ls -lh "${WORK_DIR}"/*.deb "${WORK_DIR}"/*.changes 2>/dev/null || true
