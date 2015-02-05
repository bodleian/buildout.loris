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

RUN (adduser --disabled-password --gecos '' bodl-loris-svc && adduser bodl-loris-svc sudo && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && su - bodl-loris-svc && mkdir -p sites/bodl-loris-svc)

# -------------------------------------------------------------------------
# --------------------------- COPY SOURCE INTO CONTAINER ------------------
# -------------------------------------------------------------------------

COPY / /home/bodl-loris-svc/sites/bodl-loris-svc/

# -------------------------------------------------------------------------
# ---------------- IN UBUNTU 14 PILLOW REQS OPENJPEG 2.0  -----------------
# -------------------------------------------------------------------------

# http://shortrecipes.blogspot.co.uk/2014/06/python-34-and-pillow-24-with-jpeg2000.html
# http://stackoverflow.com/questions/1099981/why-cant-python-find-shared-objects-that-are-in-directories-in-sys-path

RUN (sudo apt-get install -y -q wget cmake make)
RUN (mkdir -p /home/bodl-loris-svc/Downloads && cd /home/bodl-loris-svc/Downloads && wget http://downloads.sourceforge.net/project/openjpeg.mirror/2.0.1/openjpeg-2.0.1.tar.gz && tar xzvf openjpeg-2.0.1.tar.gz && cd openjpeg-2.0.1/ && cmake . && make && sudo make install && export LD_LIBRARY_PATH=/usr/local/lib)

# -------------------------------------------------------------------------
# --------------------------- INSTALL REQS --------------------------------
# -------------------------------------------------------------------------

RUN apt-get -y install $(cat /home/bodl-loris-svc/sites/bodl-loris-svc/ubuntu_requirements)

# -------------------------------------------------------------------------
# --------------------------- GET KAKADU ----------------------------------
# -------------------------------------------------------------------------

# change Kakadu_v<number>.zip for different versions: 64, 72, 74, etc.

RUN (cd /home/bodl-loris-svc/Downloads && curl --user admn2410 -o Kakadu_v74.zip https://databank.ora.ox.ac.uk/dmt/datasets/Kakadu/Kakadu_v74.zip && unzip -d kakadu Kakadu_v74.zip)

# -------------------------------------------------------------------------
# --------------------------- INSTALL PYTHON ------------------------------
# -------------------------------------------------------------------------

RUN (cd /home/bodl-loris-svc/Downloads && wget http://www.python.org/ftp/python/2.7.6/Python-2.7.6.tgz --no-check-certificate && tar zxfv Python-2.7.6.tgz && cd /home/bodl-loris-svc/Downloads/Python-2.7.6)
RUN /home/bodl-loris-svc/Downloads/Python-2.7.6/configure --prefix=/home/bodl-loris-svc/python/2.7.6 --enable-unicode=ucs4 --enable-shared LDFLAGS="-Wl,-rpath=/home/bodl-loris-svc/python/2.7.6/lib"
RUN make
RUN make install

# -------------------------------------------------------------------------
# --------------------------- BUILDOUT SETUP ------------------------------
# -------------------------------------------------------------------------

RUN (cd /home/bodl-loris-svc/Downloads && wget --no-check-certificate https://pypi.python.org/packages/source/d/distribute/distribute-0.6.49.tar.gz && tar zxfv distribute-0.6.49.tar.gz) 
RUN /home/bodl-loris-svc/python/2.7.6/bin/python /home/bodl-loris-svc/Downloads/distribute-0.6.49/distribute_setup.py
RUN /home/bodl-loris-svc/python/2.7.6/bin/easy_install pip
RUN /home/bodl-loris-svc/python/2.7.6/bin/pip install virtualenv

# -------------------------------------------------------------------------
# --------------------------- BUILDOUT CACHE ------------------------------
# -------------------------------------------------------------------------

RUN (mkdir /home/bodl-loris-svc/.buildout && cd /home/bodl-loris-svc/.buildout && mkdir eggs && mkdir downloads && mkdir extends && (echo "[buildout]" && echo "eggs-directory = /home/bodl-loris-svc/.buildout/eggs" && echo "download-cache = /home/bodl-loris-svc/.buildout/downloads" && echo "extends-cache = /home/bodl-loris-svc/.buildout/extends") >> /home/bodl-loris-svc/.buildout/default.cfg)

# -------------------------------------------------------------------------
# --------------------------- RUN BUILDOUT AND INSTALL EGGS ---------------
# -------------------------------------------------------------------------

RUN (cd /home/bodl-loris-svc/sites/bodl-loris-svc && /home/bodl-loris-svc/python/2.7.6/bin/virtualenv . && . bin/activate && pip install zc.buildout && pip install distribute && buildout init && buildout -c development_docker.cfg)

# -------------------------------------------------------------------------
# --------------------------- INSTALL LORIS -------------------------------
# -------------------------------------------------------------------------

RUN (cd /home/bodl-loris-svc/sites/bodl-loris-svc/ && . bin/activate && cd /home/bodl-loris-svc/sites/bodl-loris-svc/src/loris && python setup.py install)

# -------------------------------------------------------------------------
# --------------------------- SHORTLINKS ----------------------------------
# -------------------------------------------------------------------------

RUN (ln -s /usr/include/freetype2 freetype && ln -s /usr/lib/`uname -i`-linux-gnu/libfreetype.so /usr/lib/ && ln -s /usr/lib/`uname -i`-linux-gnu/libjpeg.so /usr/lib/ && ln -s /usr/lib/`uname -i`-linux-gnu/libz.so /usr/lib/ && ln -s /usr/lib/`uname -i`-linux-gnu/liblcms.so /usr/lib/ && ln -s /usr/lib/`uname -i`-linux-gnu/libtiff.so /usr/lib/ && ln -s /usr/lib/`uname -i`-linux-gnu/libopenjp2.so /usr/lib/)

# -------------------------------------------------------------------------
# --------------------------- GET TEST IMAGE ------------------------------
# -------------------------------------------------------------------------

RUN (cd /home/bodl-loris-svc/sites/bodl-loris-svc/var/images && wget http://iiif-test.stanford.edu/67352ccc-d1b0-11e1-89ae-279075081939.jp2 && chmod 777 67352ccc-d1b0-11e1-89ae-279075081939.jp2)

# -------------------------------------------------------------------------
# --------------------- INSTALL & RUN TEST FRAMEWORK ----------------------
# -------------------------------------------------------------------------

RUN (cd /home/bodl-loris-svc/sites/bodl-loris-svc/ && . bin/activate && pip install pytest && py.test /home/bodl-loris-svc/sites/bodl-loris-svc/tests/)

# -------------------------------------------------------------------------
# --------------------------- INSTALL VALIDATOR ---------------------------
# -------------------------------------------------------------------------

RUN (cd /home/bodl-loris-svc/sites/bodl-loris-svc/parts && wget --no-check-certificate https://pypi.python.org/packages/source/i/iiif-validator/iiif-validator-0.9.1.tar.gz && tar zxfv iiif-validator-0.9.1.tar.gz)
RUN (sudo apt-get -y install libmagic-dev libxml2-dev libxslt-dev && cd /home/bodl-loris-svc/sites/bodl-loris-svc && . bin/activate && pip install bottle && pip install python-magic && pip install lxml && pip install Pillow)

# -------------------------------------------------------------------------
# -------------------  START SERVER, RUN VALIDATOR   ----------------------
# -------------------------------------------------------------------------

#validator needs to run in same intermediate container as the apache start

RUN chown -R bodl-loris-svc:bodl-loris-svc /home/bodl-loris-svc
WORKDIR /home/bodl-loris-svc/sites/bodl-loris-svc
EXPOSE 8080
RUN (cd /home/bodl-loris-svc/sites/bodl-loris-svc/bin/ && chmod +x lorisctl && sleep 2 && ./lorisctl start && cd /home/bodl-loris-svc/sites/bodl-loris-svc/ && . bin/activate && cd /home/bodl-loris-svc/sites/bodl-loris-svc/parts/iiif-validator-0.9.1/ && ./iiif-validate.py -s 127.0.0.1:8080 -p 'loris' -i 67352ccc-d1b0-11e1-89ae-279075081939.jp2 --version=2.0 -v)
