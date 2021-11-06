# Kiosker Installer
 Copy / paste this to the command line of a lite RPI install
 
Before you start, use raspi-config to:
System       S1 - Wireless LAN
System       S3 - Password for Pi
System       S4 - Hostname for Kiosk
System       S5 - B4 - Autologin to Desktop with no password
Display      D2 - Underscan Enable
Display      D4 - Screen Blanking Disable
Performance  P2 - SSH Enable
Performance  P3 - VNC Enable
Localisation L1 - Set Locale
Localisation L2 - Set Timezone
Localisation L3 - Set Keyboard
 
 You can then run this command from a local or remote terminal. 

> wget -N -q --show-progress https://raw.githubusercontent.com/henroFall/kiosker/main/kiosker.sh && chmod +x kiosker.sh && ./kiosker.sh && rm ./kiosker.sh



