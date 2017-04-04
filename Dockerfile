FROM debian:jessie-backports

# Add services helper utilities to start and stop LAVA
COPY stop.sh .
COPY start.sh .

RUN \
 echo 'lava-server   lava-server/instance-name string lava-slave-instance' | debconf-set-selections && \
 echo 'locales locales/locales_to_be_generated multiselect C.UTF-8 UTF-8, en_US.UTF-8 UTF-8 ' | debconf-set-selections && \
 echo 'locales locales/default_environment_locale select en_US.UTF-8' | debconf-set-selections && \
 apt-get update && \
 DEBIAN_FRONTEND=noninteractive apt-get install -y -t jessie-backports \
 locales \
 lava-dispatcher \
 lava-dev \
 git \
 vim \
 sudo \
 qemu-system \
 qemu-system-arm \
 qemu-system-i386 \
 qemu-kvm && \ 
 rm -rf /var/lib/apt/lists/*

RUN \
 git clone -b master https://git.linaro.org/lava/lava-dispatcher.git /root/lava-dispatcher && \
 cd /root/lava-dispatcher && \
 git checkout 2017.2 && \
 curl https://git.linaro.org/lava/lava-dispatcher.git/patch/?id=94876fd789952dc9da6af3adcf24c3d5ccf76991 > pyocd.patch && \
 git am pyocd.patch && \
 echo "cd \${DIR} && dpkg -i *.deb" >> /usr/share/lava-server/debian-dev-build.sh && \
 sleep 2 && \
 /usr/share/lava-server/debian-dev-build.sh -p lava-dispatcher

COPY lava-slave /etc/lava-dispatcher/lava-slave

CMD /start.sh && bash
