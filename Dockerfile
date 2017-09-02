FROM buildpack-deps:trusty

SHELL ["/bin/bash", "-c"]

RUN apt-get update \
	&& curl -sL https://deb.nodesource.com/setup_8.x | bash \
	&& apt-get install -y \
		apt-transport-https \
		ca-certificates \
		curl \
		software-properties-common \
	&& curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - \
	&& add-apt-repository \
		"deb [arch=amd64] https://download.docker.com/linux/ubuntu \
		$(lsb_release -cs) \
		stable" \
	&& add-apt-repository -y ppa:mc3man/trusty-media \
	&& add-apt-repository -y ppa:brightbox/ruby-ng \
	&& apt-get update \
	&& apt-get install -y \
		cmake \
		docker-ce \
		ffmpeg \
		git \
		libogg-dev \
		libvorbis-dev \
		libflac-dev \
		libboost-all-dev \
		libsndfile1-dev \
		libgflags-dev \
		linux-image-extra-$(uname -r) \
		linux-image-extra-virtual \
		nodejs \
		postgresql \
		redis-server \
		ruby2.4 \
		ruby2.4-dev \
		vim \
		wget \
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
	&& rm -rf /tmp/*
