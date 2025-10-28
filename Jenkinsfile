pipeline {
    // 1. Define the execution environment
    // Changed to 'agent any' to resolve the "Invalid agent type" error.
    agent any

    // 2. Define Environment Variables
    environment {
        // CRITICAL: KUBECONFIG must point to the mounted path INSIDE the Docker container
        // We will update this path inside the steps, as the mount path may be different
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
                    // FIX: Changed deprecated GCR path to the official Docker Hub image name.
                    docker.image('google/cloud-sdk').inside(
                        // CRITICAL: Explicitly define the Docker run arguments here
                        // -u root: Run as root inside the container
                        // -v /host/path:/container/path: Mount the kubeconfig from the host to the container
                        '--user root -v /var/lib/jenkins/.kube:/root/.kube'
                    ) {
                        echo "KUBECONFIG is correctly set to: ${env.KUBECONFIG} (Inside Docker container)"
                        
                        // 1. --- REMOVED THE FAILING gcloud auth activate-service-account STEP ---
                        // We rely on the Service Account attached to the host VM (GCE metadata)
                        echo 'Relying on host VM Service Account for GKE authentication...'
                        
                        // 2. Get fresh cluster credentials (updates the mounted /root/.kube/config file)
                        echo "Getting fresh credentials for cluster ${env.GKE_CLUSTER}..."
                        sh "gcloud container clusters get-credentials ${env.GKE_CLUSTER} --region ${env.GKE_REGION} --project ${env.GCP_PROJECT}"

                        // 3. Verify kubectl connection
                        sh 'kubectl cluster-info'

                        // 4. Perform the Kubernetes deployment
                        echo 'Applying Kubernetes deployment configuration...'
                        // FIX: Updated file paths to use the manifests/ directory provided in the context.
                        sh 'kubectl apply -f manifests/deployment-high-spec.yaml'
                        sh 'kubectl apply -f manifests/service-high-spec.yaml'
                    }
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
