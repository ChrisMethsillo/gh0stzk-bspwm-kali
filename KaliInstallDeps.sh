#!/bin/bash

# ==============================
# COLORES PARA LA CONSOLA
# ==============================
BLD=$(tput bold)
CGR="\033[32m"  # Verde
CYE="\033[33m"  # Amarillo
CRE="\033[31m"  # Rojo
CBL="\033[34m"  # Azul
CNC="\033[0m"   # Reset de color

# ==============================
# FUNCIONES
# ==============================

# Barra de progreso simple
progress_bar() {
    local total=$1
    local current=$2
    local width=50
    local progress=$((current * width / total))
    local remaining=$((width - progress))
    printf "\r["
    printf "#%.0s" $(seq 1 $progress)
    printf " %.0s" $(seq 1 $remaining)
    printf "] %s%%" $((current * 100 / total))
}

# Verificar si un paquete está instalado (APT)
is_installed() {
    local package="$1"
    dpkg -l | grep -q "^ii  $package "
}

# Instalar desde apt
install_from_apt() {
    local package="$1"
    echo -e "\n${BLD}${CBL}===== Verificando paquete: $package =====${CNC}"

    if is_installed "$package"; then
        echo -e "${BLD}${CGR}[✔] $package ya está instalado.${CNC}"
    else
        echo -e "${BLD}${CYE}[~] Comenzando instalación de $package...${CNC}"
        sleep 1
        echo -e "${BLD}${CYE}Mostrando logs de instalación para $package:${CNC}"
        sleep 1

        # Ejecutar apt y mostrar logs en tiempo real
        if sudo apt install -y "$package" 2>&1 | tee >(sed "s/^/${BLD}${CNC}[LOG] /"); then
            echo -e "\n${BLD}${CGR}[✔] $package instalado correctamente.${CNC}"
        else
            echo -e "\n${BLD}${CRE}[✘] Error al instalar $package.${CNC}"
            echo -e "${BLD}${CRE}Intenta verificar manualmente con: sudo apt install $package${CNC}"
        fi
    fi
    echo -e "${BLD}${CBL}===== Fin del proceso para: $package =====${CNC}\n"
    sleep 1
}

# Instalar desde GitHub
install_from_git() {
    local name="$1"
    local repo_url="$2"
    local repo_dir="/tmp/$name"

    echo -e "${BLD}${CYE}[~] Clonando e instalando desde $repo_url en $repo_dir...${CNC}"

    # Clonar el repositorio en el directorio específico
    git clone "$repo_url" "$repo_dir" > /dev/null 2>&1 && cd "$repo_dir"
    
    # Intentar compilar e instalar
    if make > /dev/null 2>&1 && sudo make install > /dev/null 2>&1; then
        echo -e "${BLD}${CGR}[✔] Instalación desde $repo_url completada.${CNC}"
    else
        echo -e "${BLD}${CRE}[✘] Error al instalar desde $repo_url.${CNC}"
    fi

    # Volver al directorio anterior y limpiar
    cd - > /dev/null && rm -rf "$repo_dir"
}


