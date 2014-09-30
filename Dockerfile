# Docker version 1.2.0, build fa7b24f

FROM ubuntu:14.04
RUN (sudo apt-get update && sudo apt-get upgrade -y -q && sudo apt-get dist-upgrade -y -q && sudo apt-get -y -q autoclean && sudo apt-get -y -q autoremove)
RUN sudo apt-get -y install git
RUN git clone git@github.com:BDLSS/buildout.loris.git
RUN apt-get -y install $(cat ubuntu_requirements_ubuntu14)
RUN mkdir ~/Downloads
RUN wget http://www.python.org/ftp/python/2.7.6/Python-2.7.6.tgz --no-check-certificate
RUN tar zxfv Python-2.7.6.tgz
RUN cd Python-2.7.6
RUN ./configure --prefix=$HOME/python/2.7.6 --enable-unicode=ucs4 --enable-shared LDFLAGS="-Wl,-rpath=/home/root/python/2.7.6/lib"
RUN make
RUN make install
RUN cd ..
RUN wget http://python-distribute.org/distribute_setup.py
RUN ~/python/2.7.6/bin/python distribute_setup.py
RUN ~/python/2.7.6/bin/easy_install pip
RUN ~/python/2.7.6/bin/pip install virtualenv

RUN (mkdir ~/testbuild && cd ~/testbuild)
RUN ~/python/2.7.6/bin/virtualenv .
RUN source bin/activate
RUN pip install zc.buildout
RUN pip install distribute
RUN buildout init
RUN buildout -c development.cfg
RUN py.test tests/
#EXPOSE 8080
#CMD["loris", "/"]
