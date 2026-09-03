# Changelog - Laksanasoft Enterprise Kernel

## [v1.0] - 2026-09-03
### Initial Enterprise Technician Release
- **Rebranding**: Rebranded from FreeRunnerKernel to **Laksanasoft Enterprise Edition v1.0**.
- **Kernel Version**: Linux 4.14.356 for Samsung Galaxy S10+ (beyond2lte / SM-G975F Exynos 9820).
- **USB-to-Serial Drivers**:
  - Added WCH CH340 / CH341 (`CONFIG_USB_SERIAL_CH341=y`) for Arduino and cheap USB-TTL dongles.
  - Added Silicon Labs CP2102 / CP2104 (`CONFIG_USB_SERIAL_CP210X=y`) for ESP32 and NodeMCU.
  - Added Qualcomm Diagnostic serial (`CONFIG_USB_SERIAL_QUALCOMM=y`) for 900E / 901D IMEI / baseband repair.
  - Retained FTDI FT232R and Prolific PL2303.
- **Wireless Drivers**:
  - Restored Ralink RT2800USB / RT3070 / RT5370 (`CONFIG_RT2X00=y`, `CONFIG_RT2800USB=y`) for Alfa AWUS036NH / AWUS036NEH.
  - Retained Realtek RTL8812AU / RTL8814AU dual band (`CONFIG_88XXAU=y`).
  - Retained Atheros AR9271 (`CONFIG_ATH9K_HTC=y`) and Carl9170.
- **Mobile Technician Tools**:
  - Full bulk-transfer support for Android Fastboot, MediaTek BROM (mtkclient), Qualcomm EDL 9008, Samsung Heimdall.
  - Full support for Apple iOS (idevicerestore, usbmuxd, irecovery, checkra1n, palera1n).
- **Security & Stealth**:
  - KernelSU-Next v3.3.0 integrated.
  - SuSFS v2.2.0 stealth hooks integrated.
