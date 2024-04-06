#!/bin/bash

echo "Configurar sitio web para importar"

read -p "Escribe el nombre del sitio web: " site_name
site_folder="$HOME/domains/$site_name"

if [ ! -d "$site_folder" ]; then
  echo "Error: el sitio web no existe."
  exit 1
fi

cd "$site_folder/public_html"

#traducir wordpress
wp language core install es_ES --activate
echo "WordPress traducido a español"

#cambiar zona horaria a Madrid
wp option update timezone_string 'Europe/Madrid'
echo "Zona horaria cambiada a Madrid"

#cambiar formato de fecha a d/m/Y
wp option update date_format 'd/m/Y'
echo "Formato de fecha cambiado a d/m/Y"

#cambiar formato de hora a H:i
wp option update time_format 'H:i'
echo "Formato de hora cambiado a 24h"

#desactivar comentarios
wp option update default_comment_status 'closed'
echo "Comentarios desactivados"

#borrar todas las entradas y páginas por defecto
wp post delete $(wp post list --post_type=post --post_status=publish --posts_per_page=100 --field=ID --format=ids)
wp post delete $(wp post list --post_type=page --post_status=publish --posts_per_page=100 --field=ID --format=ids)
#vacia la papelera
wp post delete $(wp post list --post_status=trash --posts_per_page=100 --field=ID --format=ids)
echo "Entradas y páginas por defecto eliminadas"

#borra todos los plugins por defecto
wp plugin deactivate --all
wp plugin delete --all
echo "Plugins por defecto eliminados"

#borra todos los temas por defecto menos el tema activo
active_theme=$(wp theme list --status=active --field=name)
wp theme list --status=inactive --field=name | grep -v "$active_theme" | xargs wp theme delete
echo "Temas por defecto eliminados"

#instalar y activar plugin all-in-one-migration
wp plugin install all-in-one-wp-migration --activate
#instalar y activar el plugin all-in-one-wp-migration-dropbox-extension
wp plugin install $HOME/wp-cli-files/all-in-one-wp-migration-dropbox-extension.zip --activate
wp plugin update all-in-one-wp-migration-dropbox-extension
echo "Plugins instalados y activados"

#borra todos los usuarios por defecto
wp user delete $(wp user list --role=administrator --field=ID --format=ids) --reassign=1
echo "Usuarios por defecto eliminados"

#crear un usuario administrador
wp user create admin cristina@pixelinlove.net --user_pass=admin
wp user add-role admin administrator
wp user remove-role admin subscriber
echo "Usuario administrador creado"

echo "Sitio web listo para importar"
