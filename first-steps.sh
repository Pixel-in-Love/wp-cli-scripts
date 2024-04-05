#!/bin/bash

echo "Configuración de primeros pasos"

read -p "Escribe el nombre del sitio web: " site_name
site_folder="$HOME/domains/$site_name"

if [ ! -d "$site_folder" ]; then
  echo "Error: el sitio web no existe."
  exit 1
fi

cd "$site_folder"
cd "public_html"

wp option get siteurl