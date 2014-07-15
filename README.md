Installation
============

Create user "bodl-loris-svc"
------------------

```bash
sudo useradd bodl-loris-svc
sudo passwd bodl-loris-svc
sudo mkdir -p /home/bodl-loris-svc/.ssh
cd /home
sudo chown -R bodl-loris-svc:bodl-loris-svc bodl-loris-svc/
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

```bash
su - <sudo user>
sudo apt-get install $(cat /home/bodl-loris-svc/sites/bodl-loris-svc/ubuntu_requirements)
su - bodl-loris-svc
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
mkdir -p ~/Downloads
cd ~/Downloads
wget http://www.python.org/ftp/python/2.7.6/Python-2.7.6.tgz --no-check-certificate
tar zxfv Python-2.7.6.tgz
cd Python-2.7.6
./configure --prefix=$HOME/python/2.7.6 --enable-shared LDFLAGS="-Wl,-rpath=/home/bodl-loris-svc/python/2.7.6/lib"
make
make install
cd ..
wget http://python-distribute.org/distribute_setup.py
~/python/2.7.6/bin/python distribute_setup.py
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

Install Loris
-------------

```bash
su - <sudo user>
sudo python /home/bodl-loris-svc/sites/bodl-loris-svc/src/loris/setup.py install
```

Installation complete message
-----------------------------

You should see the following information on your screen. You may want to save this information to a file.

```bash
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-
Installation was successful. Here's where things are:

 * Loris configuration: /home/loris/sites/loris/src/loris/etc/loris
 * Cache cleaner cron: /home/loris/sites/loris/src/loris/bin/loris-cache_clean.sh
 * kdu_expand: /home/loris/sites/loris/src/loris/bin/kdu_expand
 * Kakadu libraries: /home/loris/sites/loris/src/loris/lib/libkdu_v72R.so
 * Logs: /home/loris/sites/loris/var/log/loris
 * Image cache (opaque): /home/loris/sites/loris/var/cache/loris/img
 * Image cache (symlinks that look like IIIF URIs): /home/loris/sites/loris/var/cache/loris/links
 * Info cache: /home/loris/sites/loris/var/cache/loris/info
 * www/WSGI application directory: /home/loris/sites/loris/src/loris/www
 * Temporary directory: /home/loris/sites/loris/tmp

```

Ignore the rest.

Setup library shortlinks
------------------------

```bash
sudo ln -s /usr/include/freetype2 freetype
sudo ln -s /usr/lib/`uname -i`-linux-gnu/libfreetype.so /usr/lib/
sudo ln -s /usr/lib/`uname -i`-linux-gnu/libjpeg.so /usr/lib/
sudo ln -s /usr/lib/`uname -i`-linux-gnu/libz.so /usr/lib/
sudo ln -s /usr/lib/`uname -i`-linux-gnu/liblcms.so /usr/lib/

sudo ln -s /usr/lib/`uname -i`-linux-gnu/libtiff.so /usr/lib/
```

Temporarily you will need to copy the kdu library into /usr/lib/. Once this is compiled from source (source is currently unavailable on Q: 11.7.14).

```bash
sudo cp /home/bodl-loris-svc/sites/bodl-loris-svc/src/loris/lib/Linux/x86_64/libkdu_v72R.so /usr/lib/
```

Start Apache
------------

From within the virtual environment:

```bash
/home/bodl-loris-svc/sites/bodl-loris-svc/parts/apache/bin/apachectl start
```

Setup the reboot script in the sudo crontab
-------------------------------------------

```bash
su - <sudo user>
sudo crontab /home/bodl-loris-svc/sites/bodl-loris-svc/bin/cron.txt
su - mdb1
```


Startup scripts and cron jobs (RHEL)
------------------------------------

Add the following in ```/etc/sudoers```. This will allow the cron reboot directive to run sudo commands in ```bin/mldbctl```. This will reboot the php-fpm service and nginx on port 80.

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