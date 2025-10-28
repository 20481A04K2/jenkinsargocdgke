pipeline {
    // 1. Define the execution environment (GCloud SDK Docker image)
    agent {
        docker {
            image 'gcr.io/google.com/cloudsdk/cloud-sdk'
            // CRITICAL: Mounts the kubeconfig directory from the host (/var/lib/jenkins/.kube)
            // into the container's root user's home directory (/root/.kube).
            args '-u root -v /var/lib/jenkins/.kube:/root/.kube' 
        }
    }

    // 2. Define Environment Variables
    environment {
        // CRITICAL: KUBECONFIG must point to the mounted path INSIDE the Docker container
        KUBECONFIG = '/root/.kube/config'
        // Project Variables
        GCP_PROJECT = 'crested-polygon-472204-n5'
        GKE_CLUSTER = 'cluster-2'
        GKE_REGION  = 'us-east1'
    }

    // 3. Define Pipeline Stages
    stages {
        stage('Checkout Source Code') {
            steps {
                echo 'Checking out code from SCM...'
                // This checks out the code configured in the job's SCM settings
                checkout scm
            }
        }

        stage('GKE Deployment') {
            steps {
                script {
                    echo "KUBECONFIG is correctly set to: ${env.KUBECONFIG}"
                    
                    // 1. Refresh authentication using the host VM's Service Account
                    echo 'Activating host Service Account for token refresh...'
                    sh "gcloud auth activate-service-account --key-file=/dev/null"
                    
                    // 2. Get fresh cluster credentials (updates the mounted /root/.kube/config file)
                    echo "Getting fresh credentials for cluster ${env.GKE_CLUSTER}..."
                    sh "gcloud container clusters get-credentials ${env.GKE_CLUSTER} --region ${env.GKE_REGION} --project ${env.GCP_PROJECT}"

                    // 3. Verify kubectl connection
                    sh 'kubectl cluster-info'

                    // 4. Perform the Kubernetes deployment
                    echo 'Applying Kubernetes deployment configuration...'
                    sh 'kubectl apply -f k8s/deployment.yaml'
                    sh 'kubectl apply -f k8s/service.yaml'
                }
            }
        }
    }

    // 4. Post-Build Actions
    post {
        always {
            // Clean up workspace files to save disk space
            cleanWs()
            echo 'Pipeline execution complete.'
        }
        success {
            echo '✅ Deployment successful!'
        }
        failure {
            echo '❌ Deployment failed!'
        }
    }
}
