# KalMacScript 🍏

**KalMacScript** adalah alat otomatisasi ringan (*lightweight*) yang dirancang khusus untuk melakukan **Backup** dan **Restore** seluruh kustomisasi tampilan macOS pada **Kali Linux GNOME (Wayland/X11)**. 

Script ini secara mendalam mencakup konfigurasi sistem, tema GTK, ikon, font, ekstensi GNOME Shell, wallpaper aktif, hingga animasi *booting* (Plymouth).

---

## 🌟 Fitur Utama

- 🎨 **Deep Backup & Restore**: Menyimpan dan mengembalikan seluruh tema GTK-3/GTK-4, `.themes`, `.icons`, dan font sistem.
- ⚙️ **Dconf/GSettings Registry**: Mengatur ulang tata letak dock, shortcut, dan preferensi tampilan GNOME secara presisi.
- 🧩 **Extension Manager**: Mengamankan seluruh ekstensi GNOME Shell (User & System-wide) lengkap dengan kompilasi skema otomatis agar bebas dari bug/crash.
- 🖼️ **Auto Wallpaper Fix**: Otomatis memulihkan wallpaper dan memperbarui *path* ke direktori pengguna baru.
- 🐉 **Plymouth Boot Theme**: Mengamankan animasi *booting* macOS dan melakukan *rebuild* `initramfs` otomatis saat restore.
- 🔀 **Hybrid Compatibility**: Mendukung deteksi arsip terkompresi (`.tar.gz`) maupun folder aset mentah.
- 🌐 **Dynamic ASCII Banner**: Menampilkan logo hacker/Metasploit acak secara *remote* setiap kali dijalankan.

---

## 🚀 Cara Penggunaan

Kamu tidak perlu menginstal dependensi tambahan karena script ini memanfaatkan *utility* bawaan Kali Linux (`bash`, `dconf`, `tar`, `gsettings`, dan `curl`).

### 1. Cloning Repositori
Buka terminal dan jalankan perintah berikut:

```bash
git clone [https://github.com/Marz57/nama-repo-kamu.git](https://github.com/Marz57/nama-repo-kamu.git)
cd nama-repo-kamu
chmod +x macOS_kali_ultimate.sh
