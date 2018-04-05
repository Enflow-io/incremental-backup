apt-get install python-pip
pip -V
pip install awscli --upgrade --user

export PATH=~/.local/bin/:$PATH # to .bash_profile
apt-get install python2.7-dev #pip install awscli --force-reinstall --upgrade --user

aws s3 cp ./backper.sh s3://enflow-server
