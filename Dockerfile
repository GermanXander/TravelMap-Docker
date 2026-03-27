# Usar imagen base de PHP con Apache
FROM php:8.1-apache

# Instalar extensiones de PHP requeridas
RUN docker-php-ext-install pdo pdo_mysql gd fileinfo curl

# Instalar herramientas adicionales si es necesario (opcional)
RUN apt-get update && apt-get install -y \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# Copiar el código del proyecto al contenedor
COPY . /var/www/html/

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