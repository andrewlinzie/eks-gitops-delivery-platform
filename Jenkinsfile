pipeline {
  agent any

  environment {
    AWS_DEFAULT_REGION = 'us-east-2'
    CLUSTER_NAME       = 'eks-cluster'
    ECR_URI            = '899631475351.dkr.ecr.us-east-2.amazonaws.com/hello-world-flask'
    IMAGE_TAG          = "${env.BUILD_NUMBER}"
    RELEASE_NAME       = 'hello'
    CHART_DIR          = 'helm/hello'
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Docker Build') {
      steps {
        sh """
          docker build -t ${ECR_URI}:${IMAGE_TAG} App
        """
      }
    }

    stage('ECR Login & Push') {
      steps {
        sh """
          aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | \
            docker login --username AWS --password-stdin ${ECR_URI}
          docker push ${ECR_URI}:${IMAGE_TAG}
        """
      }
    }

    stage('Update kubeconfig') {
      steps {
        sh "aws eks update-kubeconfig --name ${CLUSTER_NAME} --region ${AWS_DEFAULT_REGION}"
      }
    }

    stage('Helm Deploy/Upgrade') {
      steps {
        dir("${CHART_DIR}") {
          sh """
            helm upgrade --install ${RELEASE_NAME} . \
              --set image.repository=${ECR_URI} \
              --set image.tag=${IMAGE_TAG} \
              --wait --timeout 5m
          """
        }
      }
    }
  }

  post {
    success {
      sh 'kubectl get ingress'
    }
  }
}
