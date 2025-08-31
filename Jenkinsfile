pipeline {
    agent any

    environment {
        PATH = "/usr/bin:/usr/local/bin:/bin:${env.PATH}"
        AWS_REGION = "us-east-2"
        ECR_REGISTRY = "899631475351.dkr.ecr.us-east-2.amazonaws.com"
        ECR_REPO = "hello-world-flask"
        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Docker Build') {
            steps {
                sh '/usr/bin/docker --version'
                sh '/usr/bin/docker build -t $ECR_REGISTRY/$ECR_REPO:$IMAGE_TAG App'
            }
        }

        stage('ECR Login & Push') {
            steps {
                sh 'aws ecr get-login-password --region $AWS_REGION | /usr/bin/docker login --username AWS --password-stdin $ECR_REGISTRY'
                sh '/usr/bin/docker push $ECR_REGISTRY/$ECR_REPO:$IMAGE_TAG'
            }
        }

        stage('Update kubeconfig') {
            steps {
                sh 'aws eks update-kubeconfig --region $AWS_REGION --name eks-cluster'
            }
        }

        stage('Helm Deploy/Upgrade') {
            steps {
                sh 'helm upgrade --install hello-app helm/hello -n jenkins-deploy --create-namespace -f helm/hello/values.yaml --set image.tag=$IMAGE_TAG'
            }
        }
    }
}
