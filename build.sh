#!/bin/bash

# config

export ORIGINAL_PATH=`pwd`
export SANDWICH=`pwd`
export SANDWICH_METADATA=`pwd`/metadata
export GLIBC_VERSION=2.35
export BUSYBOX_VERSION=1.35.0
export COREUTILS_VERSION=9.1

export SANDWICH_OUTPUT=`pwd`/packages
export SLICE_BINARY=`pwd`/slice

# create directories

mkdir -p $SANDWICH_OUTPUT

if [ ! -d $SANDWICH/source ]
then
	mkdir -p $SANDWICH/source/tarball
	mkdir -p $SANDWICH/source/decompressed

	# download tarballs

	wget https://ftp.gnu.org/gnu/glibc/glibc-$GLIBC_VERSION.tar.gz -O $SANDWICH/source/tarball/glibc-$GLIBC_VERSION.tar.gz
	wget https://www.busybox.net/downloads/busybox-$BUSYBOX_VERSION.tar.bz2 -O $SANDWICH/source/tarball/busybox-$BUSYBOX_VERSION.tar.bz2
	wget https://ftp.gnu.org/gnu/coreutils/coreutils-$COREUTILS_VERSION.tar.gz -O $SANDWICH/source/tarball/coreutils-$COREUTILS_VERSION.tar.gz
fi

# compile glibc

if [ ! -d $SANDWICH/source/decompressed/glibc-$GLIBC_VERSION ]
then
	tar -xvf $SANDWICH/source/tarball/glibc-$GLIBC_VERSION.tar.gz -C $SANDWICH/source/decompressed
fi

mkdir $SANDWICH/source/decompressed/glibc-$GLIBC_VERSION/build

cd $SANDWICH/source/decompressed/glibc-$GLIBC_VERSION/build

if [ ! -d slice-package ]
then
	mkdir -p slice-package/lib/x86_64-linux-gnu
fi

../configure --libdir=/lib/x86_64-linux-gnu --prefix=/ && make -j8 && make install DESTDIR=`pwd`/slice-package && ln -s lib slice-package/lib64 && cp $SANDWICH_METADATA/glibc.json slice-package/metadata.json && $SLICE_BINARY create slice-package $SANDWICH_OUTPUT/glibc.slicepkg

rm -r slice-package

cd $ORIGINAL_PATH

# compile coreutils

if [ ! -d $SANDWICH/source/decompressed/coreutils-$COREUTILS_VERSION ]
then
	tar -xvf $SANDWICH/source/tarball/coreutils-$COREUTILS_VERSION.tar.gz -C $SANDWICH/source/decompressed
fi

cd $SANDWICH/source/decompressed/coreutils-$COREUTILS_VERSION

if [ ! -d slice-package ]
then
	mkdir -p slice-package
fi

./configure --libdir=/lib/x86_64-linux-gnu --prefix=/ && make -j8 && make install DESTDIR=`pwd`/slice-package && ln -s lib slice-package/lib64 && cp $SANDWICH_METADATA/coreutils.json slice-package/metadata.json && $SLICE_BINARY create slice-package $SANDWICH_OUTPUT/coreutils.slicepkg

rm -r slice-package

cd $ORIGINAL_PATH

# compile busybox

if [ ! -d $SANDWICH/source/decompressed/busybox-$BUSYBOX_VERSION ]
then
	tar -xvf $SANDWICH/source/tarball/busybox-$BUSYBOX_VERSION.tar.bz2 -C $SANDWICH/source/decompressed
fi

cd $SANDWICH/source/decompressed/busybox-$BUSYBOX_VERSION

make defconfig && make -j8 && make install && cp $SANDWICH_METADATA/busybox.json _install/metadata.json && $SLICE_BINARY create _install $SANDWICH_OUTPUT/busybox.slicepkg

rm -r _install

cd $ORIGINAL_PATH