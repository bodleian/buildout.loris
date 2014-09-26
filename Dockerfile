# Docker version 1.2.0, build fa7b24f

FROM ubuntu:14.04
RUN (sudo apt-get update && sudo apt-get upgrade -y -q && sudo apt-get dist-upgrade -y -q && sudo apt-get -y -q autoclean && sudo apt-get -y -q autoremove)
RUN apt-get install $(cat ubuntu_requirements_ubuntu14)

# install pip - canonical installation instructions from pip-installer.org
# http://www.pip-installer.org/en/latest/installing.html
ADD https://bitbucket.org/pypa/setuptools/raw/bootstrap/ez_setup.py /tmp/ez_setup.py
ADD https://raw.github.com/pypa/pip/master/contrib/get-pip.py /tmp/get-pip.py
RUN python /tmp/ez_setup.py
RUN python /tmp/get-pip.py
RUN pip install --upgrade pip 

RUN pip install zc.buildout
RUN buildout init
RUN bin/buildout -N -t 3 -c development.cfg
RUN py.test tests/
#EXPOSE 8080
#CMD["loris", "/"]
