FROM                    phusion/baseimage
MAINTAINER              Ana Nelson <ana@ananelson.com>

### "localedef"
RUN localedef -v -c -i en_US -f UTF-8 en_US.UTF-8 || :

### "squid-deb-proxy"
# Use squid deb proxy (if available on host OS) as per https://gist.github.com/dergachev/8441335
# Modified by @ananelson to detect squid on host OS and only enable itself if found.
ENV HOST_IP_FILE /tmp/host-ip.txt
RUN /sbin/ip route | awk '/default/ { print "http://"$3":8000" }' > $HOST_IP_FILE
RUN HOST_IP=`cat $HOST_IP_FILE` && curl -s $HOST_IP | grep squid && echo "found squid" && echo "Acquire::http::Proxy \"$HOST_IP\";" > /etc/apt/apt.conf.d/30proxy || echo "no squid"

### "apt-defaults"
RUN echo "APT::Get::Assume-Yes true;" >> /etc/apt/apt.conf.d/80custom
RUN echo "APT::Get::Quiet true;" >> /etc/apt/apt.conf.d/80custom

### "oracle-java-ppa"
RUN add-apt-repository ppa:webupd8team/java

### "update"
RUN apt-get update

### "utils"
RUN apt-get install build-essential
RUN apt-get install adduser
RUN apt-get install curl
RUN apt-get install sudo

### "nice-things"
RUN apt-get install ack-grep
RUN apt-get install strace
RUN apt-get install vim
RUN apt-get install git
RUN apt-get install tree
RUN apt-get install wget
RUN apt-get install unzip
RUN apt-get install rsync

### "texlive"
RUN apt-get install --no-install-recommends texlive-latex-base
RUN apt-get install --no-install-recommends texlive-latex-extra

### "python"
RUN apt-get install python-dev
RUN apt-get install python-pip

### "dexy"
RUN pip install dexy

### "r"
RUN apt-get install --no-install-recommends r-base

### "r-packages"
ENV CRAN_MIRROR http://cran.case.edu/
RUN R -e "install.packages(\"stargazer\", repos=\"$CRAN_MIRROR\")"
RUN R -e "install.packages(\"rjson\", repos=\"$CRAN_MIRROR\")"

### "install-phantomjs"
ENV PHANTOM_VERSION phantomjs-1.9.7-linux-x86_64
WORKDIR /tmp
RUN wget --no-verbose https://bitbucket.org/ariya/phantomjs/downloads/$PHANTOM_VERSION.tar.bz2
RUN tar -xjvf $PHANTOM_VERSION.tar.bz2
RUN mv $PHANTOM_VERSION/bin/phantomjs /usr/local/bin/

### "fake-fuse-for-openjdk"
RUN apt-get install fuse || :
RUN rm -rf /var/lib/dpkg/info/fuse.postinst
RUN apt-get install fuse

### "install-jdk"
RUN apt-get install openjdk-7-jdk

### "oracle-java"
RUN echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
RUN echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections
RUN apt-get install oracle-java7-installer

### "create-user"
RUN useradd -m -p $(perl -e'print crypt("foobarbaz", "aa")') repro
RUN adduser repro sudo

### "activate-user"
ENV HOME /home/repro
USER repro
WORKDIR /home/repro
