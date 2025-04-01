#!/bin/bash

# Farben für Hervorhebung
GRÜN='\033[0;32m'
NC='\033[0m' # Keine Farbe

echo -e "${GRÜN}=== [1/7] System wird aktualisiert... ===${NC}"
sudo apt-get update && sudo apt-get upgrade -y

echo -e "${GRÜN}=== [2/7] Grundlegende Tools installieren... ===${NC}"
sudo apt-get install -y wget curl nano sudo software-properties-common gnupg lsb-release apt-transport-https

echo -e "${GRÜN}=== [3/7] Netzwerkschnittstelle ermitteln... ===${NC}"
NET_IFACE=$(ip -o -4 route show to default | awk '{print $5}')
echo "→ Interface erkannt: $NET_IFACE"

echo -e "${GRÜN}=== [4/7] Promiscuous Mode aktivieren... ===${NC}"
sudo ip link set "$NET_IFACE" promisc on
echo "→ Promiscuous Mode aktiviert auf $NET_IFACE"

echo -e "${GRÜN}=== [5/7] ntopng Repository & Key hinzufügen... ===${NC}"
wget https://packages.ntop.org/apt-stable/$(lsb_release -rs)/all/apt-ntop-stable.deb
sudo apt-get install ./apt-ntop-stable.deb

echo -e "${GRÜN}=== [6/7] ntopng & Abhängigkeiten installieren... ===${NC}"
sudo apt-get update
sudo apt-get install -y pfring-dkms nprobe ntopng n2disk cento

echo -e "${GRÜN}=== [7/7] ntopng konfigurieren... ===${NC}"
sudo mkdir -p /etc/ntopng
sudo tee /etc/ntopng/ntopng.conf > /dev/null <<EOF
-G=/var/run/ntopng.pid
-i=$NET_IFACE
--disable-login=1
--community
EOF

echo -e "${GRÜN}=== ntopng Dienst starten und aktivieren ===${NC}"
sudo systemctl enable ntopng
sudo systemctl start ntopng

echo -e "${GRÜN}✅ Installation abgeschlossen!${NC}"
echo -e "🔗 ntopng ist erreichbar unter: http://$(hostname -I | awk '{print $1}'):3000"
