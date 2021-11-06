#!/bin/bash

# First, boot your RPI and run raspi-config to set locale, enable networking, etc.
# Then, you can run this script locally or via a remote termina.

echo -e ""

echo -e "\033[2A\033[97mHere goes the Kiosk installer... You need to enter a URL here for the Kiosk to launch to: \033[0m"
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
echo -e "\033[2A\033[97mOK - URL set. Doing my business now, hang on...\033[0m"
sudo apt -y update
sudo apt -y dist-upgrade
sudo apt -y clean
sudo apt -y install --no-install-recommends xserver-xorg
sudo apt -y install raspberrypi-ui-mods
sudo apt -y install rpd-icons gtk2-engines-clearlookspix
sudo apt -y install unclutter ntpdate at-spi2-core libnotify-bin mate-notification-daemon mate-notification-daemon-common
sudo apt -y remove  geany thonny qpdfview xarchiver gpicview galculator mousepad
sudo apt -y autoremove
mkdir -p ~/.config/lxsession/LXDE-pi

echo -e "@lxpanel --profile LXDE-pi
@pcmanfm --desktop --profile LXDE-pi
@xscreensaver -no-splash
@xset s off
@xset dpms 0 0 0
@/home/pi/autostart.sh" > ~/.config/lxsession/LXDE-pi/autostart

ln -s .config/lxsession/LXDE-pi/autostart ~/autostart

echo -e "#!/bin/bash

while ! ip route | grep -q -e \"eth0\" -e \"wlan0\"; do
    notify-send -t 900 \"Waiting for network connection...\" &> /dev/null
    sleep 1
done

notify-send -t 500 \"Connected.\" &> /dev/null
notify-send -t 3000 \"Starting browser...\" &> /dev/null
chromium-browser --incognito --app=$URL --start-fullscreen --check-for-update-interval=31536000 --overscroll-history-navigation=0 --disable-pinch" > ~/autostart.sh

echo -e "OK, I'm done. Reboot this thing and it will pop up to your prescribed page."
echo -e "If you messed up the URL, edit /home/pi/autostart.sh to correct the URL."
echo - "Scheduling restart..."
sudo shutdown -r
