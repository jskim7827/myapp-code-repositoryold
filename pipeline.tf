provider "google" {
  credentials = "${file("service-account-key1.json")}"
  project = "my-cd-pipeline-249116"
  region = "us-west1"
}

resource "google_compute_instance" "concourse" {
  name         = "concourse"
  machine_type = "n1-standard-1"
  zone         = "us-west1-b"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  metadata = {
    startup-script = <<SCRIPT
#!/bin/bash
apt-get update && \
apt-get install -y postgresql-9.6  && \
systemctl start postgresql && \
sudo -u postgres psql -c "CREATE USER concourse WITH PASSWORD 'concourse';"  && \
sudo -u postgres createdb --owner=concourse atc  && \
sudo -u postgres psql -c 'grant all privileges on database atc to concourse;' && \
curl -L https://github.com/concourse/concourse/releases/download/v4.2.2/concourse_linux_amd64 -o concourse && \
chmod +x concourse && \
mv concourse /usr/local/bin/concourse && \
concourse quickstart \
--add-local-user myuser:mypass \
--main-team-local-user myuser \
--external-url "http://$(curl -s -H 'Metadata-Flavor: Google' http://169.254.169.254/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip):8080" \
--worker-work-dir /opt/concourse/worker \
--postgres-user concourse \
--postgres-password concourse &

SCRIPT
  }

  network_interface {
    network = "default"
    access_config {
    }
  }
}

resource "google_compute_firewall" "default" {
  name    = "allow-all-traffic"
  network = "default"

  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["0-65534"]
  }
}


resource "google_compute_instance" "prometheus" {
  name         = "prometheus"
  machine_type = "n1-standard-1"
  zone         = "us-west1-b"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  metadata = {
    startup-script = <<SCRIPT
#!/bin/bash
curl -sOL https://github.com/prometheus/prometheus/releases/download/v2.6.1/prometheus-2.6.1.linux-amd64.tar.gz && \
tar xvfz prometheus-2.6.1.linux-amd64.tar.gz && \
cd prometheus-2.6.1.linux-amd64 && \
chmod +x prometheus && \
./prometheus --config.file=prometheus.yml &
SCRIPT
  }

  network_interface {
    network = "default"
    access_config {
    }
  }
}

resource "google_compute_instance" "grafana" {
  name         = "grafana"
  machine_type = "n1-standard-1"
  zone         = "us-west1-b"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  metadata = {
    startup-script = <<SCRIPT
#!/bin/bash
curl -sOL https://dl.grafana.com/oss/release/grafana-5.4.3.linux-amd64.tar.gz && \
tar -zxvf grafana-5.4.3.linux-amd64.tar.gz  && \
cd grafana-5.4.3 && \
chmod +x ./bin/grafana-server && \
bin/grafana-server &
SCRIPT
  }

  network_interface {
    network = "default"
    access_config {
    }
  }
}
