# KalMacScript 🍏

_preview_

<img src="screenshoot.png">

**_KalMacScript_** adalah alat otomatisasi ringan (_lightweight_) yang dirancang khusus untuk melakukan **Backup** dan **Restore** seluruh kustomisasi tampilan macOS pada **Kali Linux GNOME (Wayland/X11)**.

Script ini secara mendalam mencakup konfigurasi sistem, tema GTK, ikon, font, ekstensi GNOME Shell, wallpaper aktif, hingga animasi _booting_ (Plymouth).
_NOTE_ :
`Namun Plymouth ini nanti ada pengecualian ikut di restore atau tidak, lebih spesifiknya sebelum scrit mengeksekusi perintah penyalinan file tema boot dan pembaruan sistem bootloader, sistem akan bertanya kepada pengguna kalau Plymouth ikut di restore sekalian atau akan dilewatkan sepenuhnya tanpa merubah tampilan Plymouth`.

---

## 🌟 Fitur Utama

- 🎨 **Deep Backup & Restore**: Menyimpan dan mengembalikan seluruh tema GTK-3/GTK-4, `.themes`, `.icons`, dan font sistem.
- ⚙️ **Dconf/GSettings Registry**: Mengatur ulang tata letak dock, shortcut, dan preferensi tampilan GNOME secara presisi.
- 🧩 **Extension Manager**: Mengamankan seluruh ekstensi GNOME Shell (User & System-wide) lengkap dengan kompilasi skema otomatis agar bebas dari bug/crash.
- 🖼️ **Auto Wallpaper Fix**: Otomatis memulihkan wallpaper dan memperbarui _path_ ke direktori pengguna baru.
- 🐉 **Plymouth Boot Theme**: Mengamankan animasi _booting_ macOS dan melakukan _rebuild_ `initramfs` otomatis saat restore.
- 🔀 **Hybrid Compatibility**: Mendukung deteksi arsip terkompresi (`.tar.gz`) maupun folder aset mentah.

---

## 🚀 Cara Penggunaan

Kamu tidak perlu menginstal dependensi tambahan karena script ini memanfaatkan _utility_ bawaan Kali Linux (`bash`, `dconf`, `tar`, `gsettings`, dan `curl`).

### 1. Cloning Repositori

Buka terminal dan jalankan perintah berikut:

```bash
git clone https://github.com/Marz57/kali-x-macos
cd kali-x-macos
chmod +x gaskeun.sh
```

### 2. Menjalankan Script

Jalankan script menggunakan perintah:

```bash
./gaskeun.sh
```

Nanti akan muncul menu interaktif:

- Pilih **1** untuk melakukan **Backup** seluruh tampilan macOS kamu saat ini.
- Pilih **2** untuk melakukan **Restore** tampilan pada sistem Kali Linux yang baru di-install.

> **Catatan Penting setelah Restore:**
> Setelah proses restore selesai, **wajib melakukan Reboot / Log Out** agar GNOME Shell memuat ulang seluruh tema, CSS, dan ekstensi baru.

---

## 📁 Struktur Direktori Backup

Secara otomatis script akan membuat direktori `~/Kali_macOS_Backup` dengan struktur sebagai berikut:

```text
Kali_macOS_Backup/
├── kali_macos_theme.tar.gz   # Arsip kompresi seluruh tema, ikon, font & ekstensi
├── gnome_settings.dconf      # Registry konfigurasi GNOME Shell
├── wallpapers/               # Salinan wallpaper aktif
├── plymouth_backup/          # File tema booting Plymouth
├── system_extensions/        # Ekstensi tingkat sistem (/usr/share)
└── raw_assets/               # Folder mentahan aset UI
```

---

## 👥 Kredit & Informasi

- **Coded by** : OfficialMarz57
- **TikTok** : [M a r z 5 7](https://www.tiktok.com/@Marz57)
- **GitHub** : [OfficialMarz57](https://github.com/Marz57)
- **Instagram** : [M ? r z 5 7](https://www.instagram.com/official_marz57)
- **Special Thanks** : DevlinTeamSec

---

> _Terima kasih telah menggunakan script kami. Jika menemukan kendala atau bug, silakan hubungi kami via DM TikTok maupun Instagram dengan link diatas._
