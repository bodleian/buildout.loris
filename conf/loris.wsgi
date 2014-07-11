import sys;
sys.path.append('${buildout:directory}/src/loris')
#sys.path.append('/home/${users:buildout-user}/.buildout/eggs/Pillow-2.5.0-py2.7-linux-x86_64.egg')
sys.path.append('/home/${users:buildout-user}/.buildout/eggs/Werkzeug-0.9.6-py2.7.egg')

from loris.webapp import create_app
application = create_app()