#!/bin/bash
set -e

# === KONFIGURATION ===
MOUNTPOINT="/mnt/usb"
DATE=$(date +%Y%m%d)
IMAGE_NAME="raspi_kde_${DATE}.img.xz"
DEVICE="/dev/sda"  # ⚠️ Bitte sicherstellen, dass dies der USB-Stick ist!

# === Fortschrittsanzeige mit Farbfallback ===
supports_color() {
    [[ -t 1 ]] && tput colors &>/dev/null && [ "$(tput colors)" -ge 8 ]
}

show_progress() {
    local percent=$1
    local bar=""
    local color=""
    local i

    for ((i=0; i<percent/2; i++)); do bar+="#"; done
    for ((i=percent/2; i<50; i++)); do bar+="."; done

    if supports_color; then
        if (( percent < 25 )); then color="\e[31m"     # rot
        elif (( percent < 50 )); then color="\e[33m"   # gelb
        elif (( percent < 75 )); then color="\e[35m"   # orange
        else color="\e[32m"                            # grün
        fi
        echo -ne "${color}[${bar}] ${percent}%\e[0m\r"
    else
        echo -ne "[${bar}] ${percent}%\r"
    fi
}

# === INSTALLATION & BACKUP-VORGANG ===

echo -e "\n🔄 Starte Systemupdate..."
for p in 0 20 40 60 80 100; do show_progress $p; sleep 0.2; done; echo
sudo apt update
sudo apt upgrade -y
sudo apt full-upgrade -y
sudo SKIP_BACKUP=1 rpi-update <<< "y"
show_progress 100; echo

echo -e "\n🖱️ Installiere lightdm..."
sudo apt install -y lightdm
show_progress 100; echo

echo -e "\n🧠 Installiere KDE-Desktop und SDDM..."
sudo apt install -y kde-plasma-desktop sddm
sudo systemctl enable sddm
sudo systemctl set-default graphical.target
show_progress 100; echo

echo -e "\n🖱️ Installiere Touchscreen-Treiber..."
sudo apt install -y xserver-xorg-input-evdev xserver-xorg-input-libinput xinput
show_progress 100; echo

echo -e "\n📐 Konfiguriere Touchscreen (libinput)..."
sudo mkdir -p /etc/X11/xorg.conf.d
sudo bash -c 'cat > /etc/X11/xorg.conf.d/99-touchscreen.conf <<EOF
Section "InputClass"
    Identifier "Touchscreen"
    MatchIsTouchscreen "on"
    Driver "libinput"
    Option "CalibrationMatrix" "1 0 0 0 1 0 0 0 1"
EndSection
EOF'
show_progress 100; echo

echo -e "\n🚀 Starte grafische Oberfläche beim Boot..."
sudo systemctl set-default graphical.target
sudo systemctl enable sddm

echo -e "\n✅Installiere pv, xz"
sudo apt-get install -y xz-utils

echo -e "\n✅führe System Upgrade durch"
sudo apt full-upgrade -y

echo -e "\n🧹 Systembereinigung..."
sudo apt autoremove -y
show_progress 100; echo

echo -e "\n✅ Überprüung von Laufwerk SDA..."
lsblk -o NAME,SIZE,FSTYPE,TYPE,MOUNTPOINT,MODEL

echo -e "\n💾 Prüfe Gerät $DEVICE..."
read -p "⚠️ Bist du sicher, dass $DEVICE dein USB-Stick ist? (ja/j/y/yes): " confirm
case "$confirm" in
    ja|j|y|yes) ;;  # alles okay
    *) echo "Abbruch." && exit 1 ;;
esac

echo -e "\n🧱 Formatiere USB-Stick..."
sudo umount ${DEVICE}* 2>/dev/null || true
echo -e "o\nn\np\n1\n\n\nw" | sudo fdisk $DEVICE
sudo mkfs.vfat -F 32 -n RASPIBACKUP ${DEVICE}1
show_progress 100; echo

echo -e "\n📁 Mounte USB-Stick..."
sudo mkdir -p "$MOUNTPOINT"
sudo mount ${DEVICE}1 "$MOUNTPOINT"
show_progress 100; echo

echo -e "\n📦 Installiere Tools (pv, xz)..."
sudo apt install -y pv xz-utils
show_progress 100; echo

echo -e "\n💽 Erstelle komprimiertes Image..."
SIZE=$(sudo blockdev --getsize64 /dev/mmcblk0)
sudo dd if=/dev/mmcblk0 bs=4M status=none | pv -s $SIZE | xz -T0 | sudo tee "$MOUNTPOINT/$IMAGE_NAME" > /dev/null
show_progress 100; echo

echo -e "\n📤 Trenne USB-Stick sicher..."
sync
sudo umount "$MOUNTPOINT"
show_progress 100; echo

echo -e "\n✅ Backup abgeschlossen! Das Image wurde gespeichert als:"
echo "   $MOUNTPOINT/$IMAGE_NAME"

echo -e "\n📤 System wird neugestartet"
sudo systemctl reboot
