#!/bin/bash

########## ---------- Preparar Carpetas ---------- ##########

CRE=$(tput setaf 1)
CYE=$(tput setaf 3)
CGR=$(tput setaf 2)
CBL=$(tput setaf 4)
BLD=$(tput bold)
CNC=$(tput sgr0)

backup_folder=~/.RiceBackup
date=$(date +%Y%m%d-%H%M%S)
ERROR_LOG="$HOME/RiceError.log"

logo () {

    local text="${1:?}"
    echo -en "
	               %%%
	        %%%%%//%%%%%
	      %%************%%%
	  (%%//############*****%%
	%%%%%**###&&&&&&&&&###**//
	%%(**##&&&#########&&&##**
	%%(**##*****#####*****##**%%%
	%%(**##     *****     ##**
	   //##   @@**   @@   ##//
	     ##     **###     ##
	     #######     #####//
	       ###**&&&&&**###
	       &&&         &&&
	       &&&////   &&
	          &&//@@@**
	            ..***
    z0mbi3 Dotfiles\n\n"
    printf ' %s [%s%s %s%s %s]%s\n\n' "${CRE}" "${CNC}" "${CYE}" "${text}" "${CNC}" "${CRE}" "${CNC}"
}

########## ---------- You must not run this as root ---------- ##########

if [ "$(id -u)" = 0 ]; then
    echo "This script MUST NOT be run as root user."
    exit 1
fi

home_dir=$HOME
current_dir=$(pwd)

if [ "$current_dir" != "$home_dir" ]; then
    printf "%s%sThe script must be executed from the HOME directory.%s\n" "${BLD}" "${CYE}" "${CNC}"
    exit 1
fi

log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$ERROR_LOG"
}


# Verificar si el archivo user-dirs.dirs no existe en ~/.config
if [ ! -e "$HOME/.config/user-dirs.dirs" ]; then
    xdg-user-dirs-update
fi

########## ---------- Clonar el repositorio de dotfiles ---------- ##########

echo -e "\033[1;34m==== Descargando dotfiles ====\033[0m"
repo_url="https://github.com/ChrisMethsillo/gh0stzk-bspwm-kali.git"
repo_dir="$HOME/dotfiles"

# Verificar si el directorio del repositorio existe, y si existe, eliminarlo
if [ -d "$repo_dir" ]; then
    echo "Eliminando repositorio existente de dotfiles..."
    rm -rf "$repo_dir"
fi

# Clonar el repositorio
echo "Clonando dotfiles desde $repo_url..."
git clone --depth=1 "$repo_url" "$repo_dir" || { echo "Error al clonar dotfiles"; exit 1; }
clear

########## ---------- Respaldar Archivos ---------- ##########

echo -e "\033[1;34m==== Respaldando archivos existentes ====\033[0m"
backup_folder="$HOME/.RiceBackup"
date=$(date +%Y%m%d)

# Crear la carpeta de respaldo si no existe
[ ! -d "$backup_folder" ] && mkdir -p "$backup_folder"

config_folders=("bspwm" "alacritty" "picom" "rofi" "eww" "sxhkd" "dunst" "kitty" "polybar" "geany" "gtk-3.0" "ncmpcpp" "ranger" "tmux" "zsh" "mpd")
misc_files=(".zshrc" ".gtkrc-2.0" ".icons")

# Respaldar carpetas de configuración
for folder in "${config_folders[@]}"; do
    if [ -d "$HOME/.config/$folder" ]; then
        echo "Respaldando $folder..."
        mv "$HOME/.config/$folder" "$backup_folder/${folder}_$date" || echo "Error al respaldar $folder."
    fi
done

# Respaldar archivos
for file in "${misc_files[@]}"; do
    if [ -f "$HOME/$file" ]; then
        echo "Respaldando $file..."
        mv "$HOME/$file" "$backup_folder/${file}_$date" || echo "Error al respaldar $file."
    fi
done

# Respaldar configuración de Firefox
firefox_profile=$(find "$HOME/.mozilla/firefox" -name "*.default-release" -type d)
if [ -n "$firefox_profile" ]; then
    for firefox_item in "chrome" "user.js"; do
        if [ -e "$firefox_profile/$firefox_item" ]; then
            echo "Respaldando $firefox_item de Firefox..."
            mv "$firefox_profile/$firefox_item" "$backup_folder/${firefox_item}_$date" || echo "Error al respaldar $firefox_item."
        fi
    done
fi

########## ---------- Instalar los dotfiles ---------- ##########

echo -e "${BLD}${CBL}==== Instalando dotfiles ====${CNC}"
printf "Copying files to respective directories..\n"

[ ! -d ~/.config ] && mkdir -p ~/.config
[ ! -d ~/.local/bin ] && mkdir -p ~/.local/bin
[ ! -d ~/.local/share ] && mkdir -p ~/.local/share

for dirs in ~/dotfiles/config/*; do
    dir_name=$(basename "$dirs")
# If the directory is nvim and the user doesn't want to try it, skip this loop
    if [[ $dir_name == "nvim" && $try_nvim != "y" ]]; then
        continue
    fi
    if cp -R "${dirs}" ~/.config/ 2>> RiceError.log; then
        printf "%s%s%s %sconfiguration installed succesfully%s\n" "${BLD}" "${CYE}" "${dir_name}" "${CGR}" "${CNC}"
        sleep 1
    else
        printf "%s%s%s %sconfiguration failed to been installed, see %sRiceError.log %sfor more details.%s\n" "${BLD}" "${CYE}" "${dir_name}" "${CRE}" "${CBL}" "${CRE}" "${CNC}"
        sleep 1
    fi
done

for folder in applications asciiart fonts startup-page; do
    if cp -R ~/dotfiles/misc/$folder ~/.local/share/ 2>> RiceError.log; then
        printf "%s%s%s %sfolder copied succesfully!%s\n" "${BLD}" "${CYE}" "$folder" "${CGR}" "${CNC}"
        sleep 1
    else
        printf "%s%s%s %sfolder failed to been copied, see %sRiceError.log %sfor more details.%s\n" "${BLD}" "${CYE}" "$folder" "${CRE}" "${CBL}" "${CRE}" "${CNC}"
        sleep 1
    fi
done

if cp -R ~/dotfiles/misc/bin ~/.local/ 2>> RiceError.log; then
    printf "%s%sbin %sfolder copied succesfully!%s\n" "${BLD}" "${CYE}" "${CGR}" "${CNC}"
    sleep 1
else
    printf "%s%sbin %sfolder failed to been copied, see %sRiceError.log %sfor more details.%s\n" "${BLD}" "${CYE}" "${CRE}" "${CBL}" "${CRE}" "${CNC}"
    sleep 1
fi

if cp -R ~/dotfiles/misc/firefox/* ~/.mozilla/firefox/*.default-release/ 2>> RiceError.log; then
    printf "%s%sFirefox theme %scopied succesfully!%s\n" "${BLD}" "${CYE}" "${CGR}" "${CNC}"
    sleep 1
else
    printf "%s%sFirefox theme %sfailed to been copied, see %sRiceError.log %sfor more details.%s\n" "${BLD}" "${CYE}" "${CRE}" "${CBL}" "${CRE}" "${CNC}"
    sleep 1
fi


if cp -R ~/dotfiles/home/.icons "$HOME" 2>> RiceError.log; then
    printf "%s%s.icons folder %scopied succesfully!%s\n" "${BLD}" "${CYE}" "${CGR}" "${CNC}"
    sleep 1
else
    printf "%s%s.icons folder %sfailed to been copied, see %sRiceError.log %sfor more details.%s\n" "${BLD}" "${CYE}" "${CRE}" "${CBL}" "${CRE}" "${CNC}"
    sleep 1
fi

sed -i "s/user_pref(\"browser.startup.homepage\", \"file:\/\/\/home\/z0mbi3\/.local\/share\/startup-page\/index.html\")/user_pref(\"browser.startup.homepage\", \"file:\/\/\/home\/$USER\/.local\/share\/startup-page\/index.html\")/" "$HOME"/.mozilla/firefox/*.default-release/user.js
sed -i "s/name: 'gh0stzk'/name: '$USER'/" "$HOME"/.local/share/startup-page/config.js
cp -f "$HOME"/dotfiles/home/.zshrc "$HOME"
cp -f "$HOME"/dotfiles/home/.gtkrc-2.0 "$HOME"
fc-cache -rv >/dev/null 2>&1

printf "\n\n%s%sFiles copied succesfully!!%s\n" "${BLD}" "${CGR}" "${CNC}"
sleep 3
clear

echo -e "${BLD}${CBL}==== Configurando servicio MPD ====${CNC}"

if systemctl is-enabled --quiet mpd.service; then
    echo -e "${BLD}${CBL}Deshabilitando y deteniendo el servicio global de MPD...${CNC}"
    if sudo systemctl disable --now mpd.service >/dev/null 2>>"$ERROR_LOG"; then
        echo -e "${BLD}[${CGR}OK${CNC}${BLD}] Servicio global de MPD deshabilitado correctamente.${CNC}"
    else
        echo -e "${BLD}[${CRE}Error${CNC}${BLD}] Error al deshabilitar el servicio global de MPD. Verifica $ERROR_LOG.${CNC}"
        log_error "Error al deshabilitar el servicio global de MPD."
    fi
fi

echo -e "${BLD}${CBL}Habilitando y iniciando el servicio MPD a nivel de usuario...${CNC}"
if systemctl --user enable --now mpd.service >/dev/null 2>>"$ERROR_LOG"; then
    echo -e "${BLD}[${CGR}OK${CNC}${BLD}] Servicio MPD a nivel de usuario habilitado correctamente.${CNC}"
else
    echo -e "${BLD}[${CRE}Error${CNC}${BLD}] Error al habilitar el servicio MPD a nivel de usuario. Verifica $ERROR_LOG.${CNC}"
    log_error "Error al habilitar el servicio MPD a nivel de usuario."
fi

sleep 3
clear

########## ---------- Cambiar shell a Zsh ---------- ##########

echo -e "${BLD}${CBL}==== Cambiando el shell predeterminado a zsh ====${CNC}"

if [[ $SHELL != "/usr/bin/zsh" ]]; then
    echo -e "${BLD}${CYE}Cambiando tu shell a zsh...${CNC}"
    if chsh -s /usr/bin/zsh 2>>"$ERROR_LOG"; then
        echo -e "${BLD}[${CGR}OK${CNC}${BLD}] Shell cambiado a zsh correctamente.${CNC}"
    else
        echo -e "${BLD}[${CRE}Error${CNC}${BLD}] Error al cambiar el shell a zsh. Verifica $ERROR_LOG.${CNC}"
        log_error "Error al cambiar el shell a zsh."
    fi
else
    echo -e "${BLD}${CGR}Tu shell ya está configurado como zsh.${CNC}"
fi

sleep 3
clear


echo -e "\033[1;32m==== Configuración completada correctamente ====\033[0m"

