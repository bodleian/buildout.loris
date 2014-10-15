# Docker version 1.2.0, build fa7b24f
 
# -------------------------------------------------------------------------
# --------------------------- STIPULATE OS --------------------------------
# -------------------------------------------------------------------------

FROM ubuntu:14.04

# -------------------------------------------------------------------------
# --------------------------- UPDATE OS -----------------------------------
# -------------------------------------------------------------------------

RUN (sudo apt-get update && sudo apt-get upgrade -y -q && sudo apt-get dist-upgrade -y -q && sudo apt-get -y -q autoclean && sudo apt-get -y -q autoremove)

# -------------------------------------------------------------------------
# --------------------------- CREATE APP DIR ------------------------------
# -------------------------------------------------------------------------

RUN mkdir -p /root/sites/testbuild

# -------------------------------------------------------------------------
# --------------------------- COPY SOURCE INTO CONTAINER ------------------
# -------------------------------------------------------------------------

COPY / /root/sites/testbuild/

# -------------------------------------------------------------------------
# --------------------------- INSTALL REQS --------------------------------
# -------------------------------------------------------------------------

RUN apt-get -y install $(cat /root/sites/testbuild/ubuntu_requirements_ubuntu14)
RUN mkdir -p /root/Downloads

# -------------------------------------------------------------------------
# --------------------------- GET KAKADU ----------------------------------
# -------------------------------------------------------------------------

# change Kakadu_v<number>.zip for different versions: 64, 72, 74, etc.

RUN (cd /root/Downloads && curl --user admn2410:PaulB0wl3s -o Kakadu_v74.zip https://databank.ora.ox.ac.uk/dmt/datasets/Kakadu/Kakadu_v74.zip && unzip -d kakadu Kakadu_v74.zip)

# -------------------------------------------------------------------------
# --------------------------- INSTALL PYTHON ------------------------------
# -------------------------------------------------------------------------

RUN (cd /root/Downloads && wget http://www.python.org/ftp/python/2.7.6/Python-2.7.6.tgz --no-check-certificate && tar zxfv Python-2.7.6.tgz && cd /root/Downloads/Python-2.7.6)
RUN /root/Downloads/Python-2.7.6/configure --prefix=/root/python/2.7.6 --enable-unicode=ucs4 --enable-shared LDFLAGS="-Wl,-rpath=/root/python/2.7.6/lib"
RUN make
RUN make install

# -------------------------------------------------------------------------
# --------------------------- BUILDOUT SETUP ------------------------------
# -------------------------------------------------------------------------

RUN (cd /root/Downloads && wget https://pypi.python.org/packages/source/d/distribute/distribute-0.6.49.tar.gz && tar zxfv distribute-0.6.49.tar.gz) 
RUN /root/python/2.7.6/bin/python /root/Downloads/distribute-0.6.49/distribute_setup.py
RUN /root/python/2.7.6/bin/easy_install pip
RUN /root/python/2.7.6/bin/pip install virtualenv

# -------------------------------------------------------------------------
# --------------------------- RUN BUILDOUT AND INSTALL EGGS ---------------
# -------------------------------------------------------------------------

RUN (cd /root/sites/testbuild && /root/python/2.7.6/bin/virtualenv . && . bin/activate && pip install zc.buildout && pip install distribute && buildout init && buildout -c development_docker.cfg && pip install pillow==2.5.0 && pip install werkzeug==0.9.6 && pip install configobj==5.0.5 && pip install pytest==2.6.2)

# -------------------------------------------------------------------------
# --------------------------- INSTALL LORIS -------------------------------
# -------------------------------------------------------------------------

RUN (cd /root/sites/testbuild/ && . bin/activate && cd /root/sites/testbuild/src/loris && python setup.py install)

# -------------------------------------------------------------------------
# --------------------------- SHORTLINKS ----------------------------------
# -------------------------------------------------------------------------

RUN (ln -s /usr/include/freetype2 freetype && ln -s /usr/lib/`uname -i`-linux-gnu/libfreetype.so /usr/lib/ && ln -s /usr/lib/`uname -i`-linux-gnu/libjpeg.so /usr/lib/ && ln -s /usr/lib/`uname -i`-linux-gnu/libz.so /usr/lib/ && ln -s /usr/lib/`uname -i`-linux-gnu/liblcms.so /usr/lib/ && ln -s /usr/lib/`uname -i`-linux-gnu/libtiff.so /usr/lib/)

# -------------------------------------------------------------------------
# --------------------------- GET TEST IMAGE ------------------------------
# -------------------------------------------------------------------------

RUN (cd /root/sites/testbuild/var/images && curl --user admn2410:PaulB0wl3s -o 67352ccc-d1b0-11e1-89ae-279075081939.jp2 http://databank.ora.ox.ac.uk/dmt/datasets/Images/67352ccc-d1b0-11e1-89ae-279075081939.jp2)

# -------------------------------------------------------------------------
# --------------------------- RUN TEST FRAMEWORK --------------------------
# -------------------------------------------------------------------------

RUN (cd /root/sites/testbuild/ && . bin/activate && py.test /root/sites/testbuild/tests/)
#EXPOSE 8080
#CMD["loris", "/"]

