#!/usr/bin/env sh
set -e

# If LocalSettings.php exists in the host-mounted config folder, copy it in
if [ -f /config/LocalSettings.php ]; then
  cp /config/LocalSettings.php /var/www/html/LocalSettings.php
fi;

#else  
  cd /var/www/html/
  BASH_ARGV0=1
  until [ $? = 0 ]; do
    curl -s --head http://host.docker.internal:8080/index.php/Main_Page | head -n 1 | grep "HTTP/1.[01] [23].." 
    sleep 5;
  done;      

  php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
  php -r "if (hash_file('sha384', 'composer-setup.php') === 'dac665fdc30fdd8ec78b38b9800061b4150413ff2e3b6f88543c636f7cd84f6db9189d43a81e5503cda447da73c7e5b6') { echo 'Installer verified'.PHP_EOL; } else { echo 'Installer corrupt'.PHP_EOL; unlink('composer-setup.php'); exit(1); }"
  php composer-setup.php
  php -r "unlink('composer-setup.php');"
  mv composer.phar /usr/local/bin/composer

  COMPOSER=composer.local.json php /usr/local/bin/composer require --no-update mediawiki/semantic-media-wiki

  apt-get update
  apt-get install libzip-dev -y
  docker-php-ext-configure zip && docker-php-ext-install zip

  composer update --no-dev

  php maintenance/update.php
#fi;

exec apache2-foreground