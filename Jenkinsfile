pipeline {
    agent any
    
    tools {
        jdk 'JDK 17'
    }
    
    environment {
        DOCKER_IMAGE = 'java-app'
        DOCKER_TAG = 'latest'
        APP_PORT = '8080'
        CONTAINER_NAME = 'java-application'
        GITHUB_REPO = 'https://github.com/DevandMlOps/devops.git'
        // Actualizado con las rutas correctas verificadas
        JAVA_HOME = '/usr/lib/jvm/java-17-openjdk-amd64'
        M2_HOME = '/usr/local/maven/apache-maven-3.9.9'
        PATH = "${env.M2_HOME}/bin:${env.JAVA_HOME}/bin:${env.PATH}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                cleanWs()
                git branch: 'main',
                    url: env.GITHUB_REPO
            }
        }
        
        stage('Build') {
            steps {
                dir('java-app') {
                    sh 'mvn clean package'
                }
            }
        }
        
        stage('Test') {
            steps {
                dir('java-app') {
                    sh 'mvn test'
                }
            }
            post {
                always {
                    junit '**/target/surefire-reports/*.xml'
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                dir('java-app') {
                    script {
                        sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
                    }
                }
            }
        }
        
        stage('Deploy') {
            steps {
                script {
                    sh "docker stop ${CONTAINER_NAME} || true"
                    sh "docker rm ${CONTAINER_NAME} || true"
                    
                    sh """
                        docker run -d \
                            --name ${CONTAINER_NAME} \
                            -p ${APP_PORT}:8080 \
                            --restart always \
                            ${DOCKER_IMAGE}:${DOCKER_TAG}
                    """
                }
            }
        }
        
        stage('Verify Deployment') {
            steps {
                script {
                    sh 'sleep 10'
                    sh "docker ps | grep ${CONTAINER_NAME}"
                    sh "curl -f http://localhost:${APP_PORT}/health || exit 1"
                }
            }
        }
    }
    
    post {
        failure {
            echo 'Pipeline failed! Sending notifications...'
        }
        always {
            cleanWs()
        }
    }
}
