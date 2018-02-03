FROM buildpack-deps:trusty

SHELL ["/bin/bash", "-c"]

RUN apt-get update \
  && curl -sL https://deb.nodesource.com/setup_8.x | bash \
  && apt-get install -y \
    software-properties-common \
  && add-apt-repository -y ppa:mc3man/trusty-media \
  && add-apt-repository -y ppa:brightbox/ruby-ng \
  && apt-get update \
  && apt-get install -y \
    cmake \
    ffmpeg \
    git \
    libogg-dev \
    libvorbis-dev \
    libflac-dev \
    libboost-all-dev \
    libsndfile1-dev \
    libgflags-dev \
    nodejs \
    postgresql \
    redis-server \
    ruby2.4 \
    ruby2.4-dev \
    tmpreaper \
    valgrind \
    vim \
    wget \
  && rm -rf /var/lib/apt/lists/* \
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
    cd /tmp \
    && wget ftp://ftp.fftw.org/pub/fftw/fftw-3.3.4.tar.gz \
    && tar xfvz fftw-3.3.4.tar.gz \
    && cd fftw-3.3.4 \
    && echo "configure options: http://www.fftw.org/fftw3_doc/Installation-on-Unix.html" \
    && echo "compiler support needed but cpu support is not needed" \
    && ./configure --enable-float --enable-sse --enable-sse2 --enable-avx --enable-avx2 --enable-avx-128-fma \
    && make -j `nproc` \
    && make install \
  ) \
  && ( \
    cd /tmp \
    && wget https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-180.0.0-linux-x86_64.tar.gz \
    && tar xfvz google-cloud-sdk-180.0.0-linux-x86_64.tar.gz \
    && mv google-cloud-sdk /root/google-cloud-sdk \
    && /root/google-cloud-sdk/install.sh --quiet \
    && echo source google-cloud-sdk/path.bash.inc >> /root/.bashrc \
  ) \
  && rm -rf /tmp/*

RUN ( \
    mkdir -p ~/.ssh \
    && ssh-keyscan -H bitbucket.org >> ~/.ssh/known_hosts \
    && git config --global user.email "you@example.com" \
    && git config --global user.name "Your Name" \
  ) \
  && gem install bundler \
  && ( \
    echo 'local all postgres trust' > /etc/postgresql/9.3/main/pg_hba.conf \
    && echo "fix postgresql and docker bug by https://gitter.im/bgruening/docker-galaxy-stable/archives/2017/03/09" \
    && cp /etc/ssl/private/ssl-cert-snakeoil.key /etc/ \
    && chown root:ssl-cert /etc/ssl-cert-snakeoil.key \
    && sed -i -e "s/\/ssl\/private//g" /etc/postgresql/9.3/main/postgresql.conf \
  ) \
  && sed -i -e 's/SHOWWARNING=true//g' /etc/tmpreaper.conf \
  && rm -rf /tmp/*
