# 🍎 KalMacScript `(Debian/GNOME Edition)`

_preview_

<img src="screenshoot.png">

> **KalMacScript** adalah alat otomatisasi (_bash script engine_) modern untuk mengubah tampilan sistem Linux berbasis **Debian/GNOME Desktop** menjadi bergaya **macOS** secara instan, presisi, dan aman.

Script ini dirancang khusus untuk seluruh ekosistem distro turunan **Debian/Ubuntu** dengan dukungan penuh pada sesi **Wayland** maupun **X11**, serta **GNOME 40+**.

---

## ✨ Fitur Utama Versi Baru

- 🎯 **Debian Family Native**: Kompatibilitas 100% untuk `Kali Linux`, `Ubuntu`, `Debian`, `Linux Mint`, `Pop!_OS`, dan `Zorin OS`.
- 🔍 **Real-Time System Check**: Visualisasi animasi pendeteksian distro, tipe sesi (`Wayland`/`X11`), dan versi `GNOME`.
- 📁 **Auto-Folder Patcher**: Memeriksa folder tujuan (`~/.themes`, `~/.icons`, dll). Membuat struktur folder otomatis jika belum tersedia.
- 🎨 **Libadwaita / GTK4 Fixer**: Memaksa aplikasi GTK4 modern (seperti `Nautilus` & `Gnome-Terminal`) memakai tema macOS secara presisi.
- 🛡️ **Safety Rollback Snapshot**: Membuat cadangan snapshot sebelum restore. Fitur `Undo` siap mengembalikan tampilan awal kapan saja.
- 🔒 **Privacy Sanitizer**: Membersihkan data sensitif, riwayat berkas, dan username akun secara otomatis saat proses _backup_.
- 🧪 **Dry Run Mode**: Fitur pengujian simulasi tanpa merusak atau mengubah konfigurasi tampilan sistem asli.

---

## 🚀 Cara Penggunaan

Buka terminal kamu dan jalankan perintah di bawah ini satu per satu:

### 1. Clone Repositori

```bash
git clone https://github.com/Marz57/AIO-linux-X-macOs
```

### 2. Masuk ke Folder Project

```
cd AIO-linux-X-macOs
```

### 3. Berikan Izin Eksekusi pada Script

```
chmod +x run.sh
```

### 4. Jalankan Script Engine

```
./run.sh
```

### 🛠️ Menu Utama Script

| No  | Nama Menu               | Deskripsi Fungsi                                               |
| --- | ----------------------- | -------------------------------------------------------------- |
| [1] | Backup Theme            | Mengambil & membersihkan konfigurasi tema dari sistem kamu     |
| [2] | Restore macOS Theme     | Menerapkan tema macOS secara menyeluruh ke sistem Debian/GNOME |
| [3] | Dry Run (Simulasi)      | Menguji integritas berkas backup sebelum diekstrak             |
| [4] | Undo Restore (Rollback) | Mengembalikan tampilan ke posisi semula jika ada kendala       |
| [5] | Switch Banner           | Mengganti gaya header visual ASCII pada script secara berkala  |

### 📋 Persyaratan Sistem

- OS Core: Distro Turunan Debian (Kali Linux, Ubuntu, Debian, Pop!\_OS, Linux Mint, DLL)
- Desktop Environment: GNOME Shell (Wayland / X11)
- Paket Dependencies: dconf-cli, libglib2.0-bin, plymouth (Script akan menginstal otomatis via apt jika belum ada)

### 👤 Author & Credits

- Coded by : OfficialMarz57
- Profile : [Official Website](https://officialmarz57.rf.gd/)
- TikTok : [M a r z 5 7](https://www.tiktok.com/@marz.57)
- Instagram : [M ? r z 5 7](https://www.instagram.com/official_marz57)
- Saweria : [onlymarz57](https://saweria.co/onlymarz57)
- Special Thanks : DevlinTeamSec

  > ⚠️ Catatan Penting:
  > Setelah proses Restore selesai 100%, sangat disarankan untuk melakukan Reboot atau Log Out komputer agar seluruh ikon, ekstensi shell, dan tema GTK4 termuat dengan sempurna.
