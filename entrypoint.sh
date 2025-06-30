#!/usr/bin/env sh
set -e

# If LocalSettings.php exists in the host-mounted config folder, copy it in
if [ -f /config/LocalSettings.php ]; then
  cp /config/LocalSettings.php /var/www/html/LocalSettings.php
  php maintenance/update.php
fi;

exec apache2-foreground