# Docker version 1.2.0, build fa7b24f

FROM ubuntu:14.04
RUN (sudo apt-get update && sudo apt-get upgrade -y -q && sudo apt-get dist-upgrade -y -q && sudo apt-get -y -q autoclean && sudo apt-get -y -q autoremove)
RUN mkdir /root/testbuild
ADD / /root/testbuild/
RUN ls -lah /root/testbuild/
RUN apt-get -y install $(cat /root/testbuild/ubuntu_requirements_ubuntu14)
RUN mkdir /root/Downloads
RUN (cd /root/Downloads && wget http://www.python.org/ftp/python/2.7.6/Python-2.7.6.tgz --no-check-certificate && tar zxfv Python-2.7.6.tgz && cd /root/Downloads/Python-2.7.6)
RUN /root/Downloads/Python-2.7.6/configure --prefix=/root/python/2.7.6 --enable-unicode=ucs4 --enable-shared LDFLAGS="-Wl,-rpath=/root/python/2.7.6/lib"
RUN make
RUN make install
RUN (cd /root/Downloads && wget https://pypi.python.org/packages/source/d/distribute/distribute-0.6.49.tar.gz && tar zxfv distribute-0.6.49.tar.gz && ls -lah /root/Downloads) 
RUN /root/python/2.7.6/bin/python /root/Downloads/distribute-0.6.49/distribute_setup.py
RUN /root/python/2.7.6/bin/easy_install pip
RUN /root/python/2.7.6/bin/pip install virtualenv
RUN /root/python/2.7.6/bin/virtualenv /root/testbuild/
#RUN (ls /root/testbuild/bin && source /root/testbuild/bin/activate)
RUN /root/testbuild/bin/pip install zc.buildout
RUN /root/testbuild/bin/pip install distribute
RUN /root/testbuild/bin/buildout init
ENV PATH /usr/bin
RUN (PATH=/usr/bin:$PATH && echo $PATH)
RUN /root/testbuild/bin/buildout -c /root/testbuild/development_docker.cfg
RUN py.test tests/
#EXPOSE 8080
#CMD["loris", "/"]

