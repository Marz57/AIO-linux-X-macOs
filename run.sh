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
    echo -e "${CYAN}${BOLD}|   macOS Theme Engine for Debian/GNOME Family|${NC}"
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
    local delay=0.06
    local spinstr='|/-\'
    echo -e -n "${YELLOW}[*] $text ${NC}"
    for i in {1..12}; do
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

# 1. Pengecekan OS Khusus Turunan Debian
check_debian_family() {
    if [ -f /etc/os-release ]; then
        if ! grep -qiE 'debian|ubuntu|kali|mint|pop|zorin' /etc/os-release; then
            echo -e "${RED}[!] ERROR: Script ini dikhususkan untuk distro turunan Debian/Ubuntu!${NC}"
            echo -e "${RED}Distro kamu tidak terdeteksi berbasis Debian. Operasi dihentikan.${NC}\n"
            return 1
        fi
    fi
    return 0
}

# 2. Informas Sistem & Session
show_system_info() {
    echo -e "${CYAN}${BOLD}[i] INFORMASI SISTEM PENGGUNA${NC}"
    
    local OS_NAME="Linux (Debian-based)"
    if [ -f /etc/os-release ]; then
        OS_NAME=$(grep -E '^PRETTY_NAME=' /etc/os-release | cut -d'=' -f2 | tr -d '"')
    fi
    
    local SESSION_TYPE="${XDG_SESSION_TYPE:-Unknown}"
    local CURRENT_DE="${XDG_CURRENT_DESKTOP:-$DESKTOP_SESSION}"
    
    if [ -z "$CURRENT_DE" ] && pgrep -x "gnome-shell" &>/dev/null; then
        CURRENT_DE="GNOME (Detected via Process)"
    fi

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

# 3. Manajer Paket Khusus APT (Debian/Ubuntu/Kali)
check_dependencies() {
    echo -e "${BLUE}[+]${NC} Memeriksa dependensi sistem (APT)..."
    local MISSING_PKGS=()

    command -v dconf &>/dev/null || MISSING_PKGS+=("dconf-cli")
    command -v glib-compile-schemas &>/dev/null || MISSING_PKGS+=("libglib2.0-bin")
    
    if ! command -v plymouth-set-default-theme &>/dev/null && ! command -v plymouth &>/dev/null; then
        MISSING_PKGS+=("plymouth" "plymouth-themes")
    fi

    if [ "${#MISSING_PKGS[@]}" -gt 0 ]; then
        echo -e "${YELLOW}[!] Paket wajib belum terpasang: ${MISSING_PKGS[*]}${NC}"
        read -p "Pasang dependensi secara otomatis via APT? (y/n): " dep_confirm
        if [[ "$dep_confirm" =~ ^[Yy]$ ]]; then
            sudo apt-get update && sudo apt-get install -y "${MISSING_PKGS[@]}"
        else
            echo -e "${RED}[!] Dependensi tidak lengkap. Operasi dibatalkan.${NC}"
            return 1
        fi
    fi
    return 0
}

# 4. Pengecekan Folder Komponen Utama
check_and_prepare_folders() {
    echo -e "${CYAN}${BOLD}[+] MEMERIKSA FOLDER KOMPONEN TUJUAN${NC}"

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
    show_loading "Memeriksa folder Plymouth Sistem [$PLYMOUTH_SYS_DIR]"
    if [ ! -d "$PLYMOUTH_SYS_DIR" ]; then
        MISSING_FOLDERS+=("$PLYMOUTH_SYS_DIR")
    fi

    echo ""
    if [ "${#MISSING_FOLDERS[@]}" -gt 0 ]; then
        echo -e "${YELLOW}[!] Folder komponen berikut belum ada di sistem kamu:${NC}"
        for missing in "${MISSING_FOLDERS[@]}"; do
            echo -e "    ${RED}- $missing${NC}"
        done
        echo ""
        echo -e " ${CYAN}[1]${NC} Buat semua folder otomatis (Rekomendasi)"
        echo -e " ${CYAN}[2]${NC} Batalkan Restore & Kembali ke Menu"
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
            echo -e "${GREEN}[+] Semua folder siap!${NC}\n"
        else
            echo -e "${RED}[!] Restorasi dibatalkan oleh pengguna.${NC}"
            return 1
        fi
    else
        echo -e "${GREEN}[OK] Seluruh folder komponen tujuan sudah lengkap!${NC}\n"
    fi
    return 0
}

# 5. Patch Presisi Libadwaita / GTK4
patch_libadwaita_gtk4() {
    echo -e "${BLUE}[+]${NC} Menilai & Menerapkan Patch GTK4 Libadwaita..."
    mkdir -p ~/.config/gtk-4.0

    local MACOS_GTK4_CSS
    MACOS_GTK4_CSS=$(find "$HOME/.themes" "$HOME/.local/share/themes" -type f -path "*/gtk-4.0/gtk.css" 2>/dev/null | head -n 1)

    if [ -n "$MACOS_GTK4_CSS" ]; then
        cp -f "$MACOS_GTK4_CSS" ~/.config/gtk-4.0/gtk.css 2>/dev/null
        local DIR_PATH
        DIR_PATH=$(dirname "$MACOS_GTK4_CSS")
        [ -f "$DIR_PATH/gtk-dark.css" ] && cp -f "$DIR_PATH/gtk-dark.css" ~/.config/gtk-4.0/gtk-dark.css 2>/dev/null
        [ -d "$DIR_PATH/assets" ] && cp -rf "$DIR_PATH/assets" ~/.config/gtk-4.0/ 2>/dev/null
        echo -e "${GREEN}[+] Patch GTK4 Libadwaita berhasil diterapkan!${NC}"
    else
        echo -e "${GRAY}[*] Berkas GTK4 tema macOS tidak ditemukan, melewati patch.${NC}"
    fi
}

create_rollback_snapshot() {
    echo -e "${BLUE}[+]${NC} Membuat snapshot rollback keamanan..."
    rm -rf "$ROLLBACK_DIR"
    mkdir -p "$ROLLBACK_DIR"
    dconf dump /org/gnome/ > "$ROLLBACK_DIR/snapshot_settings.dconf"
    echo -e "${GREEN}[+] Snapshot rollback tersimpan di $ROLLBACK_DIR${NC}"
}

do_rollback() {
    draw_banner
    if [ ! -f "$ROLLBACK_DIR/snapshot_settings.dconf" ]; then
        echo -e "${RED}[!] ERROR: Snapshot rollback tidak ditemukan!${NC}\n"
        pause_to_menu
        return 1
    fi

    echo -e "${YELLOW}[*] Mengembalikan tampilan ke posisi semula sebelum restore...${NC}\n"
    dconf load /org/gnome/ < "$ROLLBACK_DIR/snapshot_settings.dconf" 2>/dev/null
    echo -e "${GREEN}${BOLD}[+] Tampilan berhasil dikembalikan ke keadaan awal!${NC}\n"
    pause_to_menu
}

do_dry_run() {
    draw_banner
    check_debian_family || { pause_to_menu; return 1; }
    show_system_info
    echo -e "${YELLOW}[*] Menjalankan Mode Simulasi (Dry Run)...${NC}\n"

    check_dependencies || { pause_to_menu; return 1; }

    echo -e "${BLUE}[+]${NC} Memeriksa direktori backup..."
    if [ ! -d "$BACKUP_DIR" ]; then
        echo -e "${RED}[!] FAIL: Folder backup ($BACKUP_DIR) tidak ditemukan!${NC}"
    else
        echo -e "${GREEN}[OK] Folder backup ditemukan.${NC}"
    fi

    echo -e "${BLUE}[+]${NC} Memeriksa integritas arsip..."
    if [ -f "$TAR_FILE" ]; then
        if tar -tzf "$TAR_FILE" &>/dev/null; then
            echo -e "${GREEN}[OK] File tar.gz valid dan dapat diekstrak.${NC}"
        else
            echo -e "${RED}[!] FAIL: File tar.gz mengalami kerusakan (corrupt)!${NC}"
        fi
    fi

    echo -e "${BLUE}[+]${NC} Memeriksa berkas konfigurasi dconf..."
    if [ -f "$DCONF_FILE" ]; then
        echo -e "${GREEN}[OK] File dconf tersedia.${NC}"
    else
        echo -e "${YELLOW}[!] WARNING: File dconf tidak ditemukan.${NC}"
    fi

    echo ""
    show_loading "Menganalisis simulasi..."
    sleep 0.5

    echo -e "\n${GREEN}${BOLD}[+] SIMULASI SELESAI. Sistem siap untuk Restore!${NC}\n"
    pause_to_menu
}

auto_fix_dash_to_dock() {
    echo -e "${BLUE}[+]${NC} Mengonfigurasi Dash to Dock..."
    gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM' 2>/dev/null || true
    gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false 2>/dev/null || true
    gsettings set org.gnome.shell.extensions.dash-to-dock transparency-mode 'DYNAMIC' 2>/dev/null || true
    gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 48 2>/dev/null || true
}

handle_restore_error() {
    local STEP_NAME="$1"
    echo -e "\n${RED}${BOLD}[!] ERROR CRITICAL:${NC} ${RED}Gagal pada proses: ${STEP_NAME}${NC}"
    echo -e " ${CYAN}[1]${NC} Tetap Lanjutkan Restore"
    echo -e " ${CYAN}[2]${NC} Batalkan & Undo Perubahan"
    echo ""
    read -p "Pilihan [1-2]: " err_opt
    case $err_opt in
        1)
            return 0
            ;;
        *)
            do_rollback
            ;;
    esac
}

