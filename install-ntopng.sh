#!/bin/bash

echo "=== [1/7] System wird aktualisiert... ==="
sudo apt update && sudo apt upgrade -y

echo "=== [2/7] Grundlegende Tools installieren... ==="
sudo apt install -y wget curl nano sudo software-properties-common gnupg lsb-release apt-transport-https

echo "=== [3/7] Netzwerkschnittstelle ermitteln... ==="
NET_IFACE=$(ip -o -4 route show to default | awk '{print $5}')
echo "→ Interface erkannt: $NET_IFACE"

echo "=== [4/7] Promiscuous Mode aktivieren... ==="
sudo ip link set "$NET_IFACE" promisc on
echo "→ Promiscuous Mode aktiviert auf $NET_IFACE"

echo "=== [5/7] ntopng Repository & Key hinzufügen... ==="
wget https://packages.ntop.org/apt/ntop.key
sudo apt-key add ntop.key
echo "deb https://packages.ntop.org/apt/$(lsb_release -cs)/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/ntopng.list

echo "=== [6/7] ntopng & Abhängigkeiten installieren... ==="
sudo apt update
sudo apt install -y ntopng pfring nprobe n2disk cento

echo "=== [7/7] ntopng konfigurieren... ==="
sudo tee /etc/ntopng/ntopng.conf > /dev/null <<EOF
-G=/var/run/ntopng.pid
-i=$NET_IFACE
--disable-login=1
--community
EOF

sudo systemctl enable ntopng
sudo systemctl restart ntopng

IP=$(hostname -I | awk '{print $1}')
echo ""
echo "✅ Installation abgeschlossen!"
echo "🔗 ntopng ist erreichbar unter: http://$IP:3000"
