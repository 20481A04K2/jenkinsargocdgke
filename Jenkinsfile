pipeline {
    // Uses the Google Cloud SDK Docker image as the execution environment for all stages.
    agent {
        docker {
            image 'gcr.io/google.com/cloudsdk/cloud-sdk'
            // Running as root to ensure permissions are not an issue inside the container
            // when accessing files mounted from the host (like the kubeconfig).
            args '-u root'
        }
    }

    // Set the KUBECONFIG environment variable to point to the file copied on the host.
    // This is required for kubectl inside the Docker container to find the configuration.
    environment {
        KUBECONFIG = '/var/lib/jenkins/.kube/config'
        // Define your project variables
        GCP_PROJECT = 'crested-polygon-472204-n5'
        GKE_CLUSTER = 'cluster-2'
        GKE_REGION  = 'us-east1'
    }

    stages {
        stage('Checkout Source Code') {
            steps {
                echo 'Checking out code from SCM...'
                // Assumes the Git repository is configured in the Jenkins job settings.
                // It checks out the code into the workspace.
                checkout scm
            }
        }

        stage('GKE Deployment') {
            steps {
                script {
                    echo "KUBECONFIG is set to: ${env.KUBECONFIG}"
                    
                    // 1. Refresh the authentication token using the host VM's Service Account.
                    // This command uses the gcloud auth plugin embedded in the kubeconfig.
                    echo 'Activating host Service Account for token refresh...'
                    sh "gcloud auth activate-service-account --key-file=/dev/null"
                    
                    // 2. Refresh the cluster context/credentials using the Service Account token.
                    // This updates the credentials in the KUBECONFIG file on the host.
                    echo "Getting fresh credentials for cluster ${env.GKE_CLUSTER}..."
                    sh "gcloud container clusters get-credentials ${env.GKE_CLUSTER} --region ${env.GKE_REGION} --project ${env.GCP_PROJECT}"

                    // 3. Verify kubectl connection
                    sh 'kubectl cluster-info'

                    // 4. Perform the Kubernetes deployment
                    echo 'Applying Kubernetes deployment configuration...'
                    sh 'kubectl apply -f k8s/simple-deployment.yaml'
                }
            }
        }
    }

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
