#!/bin/bash

# Script para actualizar config/config.php para soportar X-Forwarded-Host y X-Forwarded-Proto

CONFIG_FILE="/var/www/html/config/config.php"

# Crear archivo temporal
TEMP_FILE="/tmp/config-fixed.php"

# Usar awk para procesar línea por línea y hacer los reemplazos
awk '
/^\$protocol = isset\(\$_SERVER\[.HTTPS.\]/ {
    print "$protocol = (isset($_SERVER['"'"'HTTP_X_FORWARDED_PROTO'"'"']) ? $_SERVER['"'"'HTTP_X_FORWARDED_PROTO'"'"'] : (isset($_SERVER['"'"'HTTPS'"'"']) && $_SERVER['"'"'HTTPS'"'"'] === '"'"'on'"'"' ? '"'"'https'"'"' : '"'"'http'"'"'));";
    next;
}
/^\$host = \$_SERVER\[.HTTP_HOST.\]/ {
    print "$host = $_SERVER['"'"'HTTP_X_FORWARDED_HOST'"'"'] ?? $_SERVER['"'"'HTTP_HOST'"'"'] ?? '"'"'localhost'"'"';";
    next;
}
{ print; }
' "$CONFIG_FILE" > "$TEMP_FILE"

# Reemplazar el archivo original
mv "$TEMP_FILE" "$CONFIG_FILE"

echo "✓ config.php actualizado para soportar headers de proxy"
