

# 定义几个变量
ARCH=arm
CPU=armv7-a

PREFIX=`pwd`/android/$ARCH/$CPU
#编译平配置：基于android的armeabi平台
NDK=/Users/mayisheng/mayisheng/ndk/android-ndk-r16b
PLATFORM=arm-linux-androideabi

CROSS_COMPILE=$NDK/toolchains/arm-linux-androideabi-4.9/prebuilt/darwin-x86_64/bin/arm-linux-androideabi-
#CROSS_COMPILE=/Users/mayisheng/mayisheng/ndk/android-ndk-r16b/toolchains/llvm/prebuilt/darwin-x86_64/bin/
SYSROOT=$NDK/platforms/android-22/arch-arm
ISYSROOT=$NDK/sysroot
ASM=$ISYSROOT/usr/include/$PLATFORM

#定义build 方法来执行configure
./configure --prefix=$PREFIX \
    --enable-shared \
    --disable-static \
    --disable-doc \
    --disable-ffmpeg \
    --disable-ffplay \
    --disable-symver \
    --enable-cross-compile \
    --disable-avdevice \
    --cross-prefix=$CROSS_COMPILE \
    --cc=${CROSS_COMPILE}gcc \
    --extra-cflags="-I$ASM -isysroot $NDK/sysroot -D__ANDROID_API__=22 -DHAVE_STRUCT_IP_MREQ_SOURCE=0" \
    --target-os=android \
    --sysroot=$SYSROOT \
    --disable-asm \
    --arch=$ARCH
$ADDITIONAL_CONFIGURE_FLAG
sed -i '' 's/HAVE_STRUCT_IP_MREQ_SOURCE 1/HAVE_STRUCT_IP_MREQ_SOURCE 0/g' config.h

#makefile 清除
make clean
#运行Makefile
make 
#安装到 prefix 目录下,sudo 解决 Permission
sudo make install
echo "build ffmpeg finished"

