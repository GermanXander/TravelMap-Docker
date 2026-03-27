# TravelMap Docker

Este Dockerfile permite ejecutar TravelMap (https://github.com/fabiomb/TravelMap) en un contenedor Docker con una base de datos MariaDB externa.
Créditos para el gran trabajo de **fabiomb**

## Requisitos

- Docker
- Docker Compose (opcional)

## Variables de Entorno

Configura las siguientes variables de entorno para la conexión a la base de datos:

- `DB_HOST`: Host de la base de datos (ej: mariadb)
- `DB_PORT`: Puerto de la base de datos (ej: 3306)
- `DB_NAME`: Nombre de la base de datos (ej: travelmap)
- `DB_USER`: Usuario de la base de datos
- `DB_PASSWORD`: Contraseña del usuario

## Construir y Ejecutar

### Usando Docker Compose (recomendado)

1. Asegúrate de tener el código del proyecto en el directorio actual.
2. Ejecuta:

```bash
docker-compose up --build
```

Esto iniciará tanto la aplicación como una instancia de MariaDB.

Accede a http://localhost:8080

### Usando Docker solo

1. Construye la imagen:

```bash
docker build -t travelmap .
```

2. Ejecuta el contenedor (ajusta las variables de entorno):

```bash
docker run -p 8080:80 \
  -e DB_HOST=tu_host_db \
  -e DB_PORT=3306 \
  -e DB_NAME=travelmap \
  -e DB_USER=tu_usuario \
  -e DB_PASSWORD=tu_password \
  -v ./uploads:/var/www/html/uploads \
  travelmap
```

## Notas

- La base de datos debe estar creada previamente.
- El script SQL se ejecuta automáticamente al iniciar el contenedor.
- Se crea un usuario administrador: admin / admin123
- La carpeta `install/` se elimina por seguridad después de la instalación.
- Los uploads se persisten en el volumen `./uploads`

## Acceso

- Panel público: http://localhost:8080
- Panel admin: http://localhost:8080/admin/
- Login: admin / admin123
