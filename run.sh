#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$SCRIPT_DIR/Kali_macOS_Backup"

TAR_FILE="$BACKUP_DIR/kali_macos_theme.tar.gz"
DCONF_FILE="$BACKUP_DIR/gnome_settings.dconf"
PLYMOUTH_DIR="$BACKUP_DIR/plymouth_backup"
SYS_EXT_DIR="$BACKUP_DIR/system_extensions"
WALLPAPER_DIR="$BACKUP_DIR/wallpapers"
RAW_ASSETS_DIR="$BACKUP_DIR/raw_assets"
INDEX_FILE="$BACKUP_DIR/.banner_index"
ROLLBACK_DIR="/tmp/kalmac_rollback_snapshot"

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

show_loading() {
    local text="$1"
    local delay=0.08
    local spinstr='|/-\'
    echo -e -n "${YELLOW}[*] $text ${NC}"
    for i in {1..15}; do
        local temp=${spinstr#?}
        printf " [%c] " "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b"
    done
    echo -e " ${GREEN}[OK]${NC}"
}

pause_to_menu() {
    echo ""
    read -p "Tekan [Enter] untuk kembali ke menu utama..."
}

# 1. Menampilkan Info OS & Session dengan Animasi (Termasuk FITUR 2: DETEKSI VERSI GNOME)
show_system_info() {
    echo -e "${CYAN}${BOLD}[i] INFORMASI SISTEM PENGGUNA${NC}"
    
    local OS_NAME="Linux (Unknown)"
    if [ -f /etc/os-release ]; then
        OS_NAME=$(grep -E '^PRETTY_NAME=' /etc/os-release | cut -d'=' -f2 | tr -d '"')
    fi
    
    local SESSION_TYPE="${XDG_SESSION_TYPE:-Unknown}"
    local CURRENT_DE="${XDG_CURRENT_DESKTOP:-$DESKTOP_SESSION}"
    
    if [ -z "$CURRENT_DE" ] && pgrep -x "gnome-shell" &>/dev/null; then
        CURRENT_DE="GNOME (Detected via Process)"
    fi

    # FITUR 2: Ambil Versi GNOME Shell
    local GNOME_VER="Unknown"
    if command -v gnome-shell &>/dev/null; then
        GNOME_VER=$(gnome-shell --version 2>/dev/null | awk '{print $3}')
    fi

    show_loading "Mendeteksi Distro OS........ [$OS_NAME]"
    show_loading "Mendeteksi Session Type..... [$SESSION_TYPE]"
    show_loading "Mendeteksi Desktop Env...... [${CURRENT_DE:-Unknown}]"
    show_loading "Mendeteksi Versi GNOME...... [GNOME $GNOME_VER]"
    echo ""
}

# Package Manager Universal Check
install_missing_packages() {
    local pkgs=("$@")
    echo -e "${BLUE}[+]${NC} Mendeteksi Manajer Paket Sistem..."

    if command -v apt-get &>/dev/null; then
        sudo apt-get update && sudo apt-get install -y "${pkgs[@]}"
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y "${pkgs[@]}"
    elif command -v pacman &>/dev/null; then
        sudo pacman -Sy --noconfirm "${pkgs[@]}"
    elif command -v zypper &>/dev/null; then
        sudo zypper install -y "${pkgs[@]}"
    else
        echo -e "${RED}[!] Manajer paket tidak dikenali. Silakan pasang manual: ${pkgs[*]}${NC}"
        return 1
    fi
}

check_dependencies() {
    echo -e "${BLUE}[+]${NC} Checking system dependencies..."
    local MISSING_PKGS=()

    command -v dconf &>/dev/null || MISSING_PKGS+=("dconf-cli")
    command -v glib-compile-schemas &>/dev/null || MISSING_PKGS+=("libglib2.0-bin")
    
    if ! command -v plymouth-set-default-theme &>/dev/null && ! command -v plymouth &>/dev/null; then
        MISSING_PKGS+=("plymouth" "plymouth-themes")
    fi

    if [ "${#MISSING_PKGS[@]}" -gt 0 ]; then
        echo -e "${YELLOW}[!] Paket yang dibutuhkan belum terinstall: ${MISSING_PKGS[*]}${NC}"
        read -p "Apakah Anda ingin memasang dependensi otomatis? (y/n): " dep_confirm
        if [[ "$dep_confirm" =~ ^[Yy]$ ]]; then
            install_missing_packages "${MISSING_PKGS[@]}"
        else
            echo -e "${RED}[!] Dependensi wajib tidak terpenuhi. Operasi dibatalkan.${NC}"
            pause_to_menu
            return 1
        fi
    fi
}

# Pengecekan Folder Komponen Utama Sebelum Replace
check_and_prepare_folders() {
    echo -e "${CYAN}${BOLD}[+] MEMERIKSA DAN MENYIAPKAN FOLDER TUJUAN RESTORE${NC}"

    local REQUIRED_FOLDERS=(
        "$HOME/.themes"
        "$HOME/.icons"
        "$HOME/.local/share/themes"
        "$HOME/.local/share/icons"
        "$HOME/.local/share/gnome-shell/extensions"
        "$HOME/.local/share/fonts"
        "$HOME/.config/gtk-3.0"
        "$HOME/.config/gtk-4.0"
        "$HOME/Pictures"
    )

    local MISSING_FOLDERS=()

    for folder in "${REQUIRED_FOLDERS[@]}"; do
        show_loading "Memeriksa folder: $folder"
        if [ ! -d "$folder" ]; then
            MISSING_FOLDERS+=("$folder")
        fi
    done

    local PLYMOUTH_SYS_DIR="/usr/share/plymouth/themes"
    [ -d "/etc/plymouth" ] && PLYMOUTH_SYS_DIR="/usr/share/plymouth/themes"
    
    show_loading "Memeriksa folder Plymouth Sistem [$PLYMOUTH_SYS_DIR]"
    if [ ! -d "$PLYMOUTH_SYS_DIR" ]; then
        MISSING_FOLDERS+=("$PLYMOUTH_SYS_DIR")
    fi

    echo ""
    if [ "${#MISSING_FOLDERS[@]}" -gt 0 ]; then
        echo -e "${YELLOW}[!] Ditemukan beberapa folder komponen yang belum ada di sistem kamu:${NC}"
        for missing in "${MISSING_FOLDERS[@]}"; do
            echo -e "    ${RED}- $missing${NC}"
        done
        echo ""
        echo -e " ${CYAN}[1]${NC} Buat folder yang belum ada secara otomatis"
        echo -e " ${CYAN}[2]${NC} Batalkan Restore & Kembali ke Menu Utama"
        echo ""
        read -p "Pilihan [1-2]: " folder_opt

        if [ "$folder_opt" == "1" ]; then
            echo -e "${BLUE}[+] Membuat folder yang dibutuhkan...${NC}"
            for missing in "${MISSING_FOLDERS[@]}"; do
                if [[ "$missing" == /usr/* ]] || [[ "$missing" == /etc/* ]]; then
                    sudo mkdir -p "$missing" 2>/dev/null
                else
                    mkdir -p "$missing" 2>/dev/null
                fi
            done
            echo -e "${GREEN}[+] Semua folder berhasil dibuat!${NC}\n"
        else
            echo -e "${RED}[!] Operasi restore dibatalkan oleh pengguna.${NC}"
            return 1
        fi
    else
        echo -e "${GREEN}[OK] Semua folder komponen tujuan sudah lengkap & siap di-replace!${NC}\n"
    fi
    return 0
}

# FITUR 3: LIBADWAITA / GTK4 AUTO-PATCHER (Memaksa aplikasi GTK4 memakai tema macOS)
patch_libadwaita_gtk4() {
    echo -e "${BLUE}[+]${NC} Applying Libadwaita / GTK4 macOS theme patch..."
    mkdir -p ~/.config/gtk-4.0

    # Mencari file gtk.css tema macOS yang sedang aktif
    local ACTIVE_THEME
    ACTIVE_THEME=$(gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null | tr -d "'")

    local THEME_GTK4_CSS=""
    if [ -f "$HOME/.themes/$ACTIVE_THEME/gtk-4.0/gtk.css" ]; then
        THEME_GTK4_CSS="$HOME/.themes/$ACTIVE_THEME/gtk-4.0/gtk.css"
    elif [ -f "$HOME/.local/share/themes/$ACTIVE_THEME/gtk-4.0/gtk.css" ]; then
        THEME_GTK4_CSS="$HOME/.local/share/themes/$ACTIVE_THEME/gtk-4.0/gtk.css"
    fi

    if [ -n "$THEME_GTK4_CSS" ]; then
        cp -f "$THEME_GTK4_CSS" ~/.config/gtk-4.0/gtk.css 2>/dev/null
        [ -f "$(dirname "$THEME_GTK4_CSS")/gtk-dark.css" ] && cp -f "$(dirname "$THEME_GTK4_CSS")/gtk-dark.css" ~/.config/gtk-4.0/gtk-dark.css 2>/dev/null
        [ -d "$(dirname "$THEME_GTK4_CSS")/assets" ] && cp -rf "$(dirname "$THEME_GTK4_CSS")/assets" ~/.config/gtk-4.0/ 2>/dev/null
        echo -e "${GREEN}[+] Patch GTK4 Libadwaita berhasil diterapkan!${NC}"
    else
        echo -e "${GRAY}[*] Aset GTK4 tema tidak ditemukan, melewati patch Libadwaita.${NC}"
    fi
}

create_rollback_snapshot() {
    echo -e "${BLUE}[+]${NC} Creating safety rollback snapshot..."
    rm -rf "$ROLLBACK_DIR"
    mkdir -p "$ROLLBACK_DIR"
    dconf dump /org/gnome/ > "$ROLLBACK_DIR/snapshot_settings.dconf"
    echo -e "${GREEN}[+] Rollback snapshot tersimpan di $ROLLBACK_DIR${NC}"
}

do_rollback() {
    draw_banner
    if [ ! -f "$ROLLBACK_DIR/snapshot_settings.dconf" ]; then
        echo -e "${RED}[!] ERROR: Snapshot rollback tidak ditemukan!${NC}\n"
        pause_to_menu
        return 1
    fi

    echo -e "${YELLOW}[*] Restoring original system state from snapshot...${NC}\n"
    dconf load /org/gnome/ < "$ROLLBACK_DIR/snapshot_settings.dconf" 2>/dev/null
    echo -e "${GREEN}${BOLD}[+] Tampilan sistem berhasil dikembalikan ke keadaan sebelum restore!${NC}\n"
    pause_to_menu
}

do_dry_run() {
    draw_banner
    show_system_info
    echo -e "${YELLOW}[*] Running System Simulation Mode (Dry Run)...${NC}\n"

    check_dependencies || return

    echo -e "${BLUE}[+]${NC} Checking backup directory..."
    if [ ! -d "$BACKUP_DIR" ]; then
        echo -e "${RED}[!] FAIL: Backup directory ($BACKUP_DIR) tidak ditemukan!${NC}"
    else
        echo -e "${GREEN}[OK] Directory backup ditemukan.${NC}"
    fi

    echo -e "${BLUE}[+]${NC} Checking archive integrity..."
    if [ -f "$TAR_FILE" ]; then
        if tar -tzf "$TAR_FILE" &>/dev/null; then
            echo -e "${GREEN}[OK] File tar.gz valid dan dapat diekstrak.${NC}"
        else
            echo -e "${RED}[!] FAIL: File tar.gz mengalami kerusakan (corrupt)!${NC}"
        fi
    fi

    echo -e "${BLUE}[+]${NC} Checking dconf configuration file..."
    if [ -f "$DCONF_FILE" ]; then
        echo -e "${GREEN}[OK] File dconf tersedia.${NC}"
    else
        echo -e "${YELLOW}[!] WARNING: File dconf settings tidak ditemukan.${NC}"
    fi

    echo ""
    show_loading "Menganalisis hasil simulasi..."
    sleep 1

    echo -e "\n${GREEN}${BOLD}[+] SIMULASI SELESAI. Sistem siap untuk operasi Restore asli!${NC}\n"
    pause_to_menu
}

auto_fix_dash_to_dock() {
    echo -e "${BLUE}[+]${NC} Configuring & Auto-Fixing Dash to Dock..."
    gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM' 2>/dev/null || true
    gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false 2>/dev/null || true
    gsettings set org.gnome.shell.extensions.dash-to-dock transparency-mode 'DYNAMIC' 2>/dev/null || true
    gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 48 2>/dev/null || true
}

handle_restore_error() {
    local STEP_NAME="$1"
    echo -e "\n${RED}${BOLD}[!] ERROR CRITICAL:${NC} ${RED}Gagal pada proses: ${STEP_NAME}${NC}"
    echo -e "${YELLOW}[?] Proses restore mengalami kendala yang dapat membuat tampilan tidak sempurna.${NC}"
    echo -e " ${CYAN}[1]${NC} Tetap Lanjutkan Restore (Abaikan Error)"
    echo -e " ${CYAN}[2]${NC} Batalkan & Batalkan Perubahan (Kembali ke Semula)"
    echo ""
    read -p "Pilihan [1-2]: " err_opt
    case $err_opt in
        1)
            echo -e "${YELLOW}[*] Melanjutkan proses restore dengan potensi kerugian tampilan...${NC}\n"
            return 0
            ;;
        *)
            echo -e "${RED}[!] Membatalkan proses restore dan mengembalikan keadaan semula...${NC}"
            do_rollback
            ;;
    esac
}

do_backup() {
    draw_banner
    show_system_info
    check_dependencies || return
    echo -e "${YELLOW}[*] Starting deep backup with Privacy Sanitizer...${NC}\n"
    
    mkdir -p "$BACKUP_DIR" "$PLYMOUTH_DIR" "$SYS_EXT_DIR" "$WALLPAPER_DIR" "$RAW_ASSETS_DIR"

    echo -e "${BLUE}[+]${NC} Exporting UI/Desktop Dconf Settings (Sanitized)..."
    dconf dump /org/gnome/desktop/ > "$DCONF_FILE"
    dconf dump /org/gnome/shell/ >> "$DCONF_FILE"

    sed -i "s|$HOME|~|g" "$DCONF_FILE"
    sed -i "s|/home/[^/]*|~|g" "$DCONF_FILE"
    sed -i '/[a-zA-Z0-9._%+-]\+@[a-zA-Z0-9.-]\+\.[a-zA-Z]\{2,\}/d' "$DCONF_FILE" 2>/dev/null || true
    sed -i '/recent-files/d' "$DCONF_FILE" 2>/dev/null || true
    sed -i '/online-accounts/d' "$DCONF_FILE" 2>/dev/null || true

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
    CURRENT_PLYMOUTH=""
    if command -v plymouth-set-default-theme &>/dev/null; then
        CURRENT_PLYMOUTH=$(plymouth-set-default-theme 2>/dev/null)
    fi
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

    pause_to_menu
}

do_restore() {
    draw_banner
    show_system_info
    check_dependencies || return

    if [ ! -d "$BACKUP_DIR" ]; then
        echo -e "${RED}[!] ERROR: Backup directory not found!${NC}\n"
        pause_to_menu
        return 1
    fi

    CURRENT_DE="${XDG_CURRENT_DESKTOP:-$DESKTOP_SESSION}"
    if [ -z "$CURRENT_DE" ]; then
        if pgrep -x "gnome-shell" &>/dev/null; then
            CURRENT_DE="GNOME"
        fi
    fi

    if [[ ! "$(echo "$CURRENT_DE" | tr '[:upper:]' '[:lower:]')" =~ gnome ]]; then
        echo -e "${RED}[!] ERROR: Incompatible Desktop Environment!${NC}"
        echo -e "${RED}Backup dibuat untuk GNOME Desktop, sedangkan sistem kamu menggunakan: ${YELLOW}${CURRENT_DE:-Unknown}${NC}"
        echo -e "${RED}Proses restore dibatalkan otomatis demi menjaga keamanan sistem.${NC}\n"
        pause_to_menu
        return 1
    fi

    check_and_prepare_folders || { pause_to_menu; return 1; }

    create_rollback_snapshot

    echo -e "${YELLOW}[*] Starting restore engine...${NC}\n"

    if [ -f "$TAR_FILE" ]; then
        echo -e "${BLUE}[+]${NC} Extracting theme archive to home..."
        if ! tar -xzf "$TAR_FILE" -C "$HOME" 2>/dev/null; then
            handle_restore_error "Ekstraksi Arsip Tema (tar.gz)"
        fi
    elif [ -d "$RAW_ASSETS_DIR" ]; then
        echo -e "${BLUE}[+]${NC} Copying raw assets to home..."
        if ! cp -r "$RAW_ASSETS_DIR"/* "$HOME/" 2>/dev/null; then
            handle_restore_error "Salin Aset Mentah (raw_assets)"
        fi
    fi

    echo -e "${BLUE}[+]${NC} Compiling schemas & setting permissions..."
    chmod -R 755 ~/.local/share/gnome-shell/extensions/ 2>/dev/null || true
    for dir in ~/.local/share/gnome-shell/extensions/*/; do
        if [ -d "${dir}schemas" ]; then
            glib-compile-schemas "${dir}schemas" 2>/dev/null || true
        fi
    done

    if [ -d "$SYS_EXT_DIR" ] && [ "$(ls -A "$SYS_EXT_DIR" 2>/dev/null)" ]; then
        echo -e "${BLUE}[+]${NC} Restoring system-wide extensions..."
        if ! sudo cp -r "$SYS_EXT_DIR"/* /usr/share/gnome-shell/extensions/ 2>/dev/null; then
            handle_restore_error "Restorasi Ekstensi Sistem"
        fi
    else
        echo -e "${GRAY}[*] Tidak ada ekstensi sistem untuk direstore, melewatinya...${NC}"
    fi

    if [ -f "$DCONF_FILE" ]; then
        echo -e "${BLUE}[+]${NC} Applying Dconf configuration..."
        if ! dconf load /org/gnome/ < "$DCONF_FILE" 2>/dev/null; then
            handle_restore_error "Penerapan Konfigurasi Dconf"
        fi
    fi

    auto_fix_dash_to_dock

    if [ -d "$WALLPAPER_DIR" ] && [ "$(ls -A "$WALLPAPER_DIR")" ]; then
        echo -e "${BLUE}[+]${NC} Restoring wallpaper settings..."
        mkdir -p "$HOME/Pictures"
        cp "$WALLPAPER_DIR"/* "$HOME/Pictures/" 2>/dev/null || true
        FIRST_WP=$(ls "$WALLPAPER_DIR" | head -n 1)
        if [ -n "$FIRST_WP" ]; then
            WP_URI="file://$HOME/Pictures/$FIRST_WP"
            gsettings set org.gnome.desktop.background picture-uri "$WP_URI" 2>/dev/null || true
            gsettings set org.gnome.desktop.background picture-uri-dark "$WP_URI" 2>/dev/null || true
        fi
    fi

    if [ -f "$PLYMOUTH_DIR/current_theme.txt" ]; then
        echo ""
        echo -e "${YELLOW}[?] Konfirmasi Restorasi Tema Plymouth Booting:${NC}"
        echo -e " ${CYAN}[1]${NC} Ya, ganti tema Plymouth dengan hasil backup"
        echo -e " ${CYAN}[2]${NC} Tidak, biarkan tema Plymouth bawaan/normal"
        echo ""
        read -p "Pilihan Plymouth [1-2]: " ply_opt

        if [ "$ply_opt" == "1" ]; then
            echo -e "${BLUE}[+]${NC} Restoring Plymouth boot theme..."
            THEME_NAME=$(cat "$PLYMOUTH_DIR/current_theme.txt")
            if [ -d "$PLYMOUTH_DIR/$THEME_NAME" ]; then
                if ! sudo cp -r "$PLYMOUTH_DIR/$THEME_NAME" /usr/share/plymouth/themes/ 2>/dev/null; then
                    handle_restore_error "Salin Tema Plymouth"
                else
                    sudo plymouth-set-default-theme -R "$THEME_NAME" 2>/dev/null || true
                    echo -e "${BLUE}[+]${NC} Updating initramfs..."
                    if command -v update-initramfs &>/dev/null; then
                        sudo update-initramfs -u 2>/dev/null || true
                    elif command -v dracut &>/dev/null; then
                        sudo dracut --regenerate-all --force 2>/dev/null || true
                    elif command -v mkinitcpio &>/dev/null; then
                        sudo mkinitcpio -P 2>/dev/null || true
                    fi
                fi
            fi
        else
            echo -e "${GRAY}[*] Melewati restorasi tema Plymouth...${NC}"
        fi
    fi

    # FITUR 1: BYPASS CEK VERSI EKSTENSI (Mencegah ekstensi disable otomatis saat beda versi GNOME)
    echo -e "${BLUE}[+]${NC} Bypassing GNOME extension version validation..."
    gsettings set org.gnome.shell disable-extension-version-validation true 2>/dev/null || true
    gsettings set org.gnome.shell disable-user-extensions false 2>/dev/null || true

    # FITUR 3: PENERAPAN PATCH LIBADWAITA GTK4
    patch_libadwaita_gtk4

    echo ""
    echo -e "${GREEN}${BOLD}+---------------------------------------------+${NC}"
    echo -e "${GREEN}${BOLD}|           RESTORE COMPLETED 100%            |${NC}"
    echo -e "${GREEN}${BOLD}+---------------------------------------------+${NC}"
    echo -e "${YELLOW}[!] NOTICE: Please REBOOT / LOGOUT your system!${NC}\n"

    pause_to_menu
}

main_menu() {
    while true; do
        draw_banner
        echo -e "${BOLD}Select Operation:${NC}"
        echo -e " ${CYAN}[1]${NC} Backup macOS Theme"
        echo -e " ${CYAN}[2]${NC} Restore macOS Theme"
        echo -e " ${CYAN}[3]${NC} Dry Run (Simulation Mode)"
        echo -e " ${CYAN}[4]${NC} Undo Restore (Revert to Original State)"
        echo -e " ${CYAN}[5]${NC} Switch Banner"
        echo -e " ${CYAN}[6]${NC} Exit"
        echo ""
        read -p "Option [1-6]: " opt

        case $opt in
            1) do_backup ;;
            2) do_restore ;;
            3) do_dry_run ;;
            4) do_rollback ;;
            5) continue ;;
            6) 
               echo -e "\n${GREEN}Terima kasih telah menggunakan KalMacScript! Bye...${NC}\n"
               exit 0 
               ;;
            *) 
               echo -e "${RED}Invalid option!${NC}"
               sleep 1 
               ;;
        esac
    done
}

main_menu
