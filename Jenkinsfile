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
                    credentialsId: '49fc35f5-5797-44a8-b837-139ff6d2bf33', // Este ID debe coincidir con el configurado en Jenkins
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
