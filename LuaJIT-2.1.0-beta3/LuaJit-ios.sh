#!/bin/sh

: ${IPHONE_SDKVERSION:=`xcodebuild -showsdks | grep iphoneos | egrep "[[:digit:]]+\.[[:digit:]]+" -o | tail -1`}
: ${XCODE_ROOT:=`xcode-select -print-path`}

: ${SRCDIR:=`pwd`}
: ${IOSBUILDDIR:=`pwd`/build/ios/prebuild}
: ${PREFIXDIR:=`pwd`/build/ios/prefix}
: ${IOSFRAMEWORKDIR:=`pwd`/build/ios}
: ${COMPILER:="clang "}

: ${LUA_VERSION:=5.1.5}

#===============================================================================

ARM_DEV_CMD="xcrun --sdk iphoneos"
SIM_DEV_CMD="xcrun --sdk iphonesimulator"

ARMV6_LIB=$IOSBUILDDIR/lib_luajit_armv6.a
ARMV7_LIB=$IOSBUILDDIR/lib_luajit_armv7.a
ARMV7S_LIB=$IOSBUILDDIR/lib_luajit_armv7s.a
ARM64_LIB=$IOSBUILDDIR/lib_luajit_arm64.a
I386_LIB=$IOSBUILDDIR/lib_luajit_i386.a
X86_64_LIB=$IOSBUILDDIR/lib_luajit_x86_64.a




IOSSYSROOT=$XCODE_ROOT/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS$IPHONE_SDKVERSION.sdk
IOSSIMSYSROOT=$XCODE_ROOT/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator$IPHONE_SDKVERSION.sdk

FILES_INC="$SRCDIR/src/lua.h $SRCDIR/src/lualib.h $SRCDIR/src/lauxlib.h $SRCDIR/src/luaconf.h $SRCDIR/src/lua.hpp $SRCDIR/src/luajit.h"

EXTRA_CFLAGS="-DLUA_USE_DLOPEN"



mkdir -p $IOSBUILDDIR


compile_arm() {
echo compiling $1 ...
ISDKF="-arch $1 -isysroot $IOSSYSROOT $EXTRA_CFLAGS"
make -C $SRCDIR/src clean libluajit.a HOST_CC="$COMPILER -m32 -arch i386" CROSS="$ARM_DEV_CMD " TARGET_FLAGS="$ISDKF" TARGET_SYS=iOS
cp $SRCDIR/src/libluajit.a $IOSBUILDDIR/lib_luajit_$1.a
}

compile_arm64() {
echo compiling arm64 ...
ISDKF="-arch arm64 -isysroot $IOSSYSROOT $EXTRA_CFLAGS"
make -C $SRCDIR/src clean libluajit.a HOST_CC="$COMPILER -m64 -arch x86_64" CROSS="$ARM_DEV_CMD " TARGET_FLAGS="$ISDKF" TARGET_SYS=iOS
cp $SRCDIR/src/libluajit.a $IOSBUILDDIR/lib_luajit_arm64.a
}

compile_sim() {
echo compiling sim $1 ...
ISDKF="-arch $1 -isysroot $IOSSIMSYSROOT $EXTRA_CFLAGS"
make -C $SRCDIR/src clean libluajit.a HOST_CC="$COMPILER -m32 -arch $1" CROSS="$SIM_DEV_CMD " TARGET_FLAGS="$ISDKF" TARGET_SYS=iOS
cp $SRCDIR/src/libluajit.a $IOSBUILDDIR/lib_luajit_$1.a
}

#compile_sim i386
#compile_sim x86_64
compile_arm armv7
#compile_arm armv7s
compile_arm64

echo build ios framework ...

LUA_BUILD_DIR=$IOSFRAMEWORKDIR/build


rm -rf $LUA_BUILD_DIR
mkdir -p $LUA_BUILD_DIR/include/
mkdir -p $LUA_BUILD_DIR/lib/
cp -r $FILES_INC $LUA_BUILD_DIR/include/


echo "Lipoing library into ..."
$ARM_DEV_CMD lipo -create $ARMV7_LIB $ARM64_LIB -output "$LUA_BUILD_DIR/lib/luajit.a" || exit


echo framework will be at $IOSFRAMEWORKDIR
echo success!