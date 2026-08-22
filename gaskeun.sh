#!/usr/bin/env bash

# Lokasi backup sekarang tersimpan di dalam folder repository script ini
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$SCRIPT_DIR/Kali_macOS_Backup"

TAR_FILE="$BACKUP_DIR/kali_macos_theme.tar.gz"
DCONF_FILE="$BACKUP_DIR/gnome_settings.dconf"
PLYMOUTH_DIR="$BACKUP_DIR/plymouth_backup"
SYS_EXT_DIR="$BACKUP_DIR/system_extensions"
WALLPAPER_DIR="$BACKUP_DIR/wallpapers"
RAW_ASSETS_DIR="$BACKUP_DIR/raw_assets"
INDEX_FILE="$BACKUP_DIR/.banner_index"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
GRAY='\033[38;2;128;128;128m'
BOLD='\033[1m'
NC='\033[0m'

get_sequential_banner() {
    local BANNER_DIR="$SCRIPT_DIR/banners"

    mapfile -t BANNERS < <(
        find "$BANNER_DIR" -maxdepth 1 -type f -name "*.txt" 2>/dev/null | sort
    )

    if [ "${#BANNERS[@]}" -gt 0 ]; then
        local TOTAL="${#BANNERS[@]}"
        local CURRENT_INDEX=0

        if [ -f "$INDEX_FILE" ]; then
            CURRENT_INDEX=$(cat "$INDEX_FILE" 2>/dev/null)
            [[ "$CURRENT_INDEX" =~ ^[0-9]+$ ]] || CURRENT_INDEX=0
        fi

        cat "${BANNERS[$CURRENT_INDEX]}"

        NEXT_INDEX=$(( (CURRENT_INDEX + 1) % TOTAL ))
        mkdir -p "$BACKUP_DIR"
        echo "$NEXT_INDEX" > "$INDEX_FILE"
    fi
}

draw_banner() {
    clear

    # Daftar opsi warna acak untuk banner
    local COLORS=('\033[0;31m' '\033[0;32m' '\033[0;33m' '\033[0;34m' '\033[0;35m' '\033[0;36m' '\033[1;35m' '\033[1;36m')
    local RANDOM_COLOR="${COLORS[$RANDOM % ${#COLORS[@]}]}"

    echo -e "${RANDOM_COLOR}\c"
    get_sequential_banner
    echo -e "${NC}\c"

    echo -e "${CYAN}${BOLD}+---------------------------------------------+${NC}"
    echo -e "${CYAN}${BOLD}|               KalMacScript                  |${NC}"
    echo -e "${CYAN}${BOLD}|      macOS Theme Engine for Kali GNOME      |${NC}"
    echo -e "${CYAN}${BOLD}|---------------------------------------------|${NC}"
    echo -e "${CYAN}${BOLD}| Coded by  : OfficialMarz57                  |${NC}"
    echo -e "${CYAN}${BOLD}| TikTok    : M a r z 5 7                     |${NC}"
    echo -e "${CYAN}${BOLD}| GitHub    : https://github.com/Marz57       |${NC}"
    echo -e "${CYAN}${BOLD}| Thanks to : DevlinTeamSec                   |${NC}"
    echo -e "${CYAN}${BOLD}+---------------------------------------------+${NC}"
    echo -e "${GRAY} Terima kasih telah menggunakan script kami. Jika menemukan${NC}"
    echo -e "${GRAY} kendala atau bug, silakan hubungi kami via DM TikTok.${NC}"
    echo ""
}

