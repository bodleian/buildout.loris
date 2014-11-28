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
# ------------------------- CREATE APP USER/DIR ---------------------------
# -------------------------------------------------------------------------

RUN (adduser --disabled-password --gecos '' bodl-loris-srv && adduser bodl-loris-srv sudo && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && su - bodl-loris-srv && mkdir -p sites/bodl-loris-srv)

# -------------------------------------------------------------------------
# --------------------------- COPY SOURCE INTO CONTAINER ------------------
# -------------------------------------------------------------------------

COPY / /home/bodl-loris-srv/sites/bodl-loris-srv/

# -------------------------------------------------------------------------
# --------------------------- INSTALL REQS --------------------------------
# -------------------------------------------------------------------------

RUN apt-get -y install $(cat /home/bodl-loris-srv/sites/bodl-loris-srv/ubuntu_requirements_ubuntu14)
RUN mkdir -p /home/bodl-loris-srv/Downloads

# -------------------------------------------------------------------------
# --------------------------- GET KAKADU ----------------------------------
# -------------------------------------------------------------------------

# change Kakadu_v<number>.zip for different versions: 64, 72, 74, etc.

RUN (cd /home/bodl-loris-srv/Downloads && curl --user admn2410:PaulB0wl3s -o Kakadu_v74.zip https://databank.ora.ox.ac.uk/dmt/datasets/Kakadu/Kakadu_v74.zip && unzip -d kakadu Kakadu_v74.zip)

# -------------------------------------------------------------------------
# --------------------------- INSTALL PYTHON ------------------------------
# -------------------------------------------------------------------------

RUN (cd /home/bodl-loris-srv/Downloads && wget http://www.python.org/ftp/python/2.7.6/Python-2.7.6.tgz --no-check-certificate && tar zxfv Python-2.7.6.tgz && cd /home/bodl-loris-srv/Downloads/Python-2.7.6)
RUN /home/bodl-loris-srv/Downloads/Python-2.7.6/configure --prefix=/home/bodl-loris-srv/python/2.7.6 --enable-unicode=ucs4 --enable-shared LDFLAGS="-Wl,-rpath=/home/bodl-loris-srv/python/2.7.6/lib"
RUN make
RUN make install

# -------------------------------------------------------------------------
# --------------------------- BUILDOUT SETUP ------------------------------
# -------------------------------------------------------------------------

RUN (cd /home/bodl-loris-srv/Downloads && wget https://pypi.python.org/packages/source/d/distribute/distribute-0.6.49.tar.gz && tar zxfv distribute-0.6.49.tar.gz) 
RUN /home/bodl-loris-srv/python/2.7.6/bin/python /home/bodl-loris-srv/Downloads/distribute-0.6.49/distribute_setup.py
RUN /home/bodl-loris-srv/python/2.7.6/bin/easy_install pip
RUN /home/bodl-loris-srv/python/2.7.6/bin/pip install virtualenv

# -------------------------------------------------------------------------
# --------------------------- BUILDOUT CACHE ------------------------------
# -------------------------------------------------------------------------

RUN (mkdir /home/bodl-loris-srv/.buildout && cd /home/bodl-loris-srv/.buildout && mkdir eggs && mkdir downloads && mkdir extends && (echo "[buildout] eggs-directory = /home/bodl-loris-srv/.buildout/eggs" && echo "download-cache = /home/bodl-loris-srv/.buildout/downloads" && echo "extends-cache = /home/bodl-loris-srv/.buildout/extends" >> /home/bodl-loris-srv/.buildout/default.cfg))

# -------------------------------------------------------------------------
# --------------------------- RUN BUILDOUT AND INSTALL EGGS ---------------
# -------------------------------------------------------------------------

RUN (cd /home/bodl-loris-srv/sites/bodl-loris-srv && /home/bodl-loris-srv/python/2.7.6/bin/virtualenv . && . bin/activate && pip install zc.buildout && pip install distribute && buildout init && buildout -c development_docker.cfg && pip install pillow==2.5.0 && pip install werkzeug==0.9.6 && pip install configobj==5.0.5 && pip install pytest==2.6.2)

# -------------------------------------------------------------------------
# --------------------------- INSTALL LORIS -------------------------------
# -------------------------------------------------------------------------

RUN (cd /home/bodl-loris-srv/sites/bodl-loris-srv/ && . bin/activate && cd /home/bodl-loris-srv/sites/bodl-loris-srv/parts/loris && python setup.py install)

# -------------------------------------------------------------------------
# --------------------------- SHORTLINKS ----------------------------------
# -------------------------------------------------------------------------

RUN (ln -s /usr/include/freetype2 freetype && ln -s /usr/lib/`uname -i`-linux-gnu/libfreetype.so /usr/lib/ && ln -s /usr/lib/`uname -i`-linux-gnu/libjpeg.so /usr/lib/ && ln -s /usr/lib/`uname -i`-linux-gnu/libz.so /usr/lib/ && ln -s /usr/lib/`uname -i`-linux-gnu/liblcms.so /usr/lib/ && ln -s /usr/lib/`uname -i`-linux-gnu/libtiff.so /usr/lib/)

# -------------------------------------------------------------------------
# --------------------------- GET TEST IMAGE ------------------------------
# -------------------------------------------------------------------------

RUN (cd /home/bodl-loris-srv/sites/bodl-loris-srv/var/images && curl --user admn2410:PaulB0wl3s -o 67352ccc-d1b0-11e1-89ae-279075081939.jp2 http://databank.ora.ox.ac.uk/dmt/datasets/Images/67352ccc-d1b0-11e1-89ae-279075081939.jp2)

# -------------------------------------------------------------------------
# --------------------------- RUN TEST FRAMEWORK --------------------------
# -------------------------------------------------------------------------

RUN (cd /home/bodl-loris-srv/sites/bodl-loris-srv/ && . bin/activate && py.test /home/bodl-loris-srv/sites/bodl-loris-srv/tests/)

# -------------------------------------------------------------------------
# ---------------------------  INSTALL VALIDATOR --------------------------
# -------------------------------------------------------------------------

RUN (mkdir -p /home/bodl-loris-srv/sites/bodl-loris-srv/parts/validator && cd /home/bodl-loris-srv/sites/bodl-loris-srv/parts && wget --no-check-certificate https://pypi.python.org/packages/source/i/iiif-validator/iiif-validator-0.9.1.tar.gz && tar zxfv iiif-validator-0.9.1.tar.gz)
RUN (apt-get -y install libmagic-dev libxml2-dev libxslt-dev && cd /home/bodl-loris-srv/sites/bodl-loris-srv && . bin/activate && pip install bottle && pip install python-magic && pip install lxml && pip install Pillow)

# -------------------------------------------------------------------------
# -------------------  START SERVER, RUN VALIDATOR   ----------------------
# -------------------------------------------------------------------------

#validator needs to run in same intermediate container as the apache start

RUN chown -R bodl-loris-srv:bodl-loris-srv /home/bodl-loris-srv
WORKDIR /home/bodl-loris-srv/sites/bodl-loris-srv
EXPOSE 8080
RUN (chown -R www-data:www-data /home/bodl-loris-srv/sites/bodl-loris-srv/src && cd /home/bodl-loris-srv/sites/bodl-loris-srv/bin/ && chmod +x lorisctl && sleep 2 && ./lorisctl start && cd /home/bodl-loris-srv/sites/bodl-loris-srv/ && . bin/activate && cd /home/bodl-loris-srv/sites/bodl-loris-srv/parts/iiif-validator-0.9.1/ && ./iiif-validate.py -s 127.0.0.1:8080 -p '' -i /home/bodl-loris-srv/sites/bodl-loris-srv/var/images/67352ccc-d1b0-11e1-89ae-279075081939.jp2 --version=2.0 -v)
