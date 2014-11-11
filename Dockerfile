FROM                    ubuntu:latest
MAINTAINER              Ana Nelson <ana@ananelson.com>

### "localedef"
RUN locale-gen en_US.UTF-8

### "apt-defaults"
RUN echo "APT::Get::Assume-Yes true;" >> /etc/apt/apt.conf.d/80custom ; \
    echo "APT::Get::Quiet true;" >> /etc/apt/apt.conf.d/80custom ; \
    apt-get update ; \
    apt-get install curl

### "squid-deb-proxy"
# Use squid deb proxy only if found on host OS. From https://gist.github.com/dergachev/8441335
# Need curl installed before 
RUN HOST_IP_FILE="/tmp/host-ip.txt" ; \
    /sbin/ip route | awk '/default/ { print "http://"$3":8000" }' > $HOST_IP_FILE ; \
    HOST_IP=`cat $HOST_IP_FILE` && curl -s $HOST_IP | grep squid && echo "found squid" && \
    echo "Acquire::http::Proxy \"$HOST_IP\";" > /etc/apt/apt.conf.d/30proxy || echo "no squid"

### "utils"
RUN apt-get install \
      build-essential \
      adduser \
      sudo

### "nice-things"
RUN apt-get install \
      ack-grep \
      git \
      man-db \
      rsync \
      strace \
      tree \
      unzip \
      vim \
      wget

### "r"
RUN apt-get install --no-install-recommends \
      r-base

### "r-packages"
RUN CRAN_MIRROR="http://cran.stat.ucla.edu" ; \
    echo "local({r <- getOption(\"repos\"); r[\"CRAN\"] <- \"$CRAN_MIRROR\"; options(repos=r)})" >> /usr/lib/R/etc/Rprofile.site ; \
    R -e "install.packages(\"colorspace\")" ; \
    R -e "install.packages(\"bitops\")" ;

### "python"
RUN apt-get install \
      python \
      python-dev \
      python-pip

### "dist-dexy"
RUN pip install dexy

### "workdir-for-src-installs"
WORKDIR /tmp

### "source-dexy"
RUN git clone https://github.com/dexy/dexy && \
    cd dexy && \
    pip install -e .

### "source-phantomjs"
RUN PHANTOM_VERSION="phantomjs-1.9.7-linux-x86_64" ; \
    wget --no-verbose https://bitbucket.org/ariya/phantomjs/downloads/$PHANTOM_VERSION.tar.bz2 && \
    tar -xjf $PHANTOM_VERSION.tar.bz2 && \
    mv $PHANTOM_VERSION/bin/phantomjs /usr/local/bin/ && \
    phantomjs --version

### "source-casperjs"
RUN git clone git://github.com/n1k0/casperjs.git && \
    cd casperjs && \
    ln -sf `pwd`/bin/casperjs /usr/local/bin/casperjs && \
    casperjs --version

WORKDIR /tmp
### "source-zeromq"
RUN ZEROMQ_VERSION="zeromq-4.0.4" ; \
    wget --no-verbose http://download.zeromq.org/$ZEROMQ_VERSION.tar.gz && \
    tar -xzf $ZEROMQ_VERSION.tar.gz && \
    mv $ZEROMQ_VERSION zeromq && \
    cd zeromq && \
    ./configure && \
    make && \
    make install && \
    ldconfig && \
    pip install pyzmq

### "fake-fuse-for-openjdk"
RUN apt-get install fuse || :; \
    rm -rf /var/lib/dpkg/info/fuse.postinst && \
    apt-get install fuse

### "install-openjdk"
RUN apt-get install openjdk-7-jdk

### "oracle-java-ppa"
RUN apt-get install software-properties-common && \
    add-apt-repository ppa:webupd8team/java && \
    apt-get update

### "oracle-java"
RUN echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections ; \
    echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections ; \
    apt-get install oracle-java7-installer

### "asciidoctor"
RUN apt-get install \
      ruby1.9.1 \
      ruby1.9.1-dev ; \
    gem install \
      asciidoctor \
      pygments.rb

### "texlive"
RUN apt-get install --no-install-recommends \
      texlive-latex-base \
      texlive-latex-extra \
      texlive-latex-recommended

### "create-user"
RUN useradd -m repro && \
    echo "repro:password" | chpasswd ; \
    echo "repro ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/repro

### "activate-user"
ENV HOME /home/repro
USER repro
WORKDIR /home/repro
