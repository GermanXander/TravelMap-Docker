# Usar imagen base de PHP con Apache
FROM php:8.1-apache

# Instalar dependencias de build y herramientas necesarias
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libcurl4-openssl-dev \
    mariadb-client \
    git \
    && rm -rf /var/lib/apt/lists/*

# Instalar extensiones de PHP requeridas
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo pdo_mysql gd fileinfo curl

# Clonar el repositorio de TravelMap
RUN git clone https://github.com/fabiomb/TravelMap.git /var/www/html/

# Cambiar propietario de los archivos a www-data
RUN chown -R www-data:www-data /var/www/html/

# Crear directorios necesarios con permisos
RUN mkdir -p /var/www/html/uploads && \
    chown -R www-data:www-data /var/www/html/uploads

# Exponer puerto 80
EXPOSE 80

# Configurar Apache para usar el directorio correcto
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Crear script de entrada
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Usar el script de entrada
ENTRYPOINT ["docker-entrypoint.sh"]

# Comando por defecto
CMD ["apache2-foreground"]