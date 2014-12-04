Introduction
============

This Loris build is intended for Ubuntu 14.0, Loris 2.0.0-beta1 and Kakadu 7.2. These versions can be changed, see ```development[_docker].cfg``` and ```Dockerfile```. 

BDLSS Docker CI
https://registry.hub.docker.com/u/calvinbutcher/buildout.loris/

Github Loris source https://github.com/pulibrary/loris

**Please note:** ```setup.py```, ```transforms.py``` and ```webapp.py``` from the loris source have hard coded paths and kakadu library names. These files have been brought in as templates in the ```conf/``` directory and will be deployed with the correct paths and filenames.

If you are updating the loris source from 2.0.0-beta1 (you can do this by entering a new tag name inside the ```development[_docker].cfg``` file) you *may* need to update these files with their new versions. However, the buildout parameter tags ```${...}``` will need to be replaced.


Installation
============

To deploy Loris on a server, follow these instructions. Whenever this GIT account is updated, Docker will run a test deployment at ```https://registry.hub.docker.com/u/calvinbutcher/buildout.loris/```. Please see **Continuous Integration** section below for more details.

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

Install and configure Git 
-------------------------

```bash
su - <sudo user>
sudo apt-get install git
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
git clone https://github.com/BDLSS/buildout.loris.git ./
```
Setup server
------------

```bash
su - <sudo user>
sudo apt-get install $(cat /home/bodl-loris-svc/sites/bodl-loris-svc/ubuntu_requirements)
su - bodl-loris-svc
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
mkdir /home/bodl-loris-svc/.buildout
cd /home/bodl-loris-svc/.buildout
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

For BDLSS users, you can retrieve the source from databank (you will need a user account for databank):

```bash
cd ~/Downloads
curl --user <username>:<password> -o Kakadu_v72.zip https://databank.ora.ox.ac.uk/dmt/datasets/Kakadu/Kakadu_v72.zip 
unzip -d kakadu Kakadu_v72.zip
```

Otherwise you will need to ```scp```, ```wget``` or ```curl``` your licensed Kakadu source into the ```~/Downloads``` directory as a folder called 'kakadu'.

Buildout will compile the source and distribute the libraries and applications required (namely the shared object library and kdu_expand).

Create a virtualenv and run the buildout
----------------------------------------
Add _docker to development.cfg if running in docker environment (or remove [...] from code below).

```bash
cd ~/sites/bodl-loris-svc
~/python/2.7.6/bin/virtualenv .
. bin/activate
pip install zc.buildout
pip install distribute
buildout init
buildout -c development.cfg
```

Install Loris
-------------

```bash

cd /home/bodl-loris-svc/sites/bodl-loris-svc/parts/loris
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
cp -R /home/bodl-loris-svc/sites/bodl-loris-svc/parts/loris/tests/img/* /home/bodl-loris-svc/sites/bodl-loris-svc/var/images
```

Start Apache
------------

```bash
su - <sudo user>
sudo chmod +x /home/bodl-loris-svc/sites/bodl-loris-svc/bin/lorisctl
sudo /home/bodl-loris-svc/sites/bodl-loris-svc/bin/lorisctl start
```

Browse the following links to test:
```bash
http://{your_server, e.g. localhost:8080}/loris/67352ccc-d1b0-11e1-89ae-279075081939.jp2/full/full/0/default.jpg
http://{your_server, e.g. localhost:8080}/loris/67352ccc-d1b0-11e1-89ae-279075081939.jp2/info.json
```

Setup the reboot script in the sudo crontab
-------------------------------------------

```bash
su - <sudo user>
sudo crontab /home/bodl-loris-svc/sites/bodl-loris-svc/bin/cron.txt
su - bodl-loris-svc
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

The Dockerfile will run the ```_docker.cfg``` version of development.cfg. This just ensures that users are named properly (the 'env' recipe does not work inside containers) and that the localhost is pointed to all IPs (as this cannot be dictated or predicted when creating a container).

Docker
https://registry.hub.docker.com/u/calvinbutcher/buildout.loris/

If any of the 21 IIIF validation tests fail, Docker will exit with a non-zero result. This means the Docker build will fail and read "Error".

Functional and Unit Testing
---------------------------

Pytest is executed in the docker run.

This runs all test scripts using the filename format of ``test_<something>.py`` in the ``tests/`` folder.
