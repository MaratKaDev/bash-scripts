#!/bin/bash

# Камера изменение разрешения экрана
#xrandr --size 1368x768

cd qt_packages/
apt install -y ./qt515*
apt-get install -y libzbarqt0:amd64 zbarcam-qt libopencv-video4.2 unclutter
cd ../
cp udev/99-usb-serial.rules /etc/udev/rules.d/
cp bin/cpdf /usr/local/bin/
cp systemd/pt_inspection.service /etc/systemd/system/
cp systemd/pt_inspection.sh /usr/local/bin/
unzip -d /tmp/ printers/tspl_label_printer_driver_v1.2.0.zip
cd /tmp/tspl_label_printer_driver_v1.2.0
chmod +x ./install
sh ./install
cd ../
rm -rf tspl_label_printer_driver_v1.2.0

echo "Введите номер первой камеры (10)."
read VIDEO1

echo "Введите номер второй камеры (11)."
read VIDEO2

echo Введите MAC-адрес тонометра.
read ANDMAC

echo -e "Введите имя терминала.\n1. GoPack Office (открытая)\n2. GoPack Pro (защишеная)"
read NAME_TERMINAL

echo Введите номер терминала.
read NUMBER_TERMINAL

echo Введите номер телефона тех. поддержки.
read TELEPHONE_SUPPORT

echo -e "Введите номер тип терминала.\n1. Desktop\n2. Terminal"
read TYPE_TERMINAL

echo Введите имя пользователя ПК.
read USERNAME

echo Введите группу пользователя ПК.
read USERGROUP

usermod -a -G  dialout $USERNAME

lpstat -v lp58-eva
echo Введите номер серии принтера сверху.
read SERIAL

# Камера
sed -i 's/dev/video10/dev/video'$VIDEO1'/' /etc/systemd/system/pt_inspection.service
sed -i 's/dev/video11/dev/video'$VIDEO2'/' /etc/systemd/system/pt_inspection.service

# мак адрес
sed -i 's/ANDMAC=/ANDMAC='$ANDMAC'/' /etc/systemd/system/pt_inspection.service

# имя терминала
if [[ $NAME_TERMINAL -eq '1' ]]
then
  sed -i 's/Витамед 03/GoPack Office/' /etc/systemd/system/pt_inspection.service
elif [[ $NAME_TERMINAL -eq '2' ]]
then
  sed -i 's/Витамед 03/GoPack Pro/' /etc/systemd/system/pt_inspection.service
else
  echo "Введите номер терминала из списка."
fi

# номер терминала
sed -i 's/TM-VITAMED-03/'$NUMBER_TERMINAL'/' /etc/systemd/system/pt_inspection.service

# номер поддержки
sed -i 's/8-999-999-99-99/'$TELEPHONE_SUPPORT'/' /etc/systemd/system/pt_inspection.service

# тип терминала
if [[ $TYPE_TERMINAL -eq '1' ]]
then
  sed -i 's/TYPE_TERMINAL=terminal/TYPE_TERMINAL=terminal/' /etc/systemd/system/pt_inspection.service
elif [[ $TYPE_TERMINAL -eq '2' ]]
then
  sed -i 's/TYPE_TERMINAL=terminal/TYPE_TERMINAL=desktop/' /etc/systemd/system/pt_inspection.service
else
  echo "Введите номер терминала из списка."
fi

# имя пользователя
sed -i 's/User=user/User='$USERNAME'/' /etc/systemd/system/pt_inspection.service

# группа пользователя
sed -i 's/Group=user/Group='$USERGROUP'/' /etc/systemd/system/pt_inspection.service
lpadmin -p default -u allow:all -v "usb://MPRINT/LP58%20EVA?serial="$SERIAL -i /usr/share/cups/model/tspl/LPQ58.ppd
cupsenable default
cupsaccept default
lp -d default  '/tmp/pt-inspection/print.pdf'

#mv /home/$USERNAME/pt-inspection/qml /usr/local/bin/pt_inspection
cp /tmp/pt-inspection/qml /usr/local/bin/pt_inspection
chown -R $USERNAME:$USERGROUP /usr/local/bin/pt_inspection
chown -R $USERNAME:$USERGROUP /usr/local/bin/cpdf
chmod 775 /usr/local/bin/pt_inspection
chmod 775 /usr/local/bin/cpdf
chmod +x /usr/local/bin/pt_inspection
chmod +x /usr/local/bin/cpdf
chmod +x /usr/local/bin/pt_inspection.sh
echo 'KERNEL=="video*", ATTRS{idVendor}=="0380", ATTRS{idProduct}=="2006", ATTR{index}=="0", SYMLINK+="video11"' | tee -a '/etc/udev/rules.d/99-usb-serial.rules'

#sudo apt install blueman
systemctl restart bluetooth

echo Включите тонометр для сопряжения с терминалом а затем нажмите [ENTER].
read
bluetoothctl pair $ANDMAC
#bluetoothctl trust $ANDMAC

# вывод списка устройств, с которыми установлено соединение
bluetoothctl paired-devices

#bluetoothctl connect $ANDMAC

systemctl restart cups
systemctl enable pt_inspection.service
systemctl start pt_inspection.service
