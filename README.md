# Documentación del Proyecto Java Spring Boot

## 1. Correcciones Necesarias

### 1.1 Estandarización de Puertos
Se deben realizar las siguientes modificaciones para mantener consistencia en los puertos:

- `application.properties`: Cambiar de 8081 a 8080
```properties
server.port=8080
```

- `Dockerfile`: El EXPOSE ya está correcto en 8080
- `Jenkinsfile`: El APP_PORT está correcto en 8080

## 2. Prerequisitos

- Java JDK 17
- Maven 3.8.6 o superior
- Docker
- Jenkins
- Git
- curl (para healthchecks)

## 3. Estructura del Proyecto

```
java-app/
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/
│   │   │       └── demo/
│   │   │           ├── controller/
│   │   │           │   └── HealthController.java
│   │   │           ├── service/
│   │   │           │   └── HealthService.java
│   │   │           └── Application.java
│   │   └── resources/
│   │       └── application.properties
│   └── test/
│       └── java/
│           └── com/
│               └── demo/
│                   └── controller/
│                       └── HealthControllerTest.java
├── Dockerfile
├── Jenkinsfile
└── pom.xml
```

## 4. Instrucciones de Ejecución

### 4.1 Configuración Inicial

1. Clone el repositorio:
```bash
git clone <repository-url>
cd java-app
```

2. Otorgue permisos de ejecución al script:
```bash
chmod +x create_project.sh
```

3. Ejecute el script de configuración:
```bash
./create_project.sh
```

### 4.2 Ejecución Local

1. Compile el proyecto con Maven:
```bash
mvn clean package
```

2. Ejecute la aplicación:
```bash
java -jar target/java-app-1.0.0.jar
```

3. Verifique que la aplicación está funcionando:
```bash
curl http://localhost:8080/health
```

### 4.3 Ejecución con Docker

1. Construya la imagen Docker:
```bash
docker build -t java-app:latest .
```

2. Ejecute el contenedor:
```bash
docker run -d --name java-application -p 8080:8080 java-app:latest
```

3. Verifique el estado del contenedor:
```bash
docker ps | grep java-application
curl http://localhost:8080/health
```

### 4.4 Ejecución con Jenkins

1. Configure Jenkins con las herramientas necesarias:
   - JDK 17
   - Maven 3.8.6
   - Docker

2. Cree un nuevo pipeline en Jenkins:
   - Vaya a Jenkins > Nueva Tarea
   - Seleccione "Pipeline"
   - Configure el origen del código fuente (SCM)
   - Apunte al Jenkinsfile en su repositorio

3. Ejecute el pipeline:
   - El pipeline se encargará de:
     - Compilar el código
     - Ejecutar pruebas
     - Construir la imagen Docker
     - Desplegar la aplicación
     - Verificar el despliegue

## 5. Endpoints Disponibles

- `GET /`: Mensaje de bienvenida
- `GET /health`: Estado de la aplicación

## 6. Verificación del Despliegue

Para verificar que todo está funcionando correctamente:

1. Verifique el mensaje de bienvenida:
```bash
curl http://localhost:8080/
```
Respuesta esperada: "Bienvenido a la API de Demo"

2. Verifique el estado de salud:
```bash
curl http://localhost:8080/health
```
Respuesta esperada:
```json
{
    "status": "UP",
    "version": "1.0.0"
}
```

## 7. Troubleshooting

1. Si el puerto 8080 está ocupado:
   - Verifique si hay otros servicios usando el puerto:
     ```bash
     sudo lsof -i :8080
     ```
   - Detenga el servicio que está usando el puerto o modifique el puerto en `application.properties`

2. Si Docker falla al construir:
   - Verifique que tiene suficiente espacio en disco
   - Limpie imágenes antiguas:
     ```bash
     docker system prune
     ```

3. Si Jenkins falla:
   - Verifique los logs del pipeline
   - Asegúrese de que Jenkins tiene permisos para ejecutar Docker
   - Verifique que las credenciales están configuradas correctamente

## 8. Mantenimiento

1. Actualización de dependencias:
   - Revise periódicamente el archivo `pom.xml`
   - Actualice las versiones de Spring Boot y otras dependencias
   - Ejecute las pruebas después de cada actualización

2. Limpieza de Docker:
```bash
docker system prune -a
```

3. Respaldo de configuraciones:
   - Mantenga copias de seguridad de los archivos de configuración
   - Documente cualquier cambio en la configuración

## 9. Seguridad

- La aplicación está configurada para ejecutarse en el puerto 8080
- El Dockerfile utiliza una imagen base minimal (openjdk:17-jdk-slim)
- Se incluye un healthcheck en el Dockerfile
- Jenkins está configurado para limpiar el espacio de trabajo después de cada ejecución
