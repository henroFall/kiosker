#!/bin/bash

# First, boot your RPI and run raspi-config to set locale, enable networking, enable pi user to autologin, etc.
# Then, you can run this script locally or via a remote termina.

echo -e ""
echo -e ""
echo "Before you start, use raspi-config to do most of this:
System       S1 - Wireless LAN
System       S3 - Password for Pi
System       S4 - Hostname for Kiosk
System       S5 - B4 - Autologin to Desktop with no password
Display      D2 - Underscan Enable
Display      D4 - Screen Blanking Disable
Performance  P2 - SSH Enable x
Performance  P3 - VNC Enable x
Localisation L1 - Set Locale
Localisation L2 - Set Timezone
Localisation L3 - Set Keyboard

"

while true
do
 read -r -p "Do you wantt to run raspi-config now? [y/n] " input
 
 case $input in
     [yY][eE][sS]|[yY])
 echo -e "Yes\e[0m"
 sudo raspi-config
 break
 ;;
     [nN][oO]|[nN])
 echo -e "No\e[0m"
 ;;
     *)
 echo -e "\e[91mInvalid input...\e[0m"
 ;;
 esac
done
input=""

# Prompt for Kiosk URL
echo -e "Here goes the Kiosk installer... You need to enter a URL here for the Kiosk to launch to: "
read URL
echo
echo -e "The URL is set to: $URL \e[0m"
while true
do
 read -r -p "Are You Sure? [y/n] " input
 
 case $input in
     [yY][eE][sS]|[yY])
 echo -e "Yes\e[0m"
 break
 ;;
     [nN][oO]|[nN])
 echo -e "No\e[0m"
 echo
 echo -e "\e[97mRe-enter the URL: \e[0m"
read URL
echo -e "The URL is set to: $URL \e[0m"
 ;;
     *)
 echo -e "\e[91mInvalid input...\e[0m"
 ;;
 esac
done
URL=\"$URL\"

#Update OS, install desktop, install utilities, cleanup
echo -e "OK - URL set. Doing my business now, hang on..."
sudo apt -y update
sudo apt -y dist-upgrade
sudo apt -y install --no-install-recommends xserver-xorg
sudo apt -y install raspberrypi-ui-mods
sudo apt -y install rpd-icons gtk2-engines-clearlookspix unclutter ntpdate at-spi2-core libnotify-bin mate-notification-daemon mate-notification-daemon-common chromium-browser
sudo apt -y remove geany thonny qpdfview xarchiver gpicview galculator mousepad
sudo apt -y autoremove
sudo apt -y clean

# Make Chrome start at boot
mkdir -p ~/.config/lxsession/LXDE-pi
echo "@lxpanel --profile LXDE-pi
@pcmanfm --desktop --profile LXDE-pi
@xscreensaver -no-splash
@xset s off
@xset dpms 0 0 0
@/home/pi/autostart.sh" > ~/.config/lxsession/LXDE-pi/autostart
ln -s .config/lxsession/LXDE-pi/autostart ~/autostart
echo "#!/bin/bash

while ! ip route | grep -q -e \"eth0\" -e \"wlan0\"; do
    notify-send -t 900 \"Waiting for network connection...\" &> /dev/null
    sleep 1
done

notify-send -t 500 \"Connected.\" &> /dev/null
notify-send -t 3000 \"Starting browser...\" &> /dev/null
chromium-browser --incognito --app=$URL --start-fullscreen --check-for-update-interval=31536000 --overscroll-history-navigation=0 --disable-pinch --disable-crash-reporter" > ~/autostart.sh
chmod +x ~/autostart
chmod +x ~/autostart.sh

# Change VNC to password mode (make compatible with tightvnc)
echo -e We are going to set the VNC password now to be sure you are in a compatible mode:
sudo echo "
Authentication=VncAuth
Encryption=AlwaysOff
Password=e0fd0472492935da" >> /root/.vnc/config.d/vncserver-x11
sudo vncpasswd -service

# Turn off screen saver
saver="mode:		off"
saverx="mode:		random"
sudo sed -i "s/$saverx/$saver/g" ~/.xscreensaver
echo -e "OK, I'm done. Reboot this thing and it will pop up to your prescribed page."
echo -e "If you messed up the URL, edit /home/pi/autostart.sh to correct the URL."
echo - "Scheduling restart..."
sudo shutdown -r
