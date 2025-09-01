pipeline {
    agent any

    environment {
        AWS_ACCOUNT_ID = "899631475351"
        AWS_REGION     = "us-east-2"
        ECR_REPO       = "hello-world-flask"
        IMAGE_TAG      = "${BUILD_NUMBER}"
    }

    options {
        skipDefaultCheckout() // disable Jenkins' automatic checkout
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    // Ensure a clean workspace
                    deleteDir()

                    // Explicit Git checkout
                    checkout([$class: 'GitSCM',
                              branches: [[name: '*/main']],
                              userRemoteConfigs: [[
                                  url: 'https://github.com/andrewlinzie/TechChallenge2.git',
                                  credentialsId: 'github-PAT-token'
                              ]]
                    ])
                }
            }
        }

        stage('Docker Build') {
            steps {
                sh 'docker --version'
                sh 'docker build -t $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:$IMAGE_TAG App'
            }
        }

        stage('ECR Login & Push') {
            steps {
                sh '''
                  aws ecr get-login-password --region $AWS_REGION \
                    | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

                  docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:$IMAGE_TAG
                '''
            }
        }

        stage('Update kubeconfig') {
            steps {
                sh 'aws eks update-kubeconfig --region $AWS_REGION --name eks-cluster'
            }
        }

        stage('Helm Deploy/Upgrade') {
            steps {
                sh '''
                  helm upgrade --install hello-app ./helm/hello \
                    --namespace jenkins-deploy \
                    --create-namespace \
                    -f helm/hello/values.yaml \
                    --set image.tag=$IMAGE_TAG
                '''
            }
        }
    }
}