do_backup() {
    draw_banner
    check_debian_family || { pause_to_menu; return 1; }
    show_system_info
    check_dependencies || { pause_to_menu; return 1; }
    
    echo -e "${YELLOW}[*] Memulai Backup & Sanitasi Privasi...${NC}\n"
    mkdir -p "$BACKUP_DIR" "$PLYMOUTH_DIR" "$SYS_EXT_DIR" "$WALLPAPER_DIR" "$RAW_ASSETS_DIR"

    echo -e "${BLUE}[+]${NC} Mengeksport Konfigurasi Dconf..."
    dconf dump /org/gnome/desktop/ > "$DCONF_FILE"
    dconf dump /org/gnome/shell/ >> "$DCONF_FILE"

    sed -i "s|$HOME|~|g" "$DCONF_FILE"
    sed -i "s|/home/[^/]*|~|g" "$DCONF_FILE"
    sed -i '/[a-zA-Z0-9._%+-]\+@[a-zA-Z0-9.-]\+\.[a-zA-Z]\{2,\}/d' "$DCONF_FILE" 2>/dev/null || true
    sed -i '/recent-files/d' "$DCONF_FILE" 2>/dev/null || true

    echo -e "${BLUE}[+]${NC} Mengambil Wallpaper Aktif..."
    BG_URI=$(gsettings get org.gnome.desktop.background picture-uri 2>/dev/null | tr -d "'")
    BG_PATH=$(echo "$BG_URI" | sed 's|file://||')
    [ -f "$BG_PATH" ] && cp "$BG_PATH" "$WALLPAPER_DIR/"

    if [ -d "/usr/share/gnome-shell/extensions" ]; then
        echo -e "${BLUE}[+]${NC} Menyalin Ekstensi Sistem..."
        cp -r /usr/share/gnome-shell/extensions/* "$SYS_EXT_DIR/" 2>/dev/null || true
    fi

    echo -e "${BLUE}[+]${NC} Menyalin Tema Plymouth..."
    if command -v plymouth-set-default-theme &>/dev/null; then
        CURRENT_PLYMOUTH=$(plymouth-set-default-theme 2>/dev/null)
        if [ -n "$CURRENT_PLYMOUTH" ]; then
            echo "$CURRENT_PLYMOUTH" > "$PLYMOUTH_DIR/current_theme.txt"
            [ -d "/usr/share/plymouth/themes/$CURRENT_PLYMOUTH" ] && sudo cp -r "/usr/share/plymouth/themes/$CURRENT_PLYMOUTH" "$PLYMOUTH_DIR/"
        fi
    fi

    echo -e "${BLUE}[+]${NC} Mengumpulkan Tema, Ikon, Font & Ekstensi..."
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
    echo -e "${GREEN}${BOLD}|             BACKUP COMPLETED                |${NC}"
    echo -e "${GREEN}${BOLD}+---------------------------------------------+${NC}\n"

    pause_to_menu
}

do_restore() {
    draw_banner
    check_debian_family || { pause_to_menu; return 1; }
    show_system_info
    check_dependencies || { pause_to_menu; return 1; }

    if [ ! -d "$BACKUP_DIR" ]; then
        echo -e "${RED}[!] ERROR: Folder backup tidak ditemukan!${NC}\n"
        pause_to_menu
        return 1
    fi

    CURRENT_DE="${XDG_CURRENT_DESKTOP:-$DESKTOP_SESSION}"
    if [ -z "$CURRENT_DE" ] && pgrep -x "gnome-shell" &>/dev/null; then
        CURRENT_DE="GNOME"
    fi

    if [[ ! "$(echo "$CURRENT_DE" | tr '[:upper:]' '[:lower:]')" =~ gnome ]]; then
        echo -e "${RED}[!] ERROR: Lingkungan desktop bukan GNOME! (${CURRENT_DE:-Unknown})${NC}\n"
        pause_to_menu
        return 1
    fi

    check_and_prepare_folders || { pause_to_menu; return 1; }

    create_rollback_snapshot

    echo -e "${YELLOW}[*] Memulai Restorasi Tema macOS...${NC}\n"

    if [ -f "$TAR_FILE" ]; then
        echo -e "${BLUE}[+]${NC} Mengekstrak arsip tema ke Home..."
        tar -xzf "$TAR_FILE" -C "$HOME" 2>/dev/null || handle_restore_error "Ekstraksi Tema"
    elif [ -d "$RAW_ASSETS_DIR" ]; then
        echo -e "${BLUE}[+]${NC} Menyalin aset tema mentah..."
        cp -r "$RAW_ASSETS_DIR"/* "$HOME/" 2>/dev/null || handle_restore_error "Menyalin Aset"
    fi

    echo -e "${BLUE}[+]${NC} Mengompilasi skema ekstensi..."
    chmod -R 755 ~/.local/share/gnome-shell/extensions/ 2>/dev/null || true
    for dir in ~/.local/share/gnome-shell/extensions/*/; do
        [ -d "${dir}schemas" ] && glib-compile-schemas "${dir}schemas" 2>/dev/null || true
    done

    if [ -d "$SYS_EXT_DIR" ] && [ "$(ls -A "$SYS_EXT_DIR" 2>/dev/null)" ]; then
        echo -e "${BLUE}[+]${NC} Mengembalikan Ekstensi Sistem..."
        sudo cp -r "$SYS_EXT_DIR"/* /usr/share/gnome-shell/extensions/ 2>/dev/null || true
    fi

    if [ -f "$DCONF_FILE" ]; then
        echo -e "${BLUE}[+]${NC} Mengaplikasikan Konfigurasi Dconf..."
        dconf load /org/gnome/ < "$DCONF_FILE" 2>/dev/null || handle_restore_error "Penerapan Dconf"
    fi

    auto_fix_dash_to_dock

    if [ -d "$WALLPAPER_DIR" ] && [ "$(ls -A "$WALLPAPER_DIR")" ]; then
        echo -e "${BLUE}[+]${NC} Mengatur Wallpaper..."
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
        echo -e " ${CYAN}[1]${NC} Ya, ganti tema Plymouth"
        echo -e " ${CYAN}[2]${NC} Tidak, lewati Plymouth"
        echo ""
        read -p "Pilihan Plymouth [1-2]: " ply_opt

        if [ "$ply_opt" == "1" ]; then
            echo -e "${BLUE}[+]${NC} Mengatur tema Plymouth..."
            THEME_NAME=$(cat "$PLYMOUTH_DIR/current_theme.txt")
            if [ -d "$PLYMOUTH_DIR/$THEME_NAME" ]; then
                sudo cp -r "$PLYMOUTH_DIR/$THEME_NAME" /usr/share/plymouth/themes/ 2>/dev/null
                sudo plymouth-set-default-theme -R "$THEME_NAME" 2>/dev/null || true
                echo -e "${BLUE}[+]${NC} Memperbarui initramfs (APT Native)..."
                sudo update-initramfs -u 2>/dev/null || true
            fi
        fi
    fi

    # Bypass validasi versi ekstensi
    gsettings set org.gnome.shell disable-extension-version-validation true 2>/dev/null || true
    gsettings set org.gnome.shell disable-user-extensions false 2>/dev/null || true

    # Patch GTK4 Libadwaita
    patch_libadwaita_gtk4

    echo ""
    echo -e "${GREEN}${BOLD}+---------------------------------------------+${NC}"
    echo -e "${GREEN}${BOLD}|          RESTORE COMPLETED 100%             |${NC}"
    echo -e "${GREEN}${BOLD}+---------------------------------------------+${NC}"
    echo -e "${YELLOW}[!] NOTICE: Silakan REBOOT / LOGOUT komputer kamu!${NC}\n"

    pause_to_menu
}

main_menu() {
    while true; do
        draw_banner
        echo -e "${BOLD}Pilih Operasi:${NC}"
        echo -e " ${CYAN}[1]${NC} Backup macOS Theme"
        echo -e " ${CYAN}[2]${NC} Restore macOS Theme"
        echo -e " ${CYAN}[3]${NC} Dry Run (Simulasi)"
        echo -e " ${CYAN}[4]${NC} Undo Restore (Rollback)"
        echo -e " ${CYAN}[5]${NC} Switch Banner"
        echo -e " ${CYAN}[6]${NC} Keluar"
        echo ""
        read -p "Pilihan [1-6]: " opt

        case $opt in
            1) do_backup ;;
            2) do_restore ;;
            3) do_dry_run ;;
            4) do_rollback ;;
            5) continue ;;
            6) 
               echo -e "\n${GREEN}Terima kasih! Sampai jumpa...${NC}\n"
               exit 0 
               ;;
            *) 
               echo -e "${RED}Pilihan tidak valid!${NC}"
               sleep 1 
               ;;
        esac
    done
}

main_menu
