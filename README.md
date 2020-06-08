#### mac 下编译安装
##### 1.下载源码
```
git clone https://git.ffmpeg.org/ffmpeg.git ffmpeg
```
#### 2.执行 configure
```
./configure --prefix=/usr/local/ffmpeg --enable-gpl --enable-nonfree --enable-libfdk-aac --enable-libx264 --enable-libx265 --enable-filter=delogo --enable-debug --disable-optimizations --enable-libspeex --enable-videotoolbox --enable-shared --enable-pthreads --enable-version3 --enable-hardcoded-tables --cc=clang --host-cflags= --host-ldflags= --disable-x86asm

```

#### 3.编译安装
```
make &&sudo make install

```

#### 4.配置环境变量
在 zsh 或者 bash 上配置
#### 5.问题
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

