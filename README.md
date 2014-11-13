Installation
============

Travis only offers Ubuntu 12.04 builds. This Loris build is intended for Ubuntu 14.0. However, it can be installed on 12.0 by following the instructions given in section "Setup server (Debian/Ubuntu)".

![alt tag](https://travis-ci.org/BDLSS/buildout.loris.svg?branch=master)

Create user "bodl-loris-svc"
------------------

```bash
sudo useradd bodl-loris-svc
sudo passwd bodl-loris-svc
sudo mkdir -p /home/bodl-loris-svc/.ssh
cd /home
sudo chown -R bodl-loris-svc:bodl-loris-svc bodl-loris-svc/
sudo chsh -s /bin/bash bodl-loris-svc
su - bodl-loris-svc
ssh-keygen -t rsa
```

Copy and paste your key into gitlab by choosing My Profile (the grey person graphic link in the top right hand corner) then Add Public Key.

```bash
cat ~/.ssh/id_rsa.pub
```

Install and configure Git (Ubuntu)
----------------------------------
```bash
su - <sudo user>
sudo apt-get install git
```
```bash
git config --global user.email "my@address.com"
git config --global user.name "name in quotes"
```
Install and configure Git (RHEL>=6)
-----------------------------------
```bash
su
yum install git
exit
```
```bash
git config --global user.email "my@address.com"
git config --global user.name "name in quotes"
```

Checkout the buildout
---------------------
```bash
su - bodl-loris-svc
mkdir -p ~/sites/bodl-loris-svc
cd ~/sites/bodl-loris-svc
git clone gitlab@source.bodleian.ox.ac.uk:loris/buildout.loris.git ./
```
Setup server (Debian/Ubuntu)
----------------------------

Append ``_ubuntu12`` or ``_ubuntu14`` to the ubuntu_requirements file accordingly.

```bash
su - <sudo user>
sudo apt-get install $(cat /home/bodl-loris-svc/sites/bodl-loris-svc/ubuntu_requirements[_ubuntu12 or _ubuntu14])
su - bodl-loris-svc
```

Ubuntu 12 is set as default in the ``.travis.yml`` as follows:

```bash
install:
- sudo apt-get install $(cat ubuntu_requirements_ubuntu12)
```

Setup server (RHEL>=6)
----------------------------

```bash
su - <sudo user>
sudo cp /home/bodl-loris-svc/sites/bodl-loris-svc/redhat_requirements ~
sudo yum install $(cat redhat_requirements)
exit
```

Install Python
--------------
```bash
su - bodl-loris-svc
mkdir -p ~/Downloads
cd ~/Downloads
wget http://www.python.org/ftp/python/2.7.6/Python-2.7.6.tgz --no-check-certificate
tar zxfv Python-2.7.6.tgz
cd Python-2.7.6
./configure --prefix=$HOME/python/2.7.6 --enable-unicode=ucs4 --enable-shared LDFLAGS="-Wl,-rpath=/home/bodl-loris-svc/python/2.7.6/lib"
make
make install
cd ..
wget https://pypi.python.org/packages/source/d/distribute/distribute-0.6.49.tar.gz
tar zxfv distribute-0.6.49.tar.gz
~/python/2.7.6/bin/python distribute-0.6.49/distribute_setup.py
~/python/2.7.6/bin/easy_install pip
~/python/2.7.6/bin/pip install virtualenv
```

Setup the buildout cache
------------------------
```bash
mkdir ~/.buildout
cd ~/.buildout
mkdir eggs
mkdir downloads
mkdir extends
echo "[buildout]
eggs-directory = /home/bodl-loris-svc/.buildout/eggs
download-cache = /home/bodl-loris-svc/.buildout/downloads
extends-cache = /home/bodl-loris-svc/.buildout/extends" >> ~/.buildout/default.cfg
```
Change the IP address for apache config
---------------------------------------

edit development or production.cfg:

```bash

[hosts]
internalIP = <your server internal IP address>
externalIP = <your server external IP address>
```

Upload Kakadu source to server for compilation
----------------------------------------------

With no top layer directory (this buildout is designed for Kakadu versions 6.4 to 7.4).

On your loris server:

```bash
mkdir ~/Downloads/kakadu
```

From wherever your source files reside:

```bash
scp -r <kakadu source location>/* bodl-loris-svc@<your loris server>:/home/bodl-loris-svc/Downloads/kakadu
```

Buildout will compile the source and distribute the libraries and applications required (namely the shared object library and kdu_expand).

Create a virtualenv and run the buildout
----------------------------------------
```bash
cd ~/sites/bodl-loris-svc
~/python/2.7.6/bin/virtualenv .
source bin/activate
pip install zc.buildout
pip install distribute
buildout init
buildout -c development.cfg
```

Install eggs (temporary)
------------------------

```bash
pip install pillow==2.5.0
pip install werkzeug==0.9.6
pip install configobj==5.0.5
pip install pytest==2.6.2
```

Install Loris
-------------

```bash

cd /home/bodl-loris-svc/sites/bodl-loris-svc/src/loris
python setup.py install
```

Installation complete message
-----------------------------

You should see the following information on your screen. 

```bash
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-
Installation was successful. Here's where things are:

 * Loris configuration: /home/bodl-loris-svc/sites/bodl-loris-svc/src/loris/etc/loris
 * Cache cleaner cron: /home/bodl-loris-svc/sites/bodl-loris-svc/src/loris/bin/loris-cache_clean.sh
 * kdu_expand: /home/bodl-loris-svc/sites/bodl-loris-svc/src/loris/bin/kdu_expand
 * Kakadu libraries: /home/bodl-loris-svc/sites/bodl-loris-svc/src/loris/lib/libkdu_v72R.so
 * Logs: /home/bodl-loris-svc/sites/bodl-loris-svc/var/log/loris
 * Image cache (opaque): /home/bodl-loris-svc/sites/bodl-loris-svc/var/cache/loris/img
 * Image cache (symlinks that look like IIIF URIs): /home/bodl-loris-svc/sites/bodl-loris-svc/var/cache/loris/links
 * Info cache: /home/bodl-loris-svc/sites/bodl-loris-svc/var/cache/loris/info
 * www/WSGI application directory: /home/bodl-loris-svc/sites/bodl-loris-svc/src/loris/www
 * Temporary directory: /home/bodl-loris-svc/sites/bodl-loris-svc/tmp

```

Setup library shortlinks
------------------------

```bash
su - <sudo user>
sudo ln -s /usr/include/freetype2 freetype
sudo ln -s /usr/lib/`uname -i`-linux-gnu/libfreetype.so /usr/lib/
sudo ln -s /usr/lib/`uname -i`-linux-gnu/libjpeg.so /usr/lib/
sudo ln -s /usr/lib/`uname -i`-linux-gnu/libz.so /usr/lib/
sudo ln -s /usr/lib/`uname -i`-linux-gnu/liblcms.so /usr/lib/

sudo ln -s /usr/lib/`uname -i`-linux-gnu/libtiff.so /usr/lib/
```

Test images
-----------

Copy the test images into your image root:

```bash 
su - bodl-loris-svc
cp -R /home/bodl-loris-svc/sites/bodl-loris-svc/src/loris/tests/img/* /home/bodl-loris-svc/sites/bodl-loris-svc/var/images
```

Start Apache
------------

From within the virtual environment:

```bash
su - bodl-loris-svc
cd ~/sites/bodl-loris-svc
. bin/activate
/home/bodl-loris-svc/sites/bodl-loris-svc/bin/lorisctl start
```

Browse the following links to test:

http://{your_server}/loris/01/02/0001.jp2/full/full/0/default.jpg
http://{your_server}/loris/01/03/0001.jpg/full/full/0/bitonal.jpg
http://{your_server}/loris/01/04/0001.tif/full/full/0/color.jpg


Setup the reboot script in the sudo crontab
-------------------------------------------

```bash
su - <sudo user>
sudo crontab /home/bodl-loris-svc/sites/bodl-loris-svc/bin/cron.txt
su - bodl-loris-svc
```


Startup scripts and cron jobs (RHEL)
------------------------------------

Add the following in ```/etc/sudoers```. This will allow the cron reboot directive to run sudo commands in ```bin/lorisctl```. This will reboot apache.

```bash
Defaults:<sudo user as given in development/production.cfg> !requiretty
```

Startup scripts and cron jobs
-----------------------------

The following script can be run manually as sudo. 

```bash
su - <sudo user>
/home/bodl-loris-svc/sites/bodl-loris-svc/bin/lorisctl [start|stop|restart]
```

It will stop/start/restart Loris. It runs under a @reboot directive in the sudo crontab to ensure the service comes back up in the event of a server shutdown/restart. It logs progress in ```var/log/reboot.log```.

```bash
@reboot /home/bodl-loris-svc/sites/bodl-loris-svc/bin/lorisctl start > /home/bodl-loris-svc/sites/bodl-loris-svc/var/log/reboot.log 2>&1
```

Continuous Integration
----------------------

.travis.yml and jenkins.sh files are made available for CI configuration.

Currently, Travis builds are available at:

https://travis-ci.org/BDLSS

Builds are run with every GIT commit (after a push). This can be skipped by entering ``[skip ci]`` in the commit message.

Loris has an issue with Travis as the native version of Python compiled on the Travis VM isn't configured with ``./configure --prefix=$HOME/python/2.7.6 --enable-unicode=ucs4 --enable-shared LDFLAGS="-Wl,-rpath=/home/bodl-loris-svc/python/2.7.6/lib"``.

The main problem appears to be the ``enable-shared`` setting, although the ``enable-unicode=ucs4`` has also caused other problems in the past.


Functional and Unit Testing
---------------------------

Pytest is executed in the .travis.yml file as follows:

```bash
script:
- py.test tests/
```

This runs all test scripts using the filename format of ``test_<something>.py`` in the ``tests/`` folder.
