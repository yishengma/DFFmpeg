## mac 下编译安装
##### 1.下载源码
```
git clone https://git.ffmpeg.org/ffmpeg.git ffmpeg
```
##### 2.执行 configure
```
./configure --prefix=/usr/local/ffmpeg --enable-gpl --enable-nonfree --enable-libfdk-aac --enable-libx264 --enable-libx265 --enable-filter=delogo --enable-debug --disable-optimizations --enable-libspeex --enable-videotoolbox --enable-shared --enable-pthreads --enable-version3 --enable-hardcoded-tables --cc=clang --host-cflags= --host-ldflags= --disable-x86asm

```

##### 3.编译安装
```
make &&sudo make install

```

##### 4.配置环境变量
在 zsh 或者 bash 上配置
##### 5.问题
ERROR: libfdk_aac not found
```
brew install fdk-aac
```
ERROR: x264 not found
```
brew install x264
```
ERROR: x265 not found
```
brew install x265
```
ERROR: speex not found
```
brew install speex
```
ERROR: pkg-config not found
```
brew install pkg-config
```
编译ffplay需要sdl2的支持
```
brew  install sdl2
```
一次命令解决
```
brew install fdk-aac&&brew install x264&&brew install x265&&brew install speex&&brew install pkg-config&&brew  install sdl2
```
##### 交叉编译
将配置信息输出成文件,可查看 ./configure 需要传递的参数
```
./configure --help > help.txt
```
### ndk16/gcc编译4.2ffmpeg
#### 1.编写shell 脚本来执行命令
下面贴出的是最开始的脚本，不是最完整，后面会根据问题一步步完善
```
# 定义几个变量
#选择目标架构[armv7a/aarch64/x86/x86_64等]
ARCH=arm
CPU=armv7-a
#指定编译产物的输出路径前缀
PREFIX=`pwd`/android/$ARCH/$CPU
#指定 NDK 路径
NDK=/Users/mayisheng/mayisheng/ndk/android-ndk-r16b

PLATFORM=arm-linux-androideabi

#交叉编译工具前缀，这里的 gcc 编译器
CROSS_COMPILE=$NDK/toolchains/arm-linux-androideabi-4.9/prebuilt/darwin-x86_64/bin/arm-linux-androideabi-

#交叉工具链的头文件和库位,指定 Android 版本
SYSROOT=$NDK/platforms/android-22/arch-arm
ISYSROOT=$NDK/sysroot

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
    #4.2ffmpeg 编译 target-os=android 默认使用clang 编译，修改为 gcc 编译
    --cc=${CROSS_COMPILE}gcc \
    --target-os=android \
    --sysroot=$SYSROOT \
    --disable-asm \
    --arch=$ARCH

#makefile 清除
make clean
#运行Makefile
make 
#安装到 prefix 目录下,sudo 解决 Permission
sudo make install
echo "build ffmpeg finished"

```
#### 2遇到的问题
可到 ffmpeg/ffbuild/config.log 查看错误原因
##### （1）libavdevice.a: No such file or directory
```
/bin/sh: ranlib/usr/local/lib/libavdevice.a: No such file or directory

make: *** [install-libavdevice-static] Error 127
```
这个是在 configure 这个执行文件中，之前修改过 so 的命名方式，但是有错
由于LIB_INSTALL_EXTRA_CMD='$$(RANLIB)"$(LIBDIR)/$(LIBNAME)"'这个命令少打了一个空格，应该改为`LIB_INSTALL_EXTRA_CMD='$$(RANLIB) "$(LIBDIR)/$(LIBNAME)"'。

之后要重新执行下./configure。
##### （2）**C compiler test failed.**
可到 ffmpeg/ffbuild/config.log 查看错误，遇到的一个错误是 
```
rm-linux-androideabi-clang is unable to create an executable file.
```
ffmpeg 4.2 默认使用 clang 来编译，而 NDK 16 还有 gcc （高版本移除了gcc）,所以需要指定编译器参数
```
    --cc=${CROSS_COMPILE}gcc \
```
##### （3）xxx.h: No such file or directory
头文件找不到，是因为NDK16版本把头文件分离出来了，需在添加参数–extra-cflags，其中添加 “-isysroot  $NDK/sysroot”和“-I$ASM”
##### （4）error: request for member 's_addr' in something not a structure or union
网友猜测：新版的 FFmpeg 里使用了 这个结构体， 但是现在使用的是 gcc 编译的。 编译系统中 gcc 没有这个结构体。 当然使用了 clang 就不会出现这个问题。
需要修改 config.h 文件，在extra-cflags 添加参数
```
  --extra-cflags="-I$ASM -isysroot $NDK/sysroot -DHAVE_STRUCT_IP_MREQ_SOURCE=0" \
$ADDITIONAL_CONFIGURE_FLAG
sed -i '' 's/HAVE_STRUCT_IP_MREQ_SOURCE 1/HAVE_STRUCT_IP_MREQ_SOURCE 0/g' config.h
```
##### （5）error: undefined reference to 'stderr'

代码中使用了大量的标准IO设备：stderr 等，这些在NDK15以后，这些都不被支持了，代码本身没问题，只是编译器链接时找不到对应的静态库定义了。在编译选项中添加语句-D__ANDROID_API__=[你的android API版本号]即可；

#### 3完整文件
```


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

```









#### 第三方库编译方法
1.查看README.md

2.编译项目需要Makefile管理，如果已经有写好Makefile可以尝试着用make命令去边编译，如果没有需要自己写Makefile或者采用cmake构建

3.如果报错需要解决，一般情况都是Makefile的一些配置文件没生成，需要运行configure

4.生成配置文件之后，再次运行 make ,这时生成的文件（so,a,或其他）只能在当前系统运行

5.需要 android 或者 ios 就需要交叉编译

6.往configure 传交叉编译参数