do_backup() {
    draw_banner
    echo -e "${YELLOW}[*] Starting deep backup with Privacy Sanitizer...${NC}\n"
    
    mkdir -p "$BACKUP_DIR" "$PLYMOUTH_DIR" "$SYS_EXT_DIR" "$WALLPAPER_DIR" "$RAW_ASSETS_DIR"

    echo -e "${BLUE}[+]${NC} Exporting UI/Desktop Dconf Settings (Sanitized)..."
    # Hanya export konfigurasi UI, Shell, Desktop, dan Interface
    dconf dump /org/gnome/desktop/ > "$DCONF_FILE"
    dconf dump /org/gnome/shell/ >> "$DCONF_FILE"

    # PRIVACY SANITIZER (Pembersih Otomatis Data Pribadi)
    sed -i "s|$HOME|~|g" "$DCONF_FILE"
    sed -i "s|/home/[^/]*|~|g" "$DCONF_FILE"
    sed -i '/[a-zA-Z0-9._%+-]\+@[a-zA-Z0-9.-]\+\.[a-zA-Z]\{2,\}/d' "$DCONF_FILE" 2>/dev/null || true # Hapus email
    sed -i '/recent-files/d' "$DCONF_FILE" 2>/dev/null || true # Hapus history recent files
    sed -i '/online-accounts/d' "$DCONF_FILE" 2>/dev/null || true # Hapus akun online

    echo -e "${BLUE}[+]${NC} Backing up active Wallpaper..."
    BG_URI=$(gsettings get org.gnome.desktop.background picture-uri 2>/dev/null | tr -d "'")
    BG_URI_DARK=$(gsettings get org.gnome.desktop.background picture-uri-dark 2>/dev/null | tr -d "'")
    BG_PATH=$(echo "$BG_URI" | sed 's|file://||')
    BG_PATH_DARK=$(echo "$BG_URI_DARK" | sed 's|file://||')
    [ -f "$BG_PATH" ] && cp "$BG_PATH" "$WALLPAPER_DIR/"
    [ -f "$BG_PATH_DARK" ] && cp "$BG_PATH_DARK" "$WALLPAPER_DIR/"

    if [ -d "/usr/share/gnome-shell/extensions" ]; then
        echo -e "${BLUE}[+]${NC} Backing up System Extensions..."
        cp -r /usr/share/gnome-shell/extensions/* "$SYS_EXT_DIR/" 2>/dev/null || true
    fi

    echo -e "${BLUE}[+]${NC} Backing up Plymouth Theme..."
    CURRENT_PLYMOUTH=$(plymouth-set-default-theme 2>/dev/null)
    if [ -n "$CURRENT_PLYMOUTH" ]; then
        echo "$CURRENT_PLYMOUTH" > "$PLYMOUTH_DIR/current_theme.txt"
        if [ -d "/usr/share/plymouth/themes/$CURRENT_PLYMOUTH" ]; then
            sudo cp -r "/usr/share/plymouth/themes/$CURRENT_PLYMOUTH" "$PLYMOUTH_DIR/"
        fi
    fi

    echo -e "${BLUE}[+]${NC} Collecting themes, icons, fonts & user extensions..."
    cp -r ~/.themes "$RAW_ASSETS_DIR/" 2>/dev/null || true
    cp -r ~/.icons "$RAW_ASSETS_DIR/" 2>/dev/null || true
    cp -r ~/.local/share/themes "$RAW_ASSETS_DIR/" 2>/dev/null || true
    cp -r ~/.local/share/icons "$RAW_ASSETS_DIR/" 2>/dev/null || true
    cp -r ~/.local/share/gnome-shell/extensions "$RAW_ASSETS_DIR/" 2>/dev/null || true
    cp -r ~/.local/share/fonts "$RAW_ASSETS_DIR/" 2>/dev/null || true
    cp -r ~/.config/gtk-3.0 "$RAW_ASSETS_DIR/" 2>/dev/null || true
    cp -r ~/.config/gtk-4.0 "$RAW_ASSETS_DIR/" 2>/dev/null || true

    tar -czf "$TAR_FILE" -C "$RAW_ASSETS_DIR" . 2>/dev/null

    echo ""
    echo -e "${GREEN}${BOLD}+---------------------------------------------+${NC}"
    echo -e "${GREEN}${BOLD}|      BACKUP & PRIVACY CLEANUP COMPLETED     |${NC}"
    echo -e "${GREEN}${BOLD}+---------------------------------------------+${NC}"
    echo -e "${CYAN}Path : $BACKUP_DIR${NC}"
    echo -e "${CYAN}Size : $(du -h "$TAR_FILE" 2>/dev/null | cut -f1)${NC}\n"
}

do_restore() {
    draw_banner
    if [ ! -d "$BACKUP_DIR" ]; then
        echo -e "${RED}[!] ERROR: Backup directory not found!${NC}\n"
        exit 1
    fi

    echo -e "${YELLOW}[*] Starting restore engine...${NC}\n"

    if [ -f "$TAR_FILE" ]; then
        echo -e "${BLUE}[+]${NC} Extracting theme archive to home..."
        tar -xzf "$TAR_FILE" -C "$HOME"
    elif [ -d "$RAW_ASSETS_DIR" ]; then
        echo -e "${BLUE}[+]${NC} Copying raw assets to home..."
        cp -r "$RAW_ASSETS_DIR"/* "$HOME/" 2>/dev/null || true
    fi

    echo -e "${BLUE}[+]${NC} Compiling schemas & setting permissions..."
    chmod -R 755 ~/.local/share/gnome-shell/extensions/ 2>/dev/null || true
    for dir in ~/.local/share/gnome-shell/extensions/*/; do
        if [ -d "${dir}schemas" ]; then
            glib-compile-schemas "${dir}schemas" 2>/dev/null || true
        fi
    done

    if [ -d "$SYS_EXT_DIR" ] && [ "$(ls -A "$SYS_EXT_DIR")" ]; then
        echo -e "${BLUE}[+]${NC} Restoring system-wide extensions..."
        sudo cp -r "$SYS_EXT_DIR"/* /usr/share/gnome-shell/extensions/ 2>/dev/null || true
    fi

    if [ -f "$DCONF_FILE" ]; then
        echo -e "${BLUE}[+]${NC} Applying Dconf configuration..."
        dconf load /org/gnome/ < "$DCONF_FILE"
    fi

    if [ -d "$WALLPAPER_DIR" ] && [ "$(ls -A "$WALLPAPER_DIR")" ]; then
        echo -e "${BLUE}[+]${NC} Restoring wallpaper settings..."
        mkdir -p "$HOME/Pictures"
        cp "$WALLPAPER_DIR"/* "$HOME/Pictures/" 2>/dev/null || true
        FIRST_WP=$(ls "$WALLPAPER_DIR" | head -n 1)
        if [ -n "$FIRST_WP" ]; then
            WP_URI="file://$HOME/Pictures/$FIRST_WP"
            gsettings set org.gnome.desktop.background picture-uri "$WP_URI"
            gsettings set org.gnome.desktop.background picture-uri-dark "$WP_URI"
        fi
    fi

    if [ -f "$PLYMOUTH_DIR/current_theme.txt" ]; then
        echo -e "${BLUE}[+]${NC} Restoring Plymouth boot theme..."
        THEME_NAME=$(cat "$PLYMOUTH_DIR/current_theme.txt")
        if [ -d "$PLYMOUTH_DIR/$THEME_NAME" ]; then
            sudo cp -r "$PLYMOUTH_DIR/$THEME_NAME" /usr/share/plymouth/themes/
            sudo plymouth-set-default-theme -R "$THEME_NAME"
            echo -e "${BLUE}[+]${NC} Updating initramfs..."
            sudo update-initramfs -u 2>/dev/null || true
        fi
    fi

    gsettings set org.gnome.shell disable-user-extensions false

    echo ""
    echo -e "${GREEN}${BOLD}+---------------------------------------------+${NC}"
    echo -e "${GREEN}${BOLD}|           RESTORE COMPLETED 100%            |${NC}"
    echo -e "${GREEN}${BOLD}+---------------------------------------------+${NC}"
    echo -e "${YELLOW}[!] NOTICE: Please REBOOT / LOGOUT your system!${NC}\n"
}

main_menu() {
    while true; do
        draw_banner
        echo -e "${BOLD}Select Operation:${NC}"
        echo -e " ${CYAN}[1]${NC} Backup macOS Theme"
        echo -e " ${CYAN}[2]${NC} Restore macOS Theme"
        echo -e " ${CYAN}[3]${NC} Switch Banner"
        echo -e " ${CYAN}[4]${NC} Exit"
        echo ""
        read -p "Option [1-4]: " opt

        case $opt in
            1) do_backup; break ;;
            2) do_restore; break ;;
            3) continue ;;
            4) exit 0 ;;
            *) echo -e "${RED}Invalid option!${NC}"; sleep 1 ;;
        esac
    done
}

main_menu
