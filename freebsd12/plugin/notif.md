[Yowsup Under Nagios](https://www.unixmen.com/send-nagios-alert-notification-using-whatsapp/)(https://www.unixmen.com/send-nagios-alert-notification-using-whatsapp/)

```sh
## Upgrde Package Python 3.7
sudo yum -y install wget make gcc openssl-devel bzip2-devel

cd /tmp
wget https://www.python.org/ftp/python/3.7.1/Python-3.7.11.tgz
tar xzf Python-3.7.11.tgz

cd Python-3.7.11
./configure --enable-optimizations
make altinstall
ln -sfn /usr/local/bin/python3.7 /usr/bin/python3.7 && ln -sfn /usr/local/bin/python3.7 /usr/bin/python3 && ln -sfn /usr/local/bin/python3.7 /usr/bin/py3
ln -sfn /usr/local/bin/pip3.7 /usr/bin/pip3.7 && ln -sfn /usr/local/bin/pip3.7 /usr/bin/pip3

sudo rm /tmp/Python-3.7.11.tgz

## clone Yowsup
cd /tmp
wget -O yowsup.tar.gz https://github.com/tgalal/yowsup/archive/refs/tags/v3.3.0.tar.gz
tar xzf yowsup.tar.gz && cd yowsup-3.3.0/
chmod +x setup.py

python setup.py install
chmod +x yowsup-cli