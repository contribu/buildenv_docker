FROM buildpack-deps:bionic

SHELL ["/bin/bash", "-c"]

ENV PATH /root/.pyenv/bin:/root/google-cloud-sdk/bin:$PATH
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
ENV LIBRARY_PATH /usr/local/lib:$LIBRARY_PATH
# https://qiita.com/yagince/items/deba267f789604643bab
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get install gcc-8 g++-8 \
  && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 700 --slave /usr/bin/g++ g++ /usr/bin/g++-7 \
  && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 800 --slave /usr/bin/g++ g++ /usr/bin/g++-8 \
  && ( \
    cd $(mktemp -d) \
    && git clone -b gcc.amd64 https://github.com/cloudflare/zlib.git \
    && cd zlib \
    && ./configure \
    && make -j 4 \
    && make install \
  ) && ( \
    cd $(mktemp -d) \
    && git clone -b libpng16 https://github.com/glennrp/libpng.git \
    && cd libpng \
    && ./configure --enable-hardware-optimizations=yes \
    && make -j 4 \
    && make install \
  ) \
  && curl -sL https://deb.nodesource.com/setup_10.x | bash \
  && curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash \
  && apt-get install -y \
    software-properties-common \
  && add-apt-repository -y ppa:ubuntu-toolchain-r/test \
  && add-apt-repository -y ppa:brightbox/ruby-ng \
  && add-apt-repository ppa:git-core/ppa \
  && apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y \
    git \
    git-lfs \
    gnuplot \
    gsfonts \
    imagemagick \
    libflac-dev \
    libgflags-dev \
    libmagick++-dev \
    libmp3lame-dev \
    libogg-dev \
    libopus-dev \
    libpoco-dev \
    libsndfile1-dev \
    libtag1-dev \
    libtbb-dev \
    libvorbis-dev \
    libvpx-dev \
    nasm \
    nodejs \
    optipng \
    pngquant \
    postgresql \
    redis-server \
    ruby2.5 \
    ruby2.5-dev \
    sox \
    time \
    tmpreaper \
    vim \
    unifont \
    unzip \
    wget \
    yasm \
    zip \
  && git lfs install \
  && ( \
    echo latest upx is needed for cosmic \
    cd $(mktemp -d) \
    && wget https://github.com/upx/upx/releases/download/v3.95/upx-3.95-amd64_linux.tar.xz \
    && tar xfv upx-3.95-amd64_linux.tar.xz \
    && mv upx-3.95-amd64_linux/upx /usr/bin \
  ) \
  && ( \
    cd $(mktemp -d) \
    && wget https://cmake.org/files/v3.12/cmake-3.12.2.tar.gz \
    && tar xfvz cmake-3.12.2.tar.gz \
    && cd cmake-3.12.2 \
    && ./bootstrap -- -DCMAKE_BUILD_TYPE:STRING=Release \
    && make -j `nproc` \
    && make install \
  ) \
  && ( \
    VER="17.03.0-ce" \
    && curl -L -o /tmp/docker-$VER.tgz https://get.docker.com/builds/Linux/x86_64/docker-$VER.tgz \
    && tar -xz -C /tmp -f /tmp/docker-$VER.tgz \
    && mv /tmp/docker/* /usr/bin \
  ) \
  && ( \
    curl -L https://github.com/docker/compose/releases/download/1.16.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose \
  ) \
  && ( \
    (curl -L https://gist.githubusercontent.com/contribu/8a572edaccb86ae749449a3fec83ce5f/raw/d90b011686e79e8072a5df06673b2b0abc646d94/install_ffmpeg_supporting_openh264.sh | bash) \
  ) \
  && ( \
    VER="3.3.8" \
    && cd $(mktemp -d) \
    && wget ftp://ftp.fftw.org/pub/fftw/fftw-${VER}.tar.gz \
    && tar xfvz fftw-${VER}.tar.gz \
    && cd fftw-${VER} \
    && echo "configure options: http://www.fftw.org/fftw3_doc/Installation-on-Unix.html" \
    && echo "compiler support needed but cpu support is not needed" \
    && ./configure --enable-float --enable-sse --enable-sse2 --enable-avx --enable-avx2 --enable-avx-128-fma \
    && make -j `nproc` \
    && make install \
    && make clean \
    && ./configure --enable-sse2 --enable-avx --enable-avx2 --enable-avx-128-fma \
    && make -j `nproc` \
    && make install \
  ) \
  && ( \
    cd $(mktemp -d) \
    && wget https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-180.0.0-linux-x86_64.tar.gz \
    && tar xfvz google-cloud-sdk-180.0.0-linux-x86_64.tar.gz \
    && mv google-cloud-sdk /root/google-cloud-sdk \
    && /root/google-cloud-sdk/install.sh --quiet \
    && gcloud config set component_manager/disable_update_check true \
  ) \
  && ( \
    curl -L https://raw.githubusercontent.com/pyenv/pyenv-installer/eceeb9b82a1f8de7ce7bf65a14f5ac149102ad9e/bin/pyenv-installer | bash \
    && eval "$(pyenv init -)" \
    && pyenv install 3.6.5 \
    && pyenv shell 3.6.5 \
    && pip install pipenv \
  ) \
  && ( \
    cd $(mktemp -d) \
    && wget https://github.com/gohugoio/hugo/releases/download/v0.42.1/hugo_0.42.1_Linux-64bit.tar.gz \
    && tar -zxvf hugo_0.42.1_Linux-64bit.tar.gz \
    && mv hugo /usr/bin/ \
  ) \
  && ( \
    cd $(mktemp -d) \
    && wget ftp://ftp.acousticbrainz.org/pub/acousticbrainz/abzsubmit-0.1-linux-x86_64.tar.gz \
    && tar -zxvf  abzsubmit-0.1-linux-x86_64.tar.gz \
    && cd abzsubmit-0.1 \
    && mv streaming_extractor_music /usr/bin/ \
  ) \
  && ( \
    echo 'remove large unused files' \
    && rm -rf \
      /usr/local/libav* \
      $(which ffserver) \
  ) \
  && ( \
    echo 'upx large binaries' \
    && echo \
      $(which ccmake) \
      $(which cmake) \
      $(which ctest) \
      $(which cpack) \
      $(which docker) \
      $(which dockerd) \
      $(which ffmpeg) \
      $(which ffprobe) \
      $(which fftw-wisdom) \
      $(which fftwf-wisdom) \
      $(which git-lfs) \
      $(which hugo) \
      $(which node) \
      $(which python2.7) \
      $(which python3.4) \
      $(which streaming_extractor_music) \
      /usr/lib/gcc/x86_64-linux-gnu/4.8/cc1 \
      /usr/lib/gcc/x86_64-linux-gnu/4.8/cc1plus \
      | xargs -n 1 -P $(nproc) upx --lzma \
  ) \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /tmp/* \
  && rm -rf /var/tmp/*

RUN ( \
    mkdir -p ~/.ssh \
    && ssh-keyscan -H bitbucket.org >> ~/.ssh/known_hosts \
    && git config --global user.email "you@example.com" \
    && git config --global user.name "Your Name" \
  ) \
  && echo 'install: --no-ri --no-rdoc' >> /root/.gemrc \
  && echo 'update: --no-ri --no-rdoc' >> /root/.gemrc \
  && gem install bundler \
  && ( \
    echo 'local all postgres trust' > /etc/postgresql/9.3/main/pg_hba.conf \
    && echo "fix postgresql and docker bug by https://gitter.im/bgruening/docker-galaxy-stable/archives/2017/03/09" \
    && cp /etc/ssl/private/ssl-cert-snakeoil.key /etc/ \
    && chown root:ssl-cert /etc/ssl-cert-snakeoil.key \
    && sed -i -e 's@/ssl/private@@g' /etc/postgresql/9.3/main/postgresql.conf \
  ) \
  && sed -i -e 's/SHOWWARNING=true//g' /etc/tmpreaper.conf \
  && sed -i -e 's@^#cron@cron@g' /etc/rsyslog.d/50-default.conf \
  && rm -rf /tmp/* \
  && rm -rf /var/tmp/*
