pipeline {
    agent any

    environment {
        AWS_REGION = "us-east-2"
        ECR_REPO = "899631475351.dkr.ecr.us-east-2.amazonaws.com/hello-world-flask"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout([$class: 'GitSCM',
                    branches: [[name: "*/main"]],
                    userRemoteConfigs: [[
                        url: 'https://github.com/andrewlinzie/TechChallenge2.git',
                        credentialsId: 'github-PAT-token'
                    ]]
                ])
            }
        }

        stage('Docker Build') {
            steps {
                sh '/usr/bin/docker build -t $ECR_REPO:${BUILD_NUMBER} App'
            }
        }

        stage('ECR Login & Push') {
            steps {
                sh '''
                aws ecr get-login-password --region $AWS_REGION \
                  | /usr/bin/docker login --username AWS --password-stdin $ECR_REPO
                /usr/bin/docker push $ECR_REPO:${BUILD_NUMBER}
                '''
            }
        }

        stage('Update kubeconfig') {
            steps {
                sh '''
                aws eks update-kubeconfig --name eks-cluster --region $AWS_REGION
                '''
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
