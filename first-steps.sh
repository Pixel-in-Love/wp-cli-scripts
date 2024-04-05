#!/bin/bash

echo "Configuración de primeros pasos"

read -p "Escribe el nombre del sitio web: " site_name
site_folder="$HOME/domains/$site_name"

if [ ! -d "$site_folder" ]; then
  echo "Error: el sitio web no existe."
  exit 1
fi

cd "$site_folder/public_html"

#borra el titulo y la descripción por defecto
wp option update blogname ''
wp option update blogdescription ''
echo "Título y descripción por defecto eliminados"

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

#cambiar correo electrónico del administrador
wp option update admin_email 'cristina@pixelinlove.net'
echo "Correo electrónico del administrador cambiado"

#eliminar widgets del dashboard menos el de salud del sitio
wp eval-file /tmp/remove_dashboard_widgets.php
echo "Widgets del dashboard eliminados"

#disuadir motores de búsqueda
wp option update blog_public 0
echo "Motores de búsqueda disuadidos"

#establecer el tamaño de la miniatura a 300x300
wp option update thumbnail_size_w 300
wp option update thumbnail_size_h 300
#establecer el tamaño de la miniatura de tamaño medio a 600x600
wp option update medium_size_w 600
wp option update medium_size_h 600
#establecer el tamaño de la miniatura grande a 1200x1200
wp option update large_size_w 1200
wp option update large_size_h 1200
echo "Tamaños de imagen cambiados"

#cambiar enlaces permanentes
wp rewrite structure '/%postname%/'
echo "Enlaces permanentes cambiados"

#borrar todas las entradas y páginas por defecto
wp post delete $(wp post list --post_type=post --post_status=publish --posts_per_page=100 --field=ID --format=ids)
wp post delete $(wp post list --post_type=page --post_status=publish --posts_per_page=100 --field=ID --format=ids)
#vacia la papelera
wp post delete $(wp post list --post_status=trash --posts_per_page=100 --field=ID --format=ids)
echo "Entradas y páginas por defecto eliminadas"

#crear página de inicio llamada "Inicio"
wp post create --post_type=page --post_title='Inicio' --post_status=publish
#establecer la página de inicio como la página de inicio
wp option update show_on_front 'page'
wp option update page_on_front $(wp post list --post_type=page --post_status=publish --posts_per_page=1 --pagename=inicio --field=ID --format=ids)
echo "Página de inicio creada"

#borra todos los plugins por defecto
wp plugin deactivate --all
wp plugin delete --all
echo "Plugins por defecto eliminados"

#borra todos los temas por defecto menos el tema activo
active_theme=$(wp theme list --status=active --field=name)
wp theme list --status=inactive --field=name | grep -v "$active_theme" | xargs wp theme delete
echo "Temas por defecto eliminados"

#instalar y activar plugins: duplicate-page, all-in-one-migration, svg-support, wp-mail-logging
wp plugin install duplicate-page all-in-one-wp-migration svg-support wp-mail-logging --activate
#instalar plugins: cookie-law-info, sg-security, wordpress-seo
wp plugin install cookie-law-info sg-security wordpress-seo
#instalar y activar el plugin all-in-one-wp-migration-dropbox-extension
wp plugin install $HOME/wp-cli-files/all-in-one-wp-migration-dropbox-extension.zip --activate

#esperar 10 segundos para que se activen los plugins
sleep 10
#mostrar una cuenta atrás de 10 segundos
for i in {10..1}; do echo $i; sleep 1; done
#actualizar todos los plugins
wp plugin update --all
echo "Plugins instalados y activados"

#instalar el tema Divi cuyo archivo zip está en la misma carpeta que este script
wp theme install $HOME/wp-cli-files/divi.zip
#activar el tema Divi
wp theme activate Divi
echo "Tema Divi instalado y activado"

#crea un tema hijo de Divi
wp scaffold child-theme divi-child --parent_theme=Divi --theme_name="Divi Child"
#activa el tema hijo de Divi
wp theme activate divi-child
echo "Tema hijo de Divi creado"

#borra todos los usuarios por defecto
wp user delete $(wp user list --role=administrator --field=ID --format=ids) --reassign=1
wp user delete $(wp user list --role=editor --field=ID --format=ids) --yes
wp user delete $(wp user list --role=author --field=ID --format=ids) --yes
wp user delete $(wp user list --role=contributor --field=ID --format=ids) --yes
wp user delete $(wp user list --role=subscriber --field=ID --format=ids) --yes
echo "Usuarios por defecto eliminados"

#crear un usuario administrador
wp user create admin cristina@pixelinlove.net --user_pass=admin
wp user add-role admin administrator
wp user remove-role admin subscriber
echo "Usuario administrador creado"

echo "Configuración de primeros pasos completada"
