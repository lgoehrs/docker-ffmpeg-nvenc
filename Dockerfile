FROM ubuntu:xenial
MAINTAINER Benoît Vidis <contact@benoitvidis.com>

WORKDIR /root
RUN  echo "deb http://archive.ubuntu.com/ubuntu/ xenial multiverse" > /etc/apt/sources.list.d/multiverse.list \
  && echo "deb-src http://archive.ubuntu.com/ubuntu/ xenial multiverse" >> /etc/apt/sources.list.d/multiverse.list \
  && apt-get update \
  && apt-get install -y \
      ant \
      autoconf \
      automake \
      build-essential \
      bzip2 \
      cmake \
      curl \
      glew-utils \
      libalut-dev \
      libass-dev \
      libfdk-aac-dev \
      libfreetype6-dev \
      libglew-dbg \
      libglew-dev \
      libglew1.13 \
      libglewmx-dev \
      libglewmx-dbg \
      freeglut3 \
      freeglut3-dev \
      freeglut3-dbg \
      libghc-glut-dev \
      libghc-glut-doc \
      libghc-glut-prof \
      libtheora-dev \
      libtool \
      libva-dev \
      libvorbis-dev \
      libxml2-dev \
      libxmu-dev \
      libxmu-headers \
      libxmu6 \
      libxmu6-dbg \
      libxmuu-dev \
      libxmuu1 \
      libxmuu1-dbg \
      mercurial \
      p7zip-full \
      pkg-config \
      texinfo \
      zlib1g-dev \
      yasm \
  && mkdir -p "$HOME/bin" "$HOME/ffmpeg_build" "$HOME/ffmpeg_sources"

RUN  curl -SL -o fdk-aac.tar.gz https://github.com/mstorsjo/fdk-aac/tarball/master \
  && tar xzvf fdk-aac.tar.gz \
  && cd mstorsjo-fdk-aac* \
  && autoreconf -fiv \
  && ./configure --prefix="$HOME/ffmpeg_build" --disable-shared --enable-debug \
  && make \
  && make install \
  && cd /root \
  && rm -rf mstorsjo*

RUN  apt-get source libmp3lame0 \
  && cd lame* \
  && ./configure --prefix="$HOME/ffmpeg_build" --enable-nasm --disable-shared --enable-debug \
  && make \
  && make install \
  && cd /root \
  && rm -rf lame*

RUN  curl -SLO http://download.videolan.org/pub/x264/snapshots/last_x264.tar.bz2 \
  && tar xjvf last_x264.tar.bz2 \
  && cd x264-snapshot* \
  && PATH="$HOME/bin:$PATH" ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" --enable-static --disable-opencl --enable-debug \
  && PATH="$HOME/bin:$PATH" make \
  && make install \
  && cd /root \
  && rm -rf x264*

RUN  hg clone https://bitbucket.org/multicoreware/x265 \
  && cd x265/build/linux \
  && PATH="$HOME/bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DENABLE_SHARED:bool=off -DCMAKE_BUILD_TYPE=RelWithDebInfo ../../source \
  && make \
  && make install \
  && cd /root \
  && rm -rf x265

RUN  curl -SLO http://downloads.xiph.org/releases/opus/opus-1.1.4.tar.gz \
  && tar xzvf opus-1.1.4.tar.gz \
  && cd opus-1.1.4 \
  && ./configure --prefix="$HOME/ffmpeg_build" --disable-shared --enable-debug \
  && make \
  && make install \
  && cd /root \
  && rm -rf opus*

RUN  curl -SLO http://storage.googleapis.com/downloads.webmproject.org/releases/webm/libvpx-1.6.1.tar.bz2 \
  && tar xjvf libvpx-1.6.1.tar.bz2 \
  && cd libvpx-1.6.1 \
  && PATH="$HOME/bin:$PATH" ./configure --prefix="$HOME/ffmpeg_build" --disable-examples --disable-unit-tests --enable-debug \
  && PATH="$HOME/bin:$PATH" make \
  && make install \
  && cd /root \
  && rm -rf libvpx*

RUN  apt-get source libfribidi0 \
  && cd fribidi-0.19.7 \
  && ./configure --prefix="$HOME/ffmpeg_build" --disable-shared --enable-debug \
  && make \
  && make install \
  && cd /root \
  && rm -rf fribidi*

RUN  apt-get source libharfbuzz0b \
  && cd harfbuzz-1.0.1 \
  && ./configure --prefix="$HOME/ffmpeg_build" --disable-shared --enable-static --enable-debug \
  && make \
  && make install \
  && cd /root \
  && rm -rf harfbuzz*

RUN  curl -SLO https://github.com/libass/libass/releases/download/0.13.6/libass-0.13.6.tar.gz \
  && tar xvf libass-0.13.6.tar.gz \
  && cd libass-0.13.6 \
  && ./configure --prefix="$HOME/ffmpeg_build" --disable-shared --enable-debug \
  && make \
  && make install \
  && cd /root \
  && rm -rf libass*


RUN  curl -SLO http://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2 \
  && tar xvf ffmpeg-snapshot.tar.bz2 

COPY build.sh /root/
CMD ["/root/build.sh"]

