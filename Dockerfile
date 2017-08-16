FROM buildpack-deps:trusty

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
		postgresql \
		postgresql-contrib \
		redis-server \
		vim \
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
		mkdir -p ~/.ssh \
		&& ssh-keyscan -H bitbucket.org >> ~/.ssh/known_hosts \
		&& git config --global user.email "you@example.com" \
		&& git config --global user.name "Your Name" \
	) \
	&& gem install bundler \
	&& ( \
		echo 'local all postgres trust' > /etc/postgresql/9.5/main/pg_hba.conf \
	) \
	&& rm -rf /tmp/*
