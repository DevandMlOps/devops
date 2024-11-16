pipeline {
    agent any
    
    tools {
        maven 'Maven 3.8.6'
        jdk 'JDK 17'
    }
    
    environment {
        DOCKER_IMAGE = 'java-app'
        DOCKER_TAG = 'latest'
        APP_PORT = '8080'
        CONTAINER_NAME = 'java-application'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Build') {
            steps {
                sh 'mvn clean package'
            }
        }
        
        stage('Test') {
            steps {
                sh 'mvn test'
            }
            post {
                always {
                    junit '**/target/surefire-reports/*.xml'
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
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
