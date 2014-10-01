# Docker version 1.2.0, build fa7b24f

FROM ubuntu:14.04
RUN (sudo apt-get update && sudo apt-get upgrade -y -q && sudo apt-get dist-upgrade -y -q && sudo apt-get -y -q autoclean && sudo apt-get -y -q autoremove)
# Install git
#RUN apt-get install -y git
# Make ssh dir
#RUN mkdir /root/.ssh/
# Copy over private key, and set permissions
#ADD ssh-keygen -t /root/.ssh/id_rsa
# required, apparently..
#RUN echo " IdentityFile ~/.ssh/id_rsa" >> /etc/ssh/ssh_config
# Create known_hosts
#RUN touch /root/.ssh/known_hosts
# Add github.com key
#RUN ssh-keyscan github.com >> /root/.ssh/known_hosts
#RUN git clone git@github.com:BDLSS/buildout.loris.git
RUN (pwd && ls -lah)