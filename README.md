KalMacScript 🍏
​preview
​<img src="screenshoot.png">
​KalMacScript adalah alat otomatisasi ringan (lightweight) yang dirancang khusus untuk melakukan Backup, Restore, Simulasi (Dry Run), dan Rollback seluruh kustomisasi tampilan macOS pada Kali Linux GNOME (Wayland/X11).
​Script ini secara mendalam mencakup konfigurasi sistem, tema GTK, ikon, font, ekstensi GNOME Shell, wallpaper aktif, hingga animasi booting (Plymouth).
​NOTE (Pengecualian Restorasi Plymouth):
Sebelum mengeksekusi penyalinan file tema boot dan pembaruan sistem bootloader (initramfs), sistem akan memberikan konfirmasi interaktif kepada pengguna: apakah tema Plymouth ikut direstore atau dilewatkan sepenuhnya tanpa mengubah tampilan booting bawaan.
​🌟 Fitur Utama
​🎨 Deep Backup & Restore: Menyimpan dan mengembalikan seluruh tema GTK-3/GTK-4, .themes, .icons, dan font sistem secara mendalam.
​⚙️ Dconf/GSettings Registry: Mengatur ulang tata letak dock, shortcut, dan preferensi tampilan GNOME secara presisi.
​🧹 Privacy Sanitizer: Membersihkan data sensitif (email, recent files, online accounts, path home) secara otomatis pada file konfigurasi sebelum disimpan.
​🛠️ Auto-Installer Dependensi: Mendeteksi paket wajib (dconf-cli, libglib2.0-bin, plymouth) dan menawarkan instalasi otomatis jika belum terpasang di sistem pengguna.
​🧪 Mode Simulasi (Dry Run): Memeriksa integritas file backup (.tar.gz), konfigurasi, dan kesiapan sistem tanpa mengubah/menulis file apapun ke dalam sistem asli.
​🛡️ Safety Rollback Snapshot: Membuat cadangan sementara (snapshot) pengaturan sistem sebelum proses restore dilakukan, sehingga dapat dikembalikan ke keadaan semula jika dibatalkan.
​⚓ Dash to Dock Auto-Fix: Mengonfigurasi dan memperbaiki posisi serta preferensi visual Dock agar langsung bergaya macOS secara otomatis.
​🧩 Extension Manager: Mengamankan seluruh ekstensi GNOME Shell (User & System-wide) lengkap dengan kompilasi skema otomatis agar bebas dari bug/crash.
​🖼️ Auto Wallpaper Fix: Otomatis memulihkan wallpaper dan memperbarui path ke direktori pengguna baru.
​🐉 Plymouth Boot Theme: Mengamankan animasi booting macOS dan melakukan rebuild initramfs otomatis saat restore.
​🚀 Cara Penggunaan
​Script ini dapat mendeteksi serta menginstal dependensi yang kurang secara otomatis melalui pengelola paket apt.
​1. Cloning Repositori
​Buka terminal dan jalankan perintah berikut:
​```bash
git clone https://github.com/Marz57/kali-x-macos
cd kali-x-macos
chmod +x gaskeun.sh

````
​2. Menjalankan Script
​Jalankan script menggunakan perintah:
​```bash
./gaskeun.sh
````

​Nanti akan muncul menu interaktif:
​Pilih 1 untuk melakukan Backup seluruh tampilan macOS kamu saat ini.
​Pilih 2 untuk melakukan Restore tampilan pada sistem Kali Linux yang baru.
​Pilih 3 untuk menjalankan Dry Run (Simulation Mode) guna mengecek integritas backup tanpa mengubah sistem.
​Pilih 4 untuk melakukan Undo Restore (Revert) jika ingin mengembalikan tampilan ke keadaan sebelum restore.
​Pilih 5 untuk mengganti tampilan Banner ASCII.
​Pilih 6 untuk Keluar.
​Catatan Penting setelah Restore:
Setelah proses restore selesai, wajib melakukan Reboot / Log Out agar GNOME Shell memuat ulang seluruh tema, CSS, dan ekstensi baru secara sempurna.
​📁 Struktur Direktori Backup
​Secara otomatis script akan membuat direktori ~/Kali_macOS_Backup dengan struktur sebagai berikut:
​```text
Kali_macOS_Backup/
├── kali_macos_theme.tar.gz # Arsip kompresi seluruh tema, ikon, font & ekstensi
├── gnome_settings.dconf # Registry konfigurasi GNOME Shell (sanitized)
├── wallpapers/ # Salinan wallpaper aktif
├── plymouth_backup/ # File tema booting Plymouth
├── system_extensions/ # Ekstensi tingkat sistem (/usr/share)
└── raw_assets/ # Folder mentahan aset UI

```
​👥 Kredit & Informasi
​Coded by : OfficialMarz57
​TikTok : M a r z 5 7
​GitHub : OfficialMarz57
​Instagram : M ? r z 5 7
​Special Thanks : DevlinTeamSec
​Terima kasih telah menggunakan script kami. Jika menemukan kendala atau bug, silakan hubungi kami via DM TikTok maupun Instagram dengan link diatas.
```
