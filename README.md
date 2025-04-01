# ntopng

sudo oder root
```
wget https://raw.githubusercontent.com/TimInTech/ntopng/main/install-ntopng.sh -O install-ntopng.sh
chmod +x install-ntopng.sh
./install-ntopng.sh
```

---


```
sudo nano /etc/systemd/system/promisc.service
```
---
.ini
```
[Unit]
Description=Setzt Promiscuous Mode auf Interface
After=network.target

[Service]
ExecStart=/sbin/ip link set <DEIN_INTERFACE> promisc on
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```
```
sudo systemctl daemon-reexec
sudo systemctl enable promisc
```

