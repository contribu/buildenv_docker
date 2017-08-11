FROM buildpack-deps:xenial

RUN apt-get update \
	&& apt-get install -y \
		libflac-dev \
		libboost-all-dev \
		libsndfile1-dev \
		cmake \
		git \
		wget \
	&& ( \
		cd /tmp \
		&& wget ftp://ftp.fftw.org/pub/fftw/fftw-3.3.4.tar.gz \
		&& tar xfvz fftw-3.3.4.tar.gz \
		&& cd fftw-3.3.4 \
		&& ./configure --enable-float --enable-sse --enable-sse2 --enable-avx \
		&& make -j `nproc` \
		&& make install \
	) \
	&& mkdir -p ~/.ssh \
	&& ssh-keyscan -H bitbucket.org >> ~/.ssh/known_hosts \
	&& rm -rf /tmp/*
