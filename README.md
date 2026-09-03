# ⚡ Laksanasoft Enterprise Kernel (Samsung Galaxy S10+ beyond2lte)

[![Build Laksanasoft Enterprise Kernel](https://github.com/muhammadfikri-dev/laksanasoft-enterprise-beyond2lte-kernel/actions/workflows/compile-kernel.yml/badge.svg)](https://github.com/muhammadfikri-dev/laksanasoft-enterprise-beyond2lte-kernel/actions/workflows/compile-kernel.yml)
[![GitHub Release](https://img.shields.io/github/v/release/muhammadfikri-dev/laksanasoft-enterprise-beyond2lte-kernel?color=blue&label=Latest%20Release)](https://github.com/muhammadfikri-dev/laksanasoft-enterprise-beyond2lte-kernel/releases)
[![Kernel Version](https://img.shields.io/badge/Linux-4.14.356-informational?logo=linux)](https://kernel.org)
[![Root](https://img.shields.io/badge/Root-KernelSU--Next%20v3.3.0%20%2B%20SuSFS-red)](https://github.com/KernelSU-Next/KernelSU-Next)

Kernel Linux custom tingkat enterprise yang dikembangkan khusus untuk **Samsung Galaxy S10+ (beyond2lte / SM-G975F - Exynos 9820)** sebagai **Stasiun Servis Flashing Smartphone Portabel (Android & iOS)**, **Pengembangan IoT / Hardware Hacking (ESP32, Arduino, USB-TTL UART)**, dan **Kali NetHunter Suite**.

Basis kernel ini menggantikan dan mengembangkan `FreeRunnerKernel` menjadi **Laksanasoft Enterprise Edition**, melengkapi seluruh driver perangkat keras yang sebelumnya absen di kernel Android standar.

---

## 🚀 Fitur Unggulan & Matriks Driver Lengkap

### 1. Driver USB Serial & Hardware Hacking (UART / Microcontroller)
Lengkap untuk jumper testpoint, unbrick via serial bootloader, dump flash TTL, dan koneksi mikrokontroler:
* **WCH CH340 / CH341 (`CONFIG_USB_SERIAL_CH341=y`)**: Arduino UNO/Nano clones, adapter USB-TTL ekonomis.
* **Silicon Labs CP2102 / CP2104 (`CONFIG_USB_SERIAL_CP210X=y`)**: Modul ESP32, NodeMCU ESP8266, sensor industri.
* **FTDI FT232R (`CONFIG_USB_SERIAL_FTDI_SIO=y`)**: Dongle profesional FTDI USB-to-UART.
* **Prolific PL2303 (`CONFIG_USB_SERIAL_PL2303=y`)**: Kabel serial GPS / Prolific.
* **Qualcomm Diagnostic Serial (`CONFIG_USB_SERIAL_QUALCOMM=y`)**: Pemetaan port serial Qualcomm Diag Mode 900E / 901D untuk perbaikan IMEI / baseband / QCN backup.
* **USB CDC-ACM (`CONFIG_USB_ACM=y`)**: Flipper Zero, Proxmark3 RDV4, Arduino Leonardo / Teensy, USB GPS.

### 2. Flashing & Servis Smartphone (Android & iOS)
* **Android Fastboot & ADB**: Bulk transfer berkecepatan tinggi tanpa limitasi buffer.
* **MediaTek BROM / Preloader**: Bypass SLA/DAA dan read/write partisi via `mtkclient`.
* **Qualcomm EDL 9008**: Flashing XML rawprogram / firehose unbrick via `edl`.
* **Samsung Download Mode**: Flashing PIT dan TAR via `heimdall`.
* **Unisoc / Spreadtrum**: Unbrick via `spd_dump`.
* **Apple iOS (iPhone / iPad)**: Restore IPSW firmware via `idevicerestore`, query diagnostik via `ideviceinfo`, kontrol DFU via `irecovery`, serta jailbreak DFU via `checkra1n` dan `palera1n`.

### 3. External Wi-Fi Dongle Drivers (Monitor Mode & Packet Injection)
* **Ralink RT2800USB / RT3070 / RT5370 (`CONFIG_RT2800USB=y`, `CONFIG_RT2X00=y`)**: Alfa AWUS036NH, Alfa AWUS036NEH *(diaktifkan!)*.
* **Atheros AR9271 (`CONFIG_ATH9K_HTC=y`)**: Alfa AWUS036NHA, TP-Link TL-WN722N v1.
* **Atheros AR9170 (`CONFIG_CARL9170=y`)**: TP-Link TL-WN821N v2.
* **Realtek RTL8812AU / RTL8814AU (`CONFIG_88XXAU=y`)**: Alfa AWUS036ACH, AWUS036AC (Dual-Band 2.4/5GHz).
* **Realtek RTL8187L (`CONFIG_RTL8187=y`)**: Alfa AWUS036H.
* **Realtek RTL8xxxu (`CONFIG_RTL8XXXU=y`)**: RTL8188EUS, RTL8192EU.
* **MediaTek MT7601U (`CONFIG_MT7601U=y`)**: Dongle nano Wi-Fi murah.

### 4. USB Arsenal & NetHunter Suite
* **BadUSB HID Keyboard/Mouse (`CONFIG_USB_CONFIGFS_F_HID=y`)**: Eksekusi keystroke DuckHunter.
* **USB Mass Storage CD-ROM Emulation (`CONFIG_USB_CONFIGFS_MASS_STORAGE=y`)**: Mount ISO Windows / Linux installer langsung dari memori HP ke laptop pelanggan.
* **RNDIS USB Ethernet (`CONFIG_USB_CONFIGFS_RNDIS=y`)**: Tethering kabel Ethernet kecepatan gigabit ke PC target.

### 5. Root & Stealth Subsystem
* **KernelSU-Next**: Pengendali hak akses root bawaan kernel (kernel-space).
* **SuSFS v2.2.0**: Penghindar deteksi root canggih (menghindari deteksi perbankan, Play Integrity, dan Game Anti-Cheat).

---

## 📦 Cara Pemasangan (Flashing)

### Metode 1: Via TWRP / OrangeFox Recovery
1. Unduh file `.zip` dari menu [Releases](https://github.com/muhammadfikri-dev/laksanasoft-enterprise-beyond2lte-kernel/releases).
2. Salin file zip ke internal storage ponsel atau flashdisk OTG.
3. Masuk ke TWRP Recovery.
4. Pilih menu **Install** -> pilih file `Laksanasoft-Enterprise-beyond2lte-v1.0-KernelSU-Next-NetHunter-Anykernel3.zip`.
5. Geser ke kanan untuk konfirmasi flash.
6. Pilih **Reboot System**.

### Metode 2: Via KernelSU App
1. Buka aplikasi **KernelSU-Next Manager**.
2. Masuk ke tab **Modul / Install Kernel**.
3. Pilih file zip AnyKernel3.
4. Tunggu hingga proses instalasi ramdisk selesai, lalu restart HP.

---

## 🛠️ Kompilasi Otomatis via GitHub Actions

Repositori ini telah dilengkapi dengan workflow CI/CD otomatis (`.github/workflows/compile-kernel.yml`):
* Setiap kali ada perubahan atau saat tombol **Run workflow** ditekan di tab *Actions*, GitHub akan:
  1. Menyiapkan Ubuntu 22.04 runner.
  2. Mengunduh toolchain Proton-Clang.
  3. Mengambil source code kernel Samsung Exynos 9820 (branch `ksunext-susfs`).
  4. Menyuntikkan konfigurasi driver teknisi Laksanasoft.
  5. Mengompilasi kernel `Image` dan membungkusnya ke dalam flashable zip AnyKernel3.
  6. Mengunggah hasil build langsung ke halaman **GitHub Releases**.

---

## 👨‍💻 Pengembang & Lisensi

* **Lead Engineer**: [Muhammad Fikri](https://github.com/muhammadfikri-dev)
* **Organisasi**: Laksanasoft Enterprise
* **Lisensi**: GNU General Public License v2.0 (GPL-2.0)
* **Kredit**: LeDrew2017 (FreeRunnerKernel), Linux4, Sidex15 (SuSFS), RifSxD (KernelSU-Next), osm0sis (AnyKernel3).
