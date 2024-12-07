terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.0"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

resource "docker_image" "java_app" {
  name = "java-health-app:latest"
  keep_locally = true
}

resource "docker_container" "java_app" {
  name  = "java-health-app"
  image = docker_image.java_app.name

  ports {
    internal = 8080
    external = 9090  # Cambiado de 8080 a 9090
  }

  restart = "unless-stopped"

  healthcheck {
    test = ["CMD", "wget", "-q", "--spider", "http://localhost:8080/health"]
    interval = "30s"
    timeout  = "10s"
    retries  = 3
  }
}
