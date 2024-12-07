# Documentación del Pipeline CI/CD

Este documento describe el flujo de trabajo de CI/CD implementado con Jenkins, Docker y Terraform para nuestra aplicación Java Spring Boot.

## Arquitectura del Pipeline

El pipeline implementa un flujo de trabajo CI/CD completo que incluye:
- Integración Continua (CI): compilación y pruebas
- Entrega Continua (CD): construcción de imagen Docker y despliegue
- Infraestructura como Código (IaC): gestión de contenedores con Terraform

## Flujo de Trabajo Jenkins

### 1. Checkout del Código
- Jenkins se conecta al repositorio Git usando credenciales configuradas
- Descarga el código fuente más reciente de la rama main
- Prepara el workspace para la compilación

### 2. Compilación con Maven
- Jenkins utiliza la herramienta Maven configurada (versión 3.9.9)
- Ejecuta el comando `mvn clean package`:
  - `clean`: limpia el directorio target
  - `package`: compila el código y crea el JAR
- El archivo JAR resultante se almacena en `target/*.jar`

### 3. Pruebas Unitarias
- Ejecuta `mvn test` para las pruebas unitarias
- Utiliza JUnit para procesar los resultados
- Genera reportes en `target/surefire-reports/`
- Los resultados se publican en Jenkins usando el plugin JUnit

### 4. Construcción de Imagen Docker
- Jenkins construye la imagen Docker usando un Dockerfile multi-etapa:
  ```dockerfile
  # Etapa de construcción
  FROM maven:3.9.9-eclipse-temurin-17 AS build
  WORKDIR /app
  COPY . .
  RUN mvn clean package -DskipTests

  # Etapa de ejecución
  FROM eclipse-temurin:17-jre-alpine
  WORKDIR /app
  COPY --from=build /app/target/*.jar app.jar
  ```
- La imagen final se etiqueta como `java-health-app:latest`
- Se optimiza el tamaño usando una imagen base Alpine

### 5. Limpieza de Contenedores
- Elimina cualquier contenedor existente con el mismo nombre
- Asegura un despliegue limpio sin conflictos

## Gestión de Infraestructura con Terraform

### 1. Inicialización
- Terraform inicializa el provider de Docker
- Descarga los plugins necesarios
- Prepara el entorno de trabajo

### 2. Planificación
- Crea un plan de ejecución
- Determina los cambios necesarios en la infraestructura
- Genera un archivo de plan (`tfplan`)

### 3. Aplicación
- Ejecuta el plan generado
- Gestiona el ciclo de vida del contenedor Docker
- Configura la red y los puertos

### Configuración de Terraform
El archivo `main.tf` define:
```hcl
resource "docker_container" "java_app" {
  name  = "java-health-app"
  image = docker_image.java_app.name

  ports {
    internal = 8080
    external = 9090
  }

  restart = "unless-stopped"

  healthcheck {
    test = ["CMD", "wget", "-q", "--spider", "http://localhost:8080/health"]
    interval = "30s"
    timeout  = "10s"
    retries  = 3
  }
}
```

### Características de la Infraestructura
- **Contenedor**: gestiona un único contenedor Docker
- **Puertos**: mapea el puerto interno 8080 al puerto externo 9090
- **Reinicio**: configurado para reiniciar automáticamente
- **Healthcheck**: monitoreo de salud cada 30 segundos

## Verificación del Despliegue

Para verificar el despliegue exitoso:
```bash
# Verificar el estado del contenedor
docker ps

# Probar el endpoint de salud
curl http://localhost:9090/health

# Ver logs del contenedor
docker logs java-health-app
```

## Mantenimiento y Actualización

Para desplegar actualizaciones:
1. Commit y push de los cambios al repositorio
2. Jenkins detectará los cambios y ejecutará el pipeline
3. Terraform gestionará la actualización del contenedor

## Resolución de Problemas

Problemas comunes y soluciones:
1. **Puerto en uso**: verificar que el puerto 9090 esté disponible
2. **Fallo en healthcheck**: revisar logs del contenedor
3. **Errores de permisos**: verificar permisos de Docker y Jenkins