# Instalar fuentes manualmente
install_fonts() {
    echo -e "${BLD}${CBL}===== Instalando fuentes manualmente =====${CNC}"

    # Ruta de destino para las fuentes
    DESTINO="/usr/share/fonts/truetype/"

    # Verificar si la carpeta existe; si no, crearla
    if [ ! -d "$DESTINO" ]; then
        echo -e "${BLD}${CGR}[✔] Creando carpeta de fuentes en ${DESTINO}${CNC}"
        sudo mkdir -p "$DESTINO"
    fi

    # Función para manejar errores de descarga
    descargar_fuente() {
        local url=$1
        local archivo=$2
        echo -e "${BLD}${CBL}Descargando $archivo...${CNC}"
        wget -q "$url" -O "$archivo"
        if [ $? -ne 0 ] || [ ! -f "$archivo" ]; then
            echo -e "${BLD}${CGR}[✘] Error al descargar $archivo. Revisa la URL: $url${CNC}"
            return 1
        fi
        return 0
    }

    # JetBrains Mono
    descargar_fuente "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/JetBrainsMono.zip" "JetBrainsMono.zip"
    if [ $? -eq 0 ]; then
        unzip JetBrainsMono.zip -d JetBrainsMono
        sudo mv JetBrainsMono/* "$DESTINO"
        rm -rf JetBrainsMono JetBrainsMono.zip
    fi

    descargar_fuente "https://download.jetbrains.com/fonts/JetBrainsMono-2.304.zip" "JetBrainsMono2.zip"
    if [ $? -eq 0 ]; then
        unzip JetBrainsMono2.zip -d JetBrainsMono2
        sudo mv JetBrainsMono2/* "$DESTINO"
        rm -rf JetBrainsMono2 JetBrainsMono2.zip
    fi

    # Terminus Nerd Font
    descargar_fuente "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Terminus.zip" "Terminus.zip"
    if [ $? -eq 0 ]; then
        unzip Terminus.zip -d Terminus
        sudo mv Terminus/* "$DESTINO"
        rm -rf Terminus Terminus.zip
    fi

    # Ubuntu Mono Nerd Font
    descargar_fuente "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/UbuntuMono.zip" "UbuntuMono.zip"
    if [ $? -eq 0 ]; then
        unzip UbuntuMono.zip -d UbuntuMono
        sudo mv UbuntuMono/* "$DESTINO"
        rm -rf UbuntuMono UbuntuMono.zip
    fi

    # Recargar caché de fuentes
    sudo fc-cache -fv
    echo -e "${BLD}${CGR}[✔] Fuentes instaladas correctamente.${CNC}"
}


# Instalar paquetes personalizados de gh0stzk
install_custom_packages() {
    local REPO_URL="https://github.com/gh0stzk/pkgs.git"
    local CLONE_DIR="/tmp/gh0stzk_pkgs"
    local PKG_DIR="$CLONE_DIR/x86_64"

    echo -e "${BLD}${CBL}===== Instalando paquetes personalizados de gh0stzk=====${CNC}"

    # Clonar el repositorio si no está presente
    if [ ! -d "$CLONE_DIR" ]; then
        echo -e "${BLD}${CYE}[~] Clonando el repositorio $REPO_URL...${CNC}"
        git clone "$REPO_URL" "$CLONE_DIR" > /dev/null 2>&1
    else
        echo -e "${BLD}${CGR}[✔] Repositorio ya clonado.${CNC}"
    fi

    # Verificar si existe el directorio de paquetes
    if [ ! -d "$PKG_DIR" ]; then
        echo -e "${BLD}${CRE}[✘] No se encontró el directorio de paquetes en $PKG_DIR.${CNC}"
        return 1
    fi

    # Instalar las herramientas necesarias
    sudo apt update && sudo apt install -y zstd

    # Buscar e instalar los paquetes
    for package in "$PKG_DIR"/*.pkg.tar.zst; do
        if [[ -f "$package" ]]; then
            local pkg_name=$(basename "$package" | cut -d'-' -f1-3)
            if dpkg -l | grep -q "$pkg_name"; then
                echo -e "${BLD}${CGR}[✔] $pkg_name ya está instalado.${CNC}"
            else
                echo -e "${BLD}${CYE}[~] Instalando $pkg_name...${CNC}"

                # Descomprimir el paquete
                local extract_dir="/tmp/$pkg_name"
                mkdir -p "$extract_dir"
                tar --use-compress-program=zstd -xvf "$package" -C "$extract_dir" > /dev/null 2>&1

                # Mover archivos al sistema
                if [ -d "$extract_dir/usr" ]; then
                    sudo cp -r "$extract_dir/usr/"* /usr/
                    echo -e "${BLD}${CGR}[✔] $pkg_name instalado correctamente.${CNC}"
                else
                    echo -e "${BLD}${CRE}[✘] Error al instalar $pkg_name. Archivos no encontrados.${CNC}"
                fi

                # Limpiar
                rm -rf "$extract_dir"
            fi
        fi
    done
    rm -rf "$CLONE_DIR"
}

# ==============================
# LISTAS DE PAQUETES
# ==============================

apt_packages=(
    alacritty bat brightnessctl bspwm dunst eza feh firefox geany git kitty imagemagick jq
    jgmenu maim mpc mpd mpv neovim ncmpcpp npm pamixer papirus-icon-theme picom playerctl polybar
    redshift rofi rustup sxhkd tmux ueberzug webp-pixbuf-loader xclip xdg-user-dirs xdo xdotool
    xsettingsd zsh zsh-autosuggestions zsh-syntax-highlighting simple-mtpfs i3lock-color pulseaudio-utils
)

github_packages=(
    "tdrop|https://github.com/noctuid/tdrop.git"
    "xqp|https://github.com/baskerville/xqp.git"
)

# ==============================
# INSTALACIÓN
# ==============================

total_repos=${#github_packages[@]}
install_all_from_git_and_external() {
    for entry in "${github_packages[@]}"; do
        local name=$(echo "$entry" | cut -d'|' -f1)
        local repo_url=$(echo "$entry" | cut -d'|' -f2)

        # Instalar el repositorio desde Git
        install_from_git "$name" "$repo_url"
    done

    # Instalar greenclip
    local greenclip_url="https://github.com/erebe/greenclip/releases/download/v4.2/greenclip"
    local greenclip_dest="/usr/local/bin/greenclip"

    echo "Descargando greenclip desde $greenclip_url..."
    wget -q "$greenclip_url" -O "$greenclip_dest"

    if [ $? -eq 0 ]; then
        echo "Estableciendo permisos de ejecución para greenclip..."
        sudo chmod +x "$greenclip_dest"
        echo "greenclip se ha instalado correctamente en $greenclip_dest."
    else
        echo "Error al descargar greenclip. Revisa la URL y tu conexión a Internet."
    fi

    # Instalar xwinwrap
    echo "Instalando dependencias para xwinwrap..."
    sudo apt-get update
    sudo apt-get install -y xorg-dev build-essential libx11-dev x11proto-xext-dev libxrender-dev libxext-dev

    echo "Clonando y compilando xwinwrap..."
    local xwinwrap_repo="https://github.com/ujjwal96/xwinwrap.git"
    local xwinwrap_dir="/tmp/xwinwrap"

    git clone "$xwinwrap_repo" "$xwinwrap_dir" > /dev/null 2>&1
    cd "$xwinwrap_dir"

    if make > /dev/null 2>&1; then
        sudo make install > /dev/null 2>&1
        echo "xwinwrap instalado correctamente."
    else
        echo "Error al compilar xwinwrap."
    fi

    make clean > /dev/null 2>&1
    cd - > /dev/null
    rm -rf "$xwinwrap_dir"

    TEMP_DIR=$(mktemp -d)

    echo "Instalando zsh-substring-search en $TEMP_DIR"
    git clone https://github.com/zsh-users/zsh-history-substring-search "$TEMP_DIR/zsh-history-substring-search"
    cp -r "$TEMP_DIR/zsh-history-substring-search" "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search"

    echo "Instalando maple-font en $TEMP_DIR"
    git clone https://github.com/subframe7536/maple-font --depth 1 -b variable "$TEMP_DIR/maple-font"
    cd "$TEMP_DIR/maple-font" || exit
    pip install -r requirements.txt
    python build.py

    # Limpiar directorio temporal
    echo "Limpiando archivos temporales..."
    rm -rf "$TEMP_DIR"
}

install_eww(){
    echo "Instalando dependencias necesarias para Eww..."
    sudo apt-get update
    sudo apt-get install -y \
        libgtk-3-dev \
        libpango1.0-dev \
        libgdk-pixbuf-xlib-2.0-dev \
        libdbusmenu-gtk3-dev \
        libcairo2-dev \
        libglib2.0-dev \
        gcc \
        libc6-dev

    if [ $? -ne 0 ]; then
        echo "Error al instalar las dependencias. Revisa tu conexión a Internet o los paquetes."
        exit 1
    fi

    EW_DIR="/tmp/eww"
    EW_REPO="https://github.com/elkowar/eww.git"

    echo "Clonando el repositorio de Eww..."
    git clone "$EW_REPO" "$EW_DIR" > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Error al clonar el repositorio. Verifica tu conexión a Internet."
        exit 1
    fi

    echo "Compilando Eww..."
    cd "$EW_DIR"
    cargo build --release --no-default-features --features x11 > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Error durante la compilación de Eww."
        rm -rf "$EW_DIR"
        exit 1
    fi

    echo "Instalando el binario de Eww..."
    sudo chmod +x target/release/eww
    sudo cp target/release/eww /usr/local/bin/
    if [ $? -ne 0 ]; then
        echo "Error al instalar el binario de Eww."
        rm -rf "$EW_DIR"
        exit 1
    fi

    echo "Limpiando archivos temporales..."
    rm -rf "$EW_DIR"

    echo "Eww instalado correctamente en /usr/local/bin/eww."

}
echo -e "${BLD}${CBL}===== Instalando paquetes desde APT =====${CNC}"

total_packages=${#apt_packages[@]}
for i in "${!apt_packages[@]}"; do
    install_from_apt "${apt_packages[$i]}"
    progress_bar "$total_packages" "$((i + 1))"
done
echo -e "\n${BLD}${CGR}===== Instalación de paquetes APT completada =====${CNC}"

echo -e "\n${BLD}${CBL}===== Instalando paquetes desde GitHub =====${CNC}"

install_all_from_git_and_external
echo -e "\n${BLD}${CGR}===== Instalación de paquetes GitHub completada =====${CNC}"

install_fonts
install_custom_packages
install_eww

echo -e "\n${BLD}${CGR}===== Instalación completada =====${CNC}"
