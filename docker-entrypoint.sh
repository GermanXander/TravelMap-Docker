#!/bin/bash

# Esperar a que la base de datos esté disponible
echo "Esperando a que la base de datos esté disponible..."
while ! mysqladmin ping -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASSWORD" --silent --skip-ssl; do
    echo "Base de datos no disponible, esperando..."
    sleep 2
done
echo "Base de datos disponible."

# Modificar config/db.php para usar variables de entorno
sed -i "s/private const DB_HOST = '127.0.0.1';/private const DB_HOST = '${DB_HOST}';/" /var/www/html/config/db.php
sed -i "s/private const DB_NAME = 'travelmap';/private const DB_NAME = '${DB_NAME}';/" /var/www/html/config/db.php
sed -i "s/private const DB_USER = 'root';/private const DB_USER = '${DB_USER}';/" /var/www/html/config/db.php
sed -i "s/private const DB_PASS = '';/private const DB_PASS = '${DB_PASSWORD}';/" /var/www/html/config/db.php

# Modificar config/config.php para ajustar la URL base
sed -i "s/\$folder = '\/Travelmap';/\$folder = '';/" /var/www/html/config/config.php

# Ejecutar el script SQL para crear las tablas
echo "Ejecutando script SQL..."
mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" --skip-ssl < /var/www/html/database.sql

# Ejecutar el script para crear usuario admin
echo "Creando usuario administrador..."
php /var/www/html/install/seed_admin.php > /dev/null 2>&1

# Eliminar la carpeta install por seguridad
rm -rf /var/www/html/install

# Iniciar Apache
echo "Iniciando Apache..."
exec "$@"