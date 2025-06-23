# 📦 Raspberry Pi KDE Backup Script

Dieses Skript erstellt ein vollständiges und komprimiertes Backup des Raspberry Pi Systems inklusive grafischer KDE-Benutzeroberfläche und Touchscreen-Konfiguration. Die Sicherung wird auf einen USB-Stick geschrieben und kann zur Wiederherstellung oder Replikation verwendet werden.

## ⚙️ Funktionen

- Systemupdate & Upgrade (inkl. `rpi-update`)
- Installation von LightDM, KDE Plasma Desktop & SDDM
- Konfiguration von Touchscreen-Treibern und Kalibrierung
- Automatisierter Partitions- und Formatierungsprozess für USB-Stick
- Erstellung eines komprimierten Image-Files im `.img.xz` Format
- Fortschrittsanzeige mit dynamischer Farbunterstützung
- Automatischer Neustart nach erfolgreichem Backup

## 📝 Voraussetzungen

- Raspberry Pi OS Lite (64-bit) vorinstalliert
- Internetverbindung für Paketinstallationen
- USB-Stick (⚠️ wird komplett überschrieben!)
- Root-Rechte (via `sudo`)

## 📂 Verwendung

1. Stelle sicher, dass `/dev/sda` der USB-Stick ist (wird vollständig formatiert!)
2. Starte das Skript mit:
   ```bash
   chmod +x kded.sh
   ./kded.sh
   ```
3. Folge den Anweisungen – das Image wird unter `/mnt/usb/raspi_kde_<DATUM>.img.xz` gespeichert.

## 🛡️ Sicherheitshinweis

Vergewissere dich **vor der Bestätigung**, dass das angegebene Laufwerk (`/dev/sda`) korrekt ist. Ein falsches Gerät kann zu **Datenverlust** führen!

## 🧼 Cleanup

Nicht benötigte Pakete werden automatisch entfernt (`apt autoremove`), um die Systemgröße vor dem Backup zu reduzieren.

## 📋 Autor & Lizenz

Autor: *Rukia*  
Lizenz: MIT
