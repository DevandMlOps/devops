pipeline {
    agent any
    
    tools {
        // Asegúrate de que estos nombres coincidan con los configurados en Jenkins Global Tool Configuration
        jdk 'JDK 17'
        maven 'Maven 3.9.9'
    }
    
    environment {
        DOCKER_IMAGE = 'java-app'
        DOCKER_TAG = 'latest'
        APP_PORT = '8080'
        CONTAINER_NAME = 'java-application'
        GITHUB_REPO = 'https://github.com/DevandMlOps/devops.git'
    }
    
    stages {
        stage('Checkout') {
            steps {
                cleanWs()
                git branch: 'main',
                    url: env.GITHUB_REPO
            }
        }
        
        stage('Verify Tools') {
            steps {
                sh '''
                    echo "Workspace directory:"
                    pwd
                    echo "Java version:"
                    java -version
                    echo "Maven version:"
                    mvn -version
                '''
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
pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'java-health-app:latest'
        APP_PORT = '8080'
    }

    tools {
        maven 'Maven 3.9.9'  //las herramientas (Maven y JDK) deben estar configuradas con los mismos nombres que se usan en Jenkins
        jdk 'JDK 17'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    credentialsId: 'github-credentials', // Este ID debe coincidir con el configurado en Jenkins
                    url: 'https://github.com/DevandMlOps/devops.git'
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

        stage('Docker Build') {
            steps {
                script {
                    sh 'docker build -t ${DOCKER_IMAGE} .'
                }
            }
        }

        stage('Terraform Init') {
            steps {
                dir('terraform') {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir('terraform') {
                    sh 'terraform plan -out=tfplan'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('terraform') {
                    sh 'terraform apply -auto-approve tfplan'
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        success {
            echo 'Pipeline ejecutado exitosamente'
        }
        failure {
            echo 'El pipeline ha fallado'
            // Aquí puedes añadir notificaciones en caso de fallo
        }
    }
}
