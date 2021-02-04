## Create APP Directories
sudo mkdir /var/lib/rsktest
sudo mkdir /var/log/rsktest
sudo mkdir /etc/rsktest
sudo mkdir /usr/share/rsktest
sudo chown rsk:rsk /var/log/rsktest/
sudo chown rsk:rsk /var/lib/rsktest/

## Download Latest RSK Release
wget -q -nv -O- https://api.github.com/repos/rsksmart/rskj/releases/latest 2>/dev/null |  jq -r '.assets[]' |grep browser |cut -d ":" -f 2,3 |tr -d \" |sudo wget -qi - -O /usr/share/rsktest/rsk.jar

## Download RSK Config files.

sudo wget https://raw.githubusercontent.com/alebanzas/rsk-artifacts/master/ubuntu-testnet/testnet.conf -O /etc/rsktest/testnet.conf
sudo wget https://raw.githubusercontent.com/alebanzas/rsk-artifacts/master/ubuntu-testnet/logback.xml -O /etc/rsktest/logback.xml

## Set Default RSK Network

sudo ln -s /etc/rsktest/testnet.conf /etc/rsktest/node.conf

## Create RSK systemd Service

cat << EOF | sudo tee /etc/systemd/system/rsktest.service
[Unit]
Description=RSK Testnet Node

[Service]
LimitNOFILE=500000
Type=simple
ExecStart=/usr/bin/java -Dlogback.configurationFile=/etc/rsktest/logback.xml -Drsk.conf.file=/etc/rsktest/node.conf -cp /usr/share/rsktest/rsk.jar co.rsk.Start 2>&1 &
ExecStop=/bin/kill -9 $(/bin/ps -U rsk -o pid h)
PIDFile=/var/run/rsktest.pid
User=rsk

[Install]
WantedBy=multi-user.target
EOF

## Enable RSK Service
sudo systemctl enable rsktest.service

## Start RSK node
sudo service rsktest start