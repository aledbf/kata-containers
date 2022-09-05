#!/bin/bash

#https://github.com/kata-containers/kata-containers/blob/main/docs/install/kata-containers-3.0-rust-runtime-installation-guide.md

pushd tools/packaging/kata-deploy/local-build
make kata-tarball
popd

cp tools/packaging/kata-deploy/local-build/kata-static.tar.xz .
