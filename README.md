# Nginx Install

- sudo apt install nginx
- sudo systemctl start nginx
- sudo systemctl status nginx
# Grafana Install

- sudo apt-get install -y adduser libfontconfig1
- wget https://dl.grafana.com/oss/release/grafana_7.3.4_amd64.deb==
- sudo dpkg -i grafana_7.3.4_amd64.deb==
- sudo systemctl daemon-reload
- sudo systemctl start grafana-server
- sudo systemctl status grafana-server
- sudo systemctl enable grafana-server.service

# Node Exporter Install

sudo useradd --no-create-home node_exporter

- wget https://github.com/prometheus/node_exporter/releases/download/v1.0.1/node_exporter-1.0.1.linux-amd64.tar.gz
- tar xzf node_exporter-1.0.1.linux-amd64.tar.gz
- sudo cp node_exporter-1.0.1.linux-amd64/node_exporter /usr/local/bin/node_exporter
- rm -rf node_exporter-1.0.1.linux-amd64.tar.gz node_exporter-1.0.1.linux-amd64

## create node-exporter.service

- sudo nano node-exporter.service

```
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
```

- sudo cp node-exporter.service /etc/systemd/system/node-exporter.service

- sudo systemctl daemon-reload
- sudo systemctl enable node-exporter
- sudo systemctl start node-exporter
- sudo systemctl status node-exporter

# Prometheus Install

- sudo useradd --no-create-home prometheus
- sudo mkdir /etc/prometheus
- sudo mkdir /var/lib/prometheus
 
- wget  https://github.com/prometheus/prometheus/releases/download/v2.23.0/prometheus-2.23.0.linux-amd64.tar.gz
- tar -xvf prometheus-2.23.0.linux-amd64.tar.gz
- sudo cp prometheus-2.23.0.linux-amd64/prometheus /usr/local/bin
- sudo cp prometheus-2.23.0.linux-amd64/promtool /usr/local/bin
- sudo cp -r prometheus-2.23.0.linux-amd64/consoles /etc/prometheus/
- sudo cp -r prometheus-2.23.0.linux-amd64/console_libraries /etc/prometheus
- sudo cp prometheus-2.23.0.linux-amd64/promtool /usr/local/bin/

- rm -rf prometheus-2.23.0.linux-amd64.tar.gz prometheus-2.19.0.linux-amd64

## Create prometheus.yml

- sudo nano prometheus.yml

```
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
```


- sudo cp prometheus.yml /etc/prometheus/

## Create prometheus.service

- sudo nano prometheus.service

```
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
--config.file /etc/prometheus/prometheus.yml \
--storage.tsdb.path /var/lib/prometheus/ \
--web.console.templates=/etc/prometheus/consoles \
--web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
```

- sudo cp prometheus.service /etc/systemd/system/prometheus.service

- sudo chown prometheus:prometheus /etc/prometheus
- sudo chown prometheus:prometheus /usr/local/bin/prometheus
- sudo chown prometheus:prometheus /usr/local/bin/promtool
- sudo chown -R prometheus:prometheus /etc/prometheus/consoles
- sudo chown -R prometheus:prometheus /etc/prometheus/console_libraries
- sudo chown -R prometheus:prometheus /var/lib/prometheus

- sudo systemctl daemon-reload
- sudo systemctl enable prometheus
- sudo systemctl start prometheus
- sudo systemctl status prometheus

- sudo ufw allow 9090/tcp
