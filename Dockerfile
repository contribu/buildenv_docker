FROM buildpack-deps:trusty

SHELL ["/bin/bash", "-c"]

RUN apt-get update \
	&& apt-get -y install software-properties-common \
	&& add-apt-repository -y ppa:mc3man/trusty-media \
	&& add-apt-repository -y ppa:brightbox/ruby-ng \
	&& apt-get update \
	&& apt-get install -y \
		libogg-dev \
		libvorbis-dev \
		libflac-dev \
		libboost-all-dev \
		libsndfile1-dev \
		libgflags-dev \
		cmake \
		git \
		wget \
		ffmpeg \
		ruby2.4 \
		ruby2.4-dev \
		postgresql \
		redis-server \
		vim \
	&& rm -rf /var/lib/apt/lists/* \
	&& ( \
		cd /tmp \
		&& wget ftp://ftp.fftw.org/pub/fftw/fftw-3.3.4.tar.gz \
		&& tar xfvz fftw-3.3.4.tar.gz \
		&& cd fftw-3.3.4 \
		&& ./configure --enable-float --enable-sse --enable-sse2 --enable-avx \
		&& make -j `nproc` \
		&& make install \
	) \
	&& ( \
		curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | bash \
		&& export NVM_DIR="$HOME/.nvm" \
		&& [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" \
		&& [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" \
		&& nvm install v8.2.1 \
	) \
	&& rm -rf /tmp/*

RUN ( \
		mkdir -p ~/.ssh \
		&& ssh-keyscan -H bitbucket.org >> ~/.ssh/known_hosts \
		&& git config --global user.email "you@example.com" \
		&& git config --global user.name "Your Name" \
	) \
	&& gem install bundler \
	&& echo 'local all postgres trust' > /etc/postgresql/9.3/main/pg_hba.conf \
	&& rm -rf /tmp/*
