#!/bin/bash

set -e 

echo "================================================"
echo "   Arix Theme Auto-Installer Script by Shubham"
echo "   Starting Installation..."
echo "================================================"
apt install wget

cd /var/www/pterodactyl || { echo "Error: /var/www/pterodactyl folder not found!"; exit 1; }


echo "-> Downloading and extracting theme files..."
wget -q https://github.com/ArainCloud07/arix-craked/raw/refs/heads/main/pterodactyl.zip -O pterodactyl.zip

unzip -o pterodactyl.zip


if [ -d "pterodactyl" ]; then
    echo "-> Moving files from nested folder to main folder..."
    cp -rf pterodactyl/* ./
    rm -rf pterodactyl
fi

rm pterodactyl.zip

echo "-> Installing system dependencies..."
sudo apt update
sudo apt install -y ca-certificates curl git gnupg unzip wget zip

echo "-> Setting up Node.js 22.x..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --yes --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
sudo apt update
sudo apt install -y nodejs

echo "-> Installing Yarn and Node packages..."
npm i -g yarn
yarn install

echo "-> Running Arix installer..."
php artisan arix install

set +e
echo "-> Fixing permissions and preventing 'File not found' errors..."

curl -sL https://raw.githubusercontent.com/pterodactyl/panel/master/public/index.php -o public/index.php

chown -R www-data:www-data /var/www/pterodactyl 2>/dev/null
chown -R nginx:nginx /var/www/pterodactyl 2>/dev/null

find /var/www/pterodactyl -type d -exec chmod 755 {} \;
find /var/www/pterodactyl -type f -exec chmod 644 {} \;
chmod -R 775 storage/* bootstrap/cache/

php artisan view:clear
php artisan optimize:clear

echo "=========================================="
echo "  Arix Theme Installation Complete! 🎉"
echo "  Your panel is ready and error-free!"
echo "=========================================="
