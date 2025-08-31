pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = "us-east-2"
        ECR_REPO = "899631475351.dkr.ecr.us-east-2.amazonaws.com/hello-world-flask"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Docker Version Check') {
            steps {
                sh 'docker --version'
            }
        }

        stage('Docker Build') {
            steps {
                sh 'docker build -t $ECR_REPO:${BUILD_NUMBER} App'
            }
        }

        stage('ECR Login & Push') {
            steps {
                withAWS(credentials: 'aws-credentials', region: "${AWS_DEFAULT_REGION}") {
                    sh '''
                        aws ecr get-login-password --region $AWS_DEFAULT_REGION \
                          | docker login --username AWS --password-stdin $ECR_REPO
                        docker push $ECR_REPO:${BUILD_NUMBER}
                    '''
                }
            }
        }

        stage('Update kubeconfig') {
            steps {
                withAWS(credentials: 'aws-credentials', region: "${AWS_DEFAULT_REGION}") {
                    sh '''
                        aws eks update-kubeconfig --name techchallenge2-eks --region $AWS_DEFAULT_REGION
                    '''
                }
            }
        }

        stage('Helm Deploy/Upgrade') {
            steps {
                sh '''
                    helm upgrade --install hello-app ./helm/hello \
                      --namespace jenkins-deploy \
                      --create-namespace \
                      -f helm/hello/values.yaml \
                      --set image.tag=${BUILD_NUMBER}
                '''
            }
        }
    }
}
