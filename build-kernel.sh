#!/bin/bash

set -x

set -eo pipefail

DISTRO=ubuntu
KERNEL=5.19.6

# extracted from build-kernel.sh
readonly script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly default_patches_dir="${script_dir}/tools/packaging/kernel/patches"

get_config_version() {
	get_config_and_patches
	config_version_file="${default_patches_dir}/../kata_config_version"
	if [ -f "${config_version_file}" ]; then
		cat "${config_version_file}"
	else
		die "failed to find ${config_version_file}"
	fi
}

KERNEL_CONFIG_VERSION=$(get_config_version)

echo "building kernel..."
pushd tools/packaging/kernel
./build-kernel.sh -v "${KERNEL}" -f -d -x sev setup
./build-kernel.sh -v "${KERNEL}" -f -d -x sev build
./build-kernel.sh -v "${KERNEL}" -f -d -x sev install
popd

KERNEL_MODULES_DIR="${script_dir}/tools/packaging/kernel/kata-linux-${KERNEL}-${KERNEL_CONFIG_VERSION}/lib/modules/${KERNEL}"

echo "Generating assets"

DIST="${script_dir}/dist/${DISTRO}-${KERNEL}"
mkdir -p "${DIST}"

cp /usr/share/kata-containers/config-${KERNEL} "${DIST}/config-${KERNEL}-${KERNEL_CONFIG_VERSION}"
cp /usr/share/kata-containers/vmlinuz-${KERNEL}-${KERNEL_CONFIG_VERSION}-sev "${DIST}/vmlinuz-${KERNEL}-${KERNEL_CONFIG_VERSION}"
cp /usr/share/kata-containers/vmlinux-${KERNEL}-${KERNEL_CONFIG_VERSION}-sev "${DIST}/vmlinux-${KERNEL}-${KERNEL_CONFIG_VERSION}"
