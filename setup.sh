#!/bin/sh
[ -e .git ] && rm -r -f .git
rm LICENSE
rm README.md
chmod 600 login-config.php
chmod 755 shell.sh
wget https://code.jquery.com/jquery-3.3.1.min.js -O jquery.js
rm setup.sh
exit 0
