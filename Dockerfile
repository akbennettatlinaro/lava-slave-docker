FROM linarotechnologies/minideb:stretch-arm64

# Add services helper utilities to start and stop LAVA
COPY stop.sh .
COPY start.sh .

RUN \
 echo 'lava-server   lava-server/instance-name string lava-slave-instance' | debconf-set-selections && \
 echo 'locales locales/locales_to_be_generated multiselect C.UTF-8 UTF-8, en_US.UTF-8 UTF-8 ' | debconf-set-selections && \
 echo 'locales locales/default_environment_locale select en_US.UTF-8' | debconf-set-selections && \
 DEBIAN_FRONTEND=noninteractive install_packages \
 locales \
 lava-dispatcher \
 lava-dev \
 git \
 vim \
 sudo \
 expect \
 qemu-system \
 qemu-system-arm \
 qemu-system-i386 \
 tftpd-hpa \
 ser2net \
 dfu-util \
 libusb-1.0-0-dev \
 libudev-dev \
 python-dev \
 python-pip

RUN \
 pip install setuptools wheel --upgrade && \
 pip install --pre -U pyocd

RUN \
 git clone -b master https://git.linaro.org/lava/lava-dispatcher.git /root/lava-dispatcher && \
 cd /root/lava-dispatcher && \
 git checkout 2017.4 && \
 git config --global user.name "Docker Build" && \
 git config --global user.email "info@kernelci.org" && \
 curl https://github.com/EmbeddedAndroid/lava-dispatcher/commit/f34cacee50a8e702aa05644286e618316c1f3658.patch | git am && \
 curl https://github.com/EmbeddedAndroid/lava-dispatcher/commit/ac1bb2ab83ba243cc9b9d3dc890e38226d63872a.patch | git am && \
 curl https://github.com/EmbeddedAndroid/lava-dispatcher/commit/e3e4d946afed9d248966031c6a01a13bbffd4ccf.patch | git am && \
 echo "cd \${DIR} && dpkg -i *.deb" >> /usr/share/lava-server/debian-dev-build.sh && \
 sleep 2 && \
 /usr/share/lava-server/debian-dev-build.sh -p lava-dispatcher

RUN \
 cd /root && \
 git clone https://github.com/Yepkit/pykush && \
 cd pykush/ && \
 python setup.py install

COPY configs/lava-slave /etc/lava-dispatcher/lava-slave

COPY configs/tftpd-hpa /etc/default/tftpd-hpa

COPY configs/ser2net.conf /etc/ser2net.conf

COPY scripts/ /root/scripts

RUN chmod a+x /root/scripts/*

EXPOSE 69/udp

CMD /start.sh && bash
