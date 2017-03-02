#!/bin/bash
set -e

# env
SUPER_ADMIN_NAME=${SUPER_ADMIN_NAME:-"user"}
SUPER_ADMIN_PWD=${SUPER_ADMIN_PWD:-"123456"}
CONFIG_DIR=${CONFIG_DIR:-"config"}

STATIC=${STATIC:-true}
PHANJS=${PHANJS:-true}
FIREFOX=${FIREFOX:-false}
CHROME=${CHROME:-false}
SCRAPY=${SCRAPY:-false}

# install packges

echo "***** Start to install an optional dependency packages *****"

apt-get update

# requests
if [ $STATIC = true ]; then
	echo "***** Starting install requests *****"
	pip install requests
	echo "***** Installed requests *****"
fi

if [ $PHANJS = true ]; then
	# phantomjs
	echo "***** Starting install phantomjs dependency *****"
	apt-get -y install libfreetype6 libfreetype6-dev libfontconfig1 libfontconfig1-dev
	apt-get -y install build-essential chrpath libssl-dev libxft-dev
	echo "***** Installed phantomjs *****"
fi

if [ $FIREFOX = true ]; then
	# firefox
	echo "***** Starting install firefox *****"
	apt-get -y install firefox
	echo "***** Installed firefox *****"
fi

if [ $CHROME = true ]; then
	# chrome
	echo "***** Starting install chrome and chromedriver *****"
	apt-get -y install chromium-browser chromium-chromedriver
	ln -sf /usr/lib/chromium-browser/chromedriver /usr/local/bin/
	echo "***** Installed chrome and chromedriver *****"
fi

if [[ $PHANJS = true || $FIREFOX = true || $CHROME = true ]]; then
	# selenium
	echo "***** Starting install selenium *****"
	pip install selenium
	echo "***** Installed selenium *****"
fi

if [[ $FIREFOX = true || $CHROME = true ]]; then
	# firefox and chrome depedent display
	echo "***** Starting install pydisplay *****"
	apt-get -y install xvfb
	pip install pyvirtualdisplay
	echo "***** Installed pydisplay *****"
fi

if [ $SCRAPY = true ]; then
	# scrapy
	echo "***** Starting install Scrapy *****"
	apt-get install -y build-essential libssl-dev libffi-dev
	pip install Scrapy
	echo "***** Installed Scrapy *****"
fi

rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

echo "***** Install end *****"

# setting configs

super_file="/etc/supervisor/supervisord.conf"
if [ -f "$super_file" ]; then
	echo "***** Saveing user authentication to file $super_file *****"

	cat << EOF >> $super_file
username=${SUPER_ADMIN_NAME}
password=${SUPER_ADMIN_PWD}

[include]
files = /etc/supervisor/conf.d/*.conf /app/${CONFIG_DIR}/*.conf
EOF

else
	echo "***** Don't have file $super_file *****"
fi

echo "***** Done *****"
exec "$@"