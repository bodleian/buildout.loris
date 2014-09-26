# Docker version 1.2.0, build fa7b24f

FROM ubuntu:14.04
RUN (apt-get update && apt-get upgrade -y -q && apt-get dist-upgrade -y -q && apt-get -y -q autoclean && apt-get -y -q autoremove)
RUN apt-get install $(cat ubuntu_requirements_ubuntu14)
RUN pip install zc.buildout
RUN buildout init
RUN bin/buildout -N -t 3 -c development.cfg
RUN py.test tests/
#EXPOSE 8080
#CMD["loris", "/"]
