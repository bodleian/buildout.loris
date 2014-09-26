# Docker version 1.2.0, build fa7b24f

FROM ubuntu:14.04
RUN (sudo apt-get update && sudo apt-get upgrade -y -q && sudo apt-get dist-upgrade -y -q && sudo apt-get -y -q autoclean && sudo apt-get -y -q autoremove)
RUN sudo apt-get install $(cat ubuntu_requirements_ubuntu14)
RUN sudo pip install zc.buildout
RUN buildout init
RUN bin/buildout -N -t 3 -c development.cfg
RUN py.test tests/
#EXPOSE 8080
#CMD["loris", "/"]
