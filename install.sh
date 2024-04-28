#!/bin/bash

# Función para mostrar un mensaje de estado
status_message() {
    echo "==> $@"
}

# Instalación de Nginx
# status_message "Instalando Nginx..."
# sudo apt install nginx -y

# Iniciar y verificar el estado de Nginx
# status_message "Iniciando Nginx..."
# sudo systemctl start nginx
# status_message "Estado de Nginx:"
# sudo systemctl status nginx

# Instalación de Grafana
# status_message "Instalando Grafana..."
# sudo apt-get install -y adduser libfontconfig1
# wget https://dl.grafana.com/oss/release/grafana_7.3.4_amd64.deb
# sudo dpkg -i grafana_7.3.4_amd64.deb
# sudo systemctl daemon-reload
# sudo systemctl start grafana-server
# status_message "Estado de Grafana:"
# sudo systemctl status grafana-server
# sudo systemctl enable grafana-server.service

# Instalación de Node Exporter
status_message "Instalando Node Exporter..."
sudo useradd --no-create-home node_exporter
wget https://github.com/prometheus/node_exporter/releases/download/v1.0.1/node_exporter-1.0.1.linux-amd64.tar.gz
tar xzf node_exporter-1.0.1.linux-amd64.tar.gz
sudo cp node_exporter-1.0.1.linux-amd64/node_exporter /usr/local/bin/node_exporter
rm -rf node_exporter-1.0.1.linux-amd64.tar.gz node_exporter-1.0.1.linux-amd64

# Crear el servicio de Node Exporter
status_message "Creando el servicio de Node Exporter..."
cat << EOF | sudo tee /etc/systemd/system/node-exporter.service > /dev/null
[Unit]
Description=Prometheus Node Exporter Service
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable node-exporter
sudo systemctl start node-exporter
status_message "Estado de Node Exporter:"
sudo systemctl status node-exporter

# Instalación de Prometheus
status_message "Instalando Prometheus..."
sudo useradd --no-create-home prometheus
sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus
wget https://github.com/prometheus/prometheus/releases/download/v2.23.0/prometheus-2.23.0.linux-amd64.tar.gz
tar -xvf prometheus-2.23.0.linux-amd64.tar.gz
sudo cp prometheus-2.23.0.linux-amd64/prometheus /usr/local/bin
sudo cp prometheus-2.23.0.linux-amd64/promtool /usr/local/bin
sudo cp -r prometheus-2.23.0.linux-amd64/consoles /etc/prometheus/
sudo cp -r prometheus-2.23.0.linux-amd64/console_libraries /etc/prometheus
sudo cp prometheus-2.23.0.linux-amd64/promtool /usr/local/bin/
rm -rf prometheus-2.23.0.linux-amd64.tar.gz prometheus-2.23.0.linux-amd64

# Crear el archivo de configuración de Prometheus
status_message "Creando el archivo de configuración de Prometheus..."
cat << EOF | sudo tee /etc/prometheus/prometheus.yml > /dev/null
global:
  scrape_interval: 15s
  external_labels:
    monitor: 'prometheus'

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
  - job_name: 'node_exporter'
    static_configs:
      - targets: ['localhost:9100']
EOF

# Crear el servicio de Prometheus
status_message "Creando el servicio de Prometheus..."
cat << EOF | sudo tee /etc/systemd/system/prometheus.service > /dev/null
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus --config.file /etc/prometheus/prometheus.yml --storage.tsdb.path /var/lib/prometheus/ --web.console.templates=/etc/prometheus/consoles --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF
sudo chown prometheus:prometheus /etc/prometheus
sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool
sudo chown -R prometheus:prometheus /etc/prometheus/consoles
sudo chown -R prometheus:prometheus /etc/prometheus/console_libraries
sudo chown -R prometheus:prometheus /var/lib/prometheus
sudo systemctl daemon-reload
sudo systemctl enable prometheus
sudo systemctl start prometheus
status_message "Estado de Prometheus:"
sudo systemctl status prometheus

# Permitir el tráfico en el puerto 9090 para Prometheus
# status_message "Permitiendo el tráfico en el puerto 9090 para Prometheus..."
# sudo ufw allow 9090/tcp

status_message "Instalación completada."
