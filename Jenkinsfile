pipeline {
    agent any

    environment {
        AWS_ACCOUNT_ID   = "899631475351"
        AWS_REGION       = "us-east-2"
        ECR_REPO         = "hello-world-flask"
        IMAGE_TAG        = "${BUILD_NUMBER}"
        CLUSTER_NAME     = "eks-cluster"
        CPU_THRESHOLD    = "1"
        MEMORY_THRESHOLD = "1"
        SNS_TOPIC_ARN    = ""
    }

    options {
        skipDefaultCheckout()
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    deleteDir()

                    checkout([$class: 'GitSCM',
                              branches: [[name: '*/feature/predeploy-health-check']],
                              userRemoteConfigs: [[
                                  url: 'https://github.com/andrewlinzie/TechChallenge2.git',
                                  credentialsId: 'github-pat'
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
                sh 'aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME'
            }
        }

        stage('Cluster Health Check') {
            steps {
                sh 'chmod +x scripts/health-check.sh'
                sh './scripts/health-check.sh'
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

    post {
        failure {
            echo 'Pipeline failed. Review the Cluster Health Check stage logs if deployment did not proceed.'
        }
    }
}