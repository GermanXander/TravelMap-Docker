# Usar imagen base de PHP con Apache
FROM php:8.1-apache

# Instalar dependencias de build y herramientas necesarias
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libcurl4-openssl-dev \
    libmagickwand-dev \
    libzip-dev \
    mariadb-client \
    git \
    && rm -rf /var/lib/apt/lists/*

# Instalar extensiones de PHP requeridas
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo pdo_mysql gd fileinfo curl exif zip

# Habilitar todas las extensiones
RUN docker-php-ext-enable pdo pdo_mysql gd fileinfo curl exif zip

# Instalar imagick desde PECL
RUN pecl install imagick && docker-php-ext-enable imagick

# Configurar límites de carga de archivos
RUN echo "upload_max_filesize = 500M" > /usr/local/etc/php/conf.d/uploads.ini && \
    echo "post_max_size = 500M" >> /usr/local/etc/php/conf.d/uploads.ini && \
    echo "max_file_uploads = 200" >> /usr/local/etc/php/conf.d/uploads.ini && \
    echo "error_reporting = E_ALL" >> /usr/local/etc/php/conf.d/uploads.ini && \
    echo "display_errors = Off" >> /usr/local/etc/php/conf.d/uploads.ini && \
    echo "log_errors = On" >> /usr/local/etc/php/conf.d/uploads.ini

# Clonar el repositorio de TravelMap
RUN git clone https://github.com/GermanXander/TravelMap.git /var/www/html/

# Cambiar propietario de los archivos a www-data
RUN chown -R www-data:www-data /var/www/html/

# Crear directorios necesarios con permisos
RUN mkdir -p /var/www/html/uploads && \
    chmod -R 775 /var/www/html/uploads && \
    chown -R www-data:www-data /var/www/html/

# Exponer puerto 80
EXPOSE 80

# Configurar Apache para proxy headers
RUN a2enmod remoteip headers rewrite && \
    echo "RemoteIPHeader X-Forwarded-For" >> /etc/apache2/mods-enabled/remoteip.conf && \
    echo "RemoteIPTrustedProxy 127.0.0.1 172.16.0.0/12 192.168.0.0/16 10.0.0.0/8" >> /etc/apache2/mods-enabled/remoteip.conf && \
    echo "" >> /etc/apache2/apache2.conf && \
    echo "# Configurar para proxy inverso - pasar headers al script PHP" >> /etc/apache2/apache2.conf && \
    echo "SetEnvIf X-Forwarded-Proto https HTTPS=on" >> /etc/apache2/apache2.conf && \
    echo "SetEnvIf X-Forwarded-Host \"^(.+)$\" HTTP_X_FORWARDED_HOST=\$1" >> /etc/apache2/apache2.conf

# Crear script de entrada y script auxiliar
COPY docker-entrypoint.sh /usr/local/bin/
COPY fix-config.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh /usr/local/bin/fix-config.sh

# Usar el script de entrada
ENTRYPOINT ["docker-entrypoint.sh"]

# Comando por defecto
CMD ["apache2-foreground"]