pipeline {

    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod

metadata:
  labels:
    app: django-app-pipeline

spec:

  serviceAccountName: jenkins

  securityContext:
    fsGroup: 1000

  initContainers:

  - name: ecr-login
    image: amazon/aws-cli:latest
    command:
      - sh
      - -c
    args:
      - |
        aws ecr get-login-password --region \${AWS_REGION} > /tmp/pass
        mkdir -p /kaniko/.docker
        PASS=\$(tr -d '\\012' < /tmp/pass)
          AUTH=\$(printf "AWS:%s" "\$PASS" | base64 -w 0)
        cat > /kaniko/.docker/config.json <<EOF
        {
          "auths": {
            "\${ECR_REGISTRY}": {
              "auth": "\$AUTH"
            }
          }
        }
        EOF
    env:
      - name: AWS_REGION
        value: "eu-central-1"
      - name: ECR_REGISTRY
        value: "034255117140.dkr.ecr.eu-central-1.amazonaws.com"
    volumeMounts:
      - name: docker-config
        mountPath: /kaniko/.docker

  containers:

  - name: git
    image: alpine/git:latest
    command:
      - cat
    tty: true
    volumeMounts:
      - name: workspace-volume
        mountPath: /home/jenkins/agent

  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    command:
      - /busybox/cat
    tty: true
    volumeMounts:
      - name: workspace-volume
        mountPath: /home/jenkins/agent
      - name: docker-config
        mountPath: /kaniko/.docker

  volumes:
    - name: workspace-volume
      emptyDir: {}

    - name: docker-config
      emptyDir: {}
"""
        }
    }

    environment {

        AWS_REGION = "eu-central-1"

        ECR_REPOSITORY = "034255117140.dkr.ecr.eu-central-1.amazonaws.com/django-app-gitops"

        IMAGE_TAG = "${BUILD_NUMBER}"

    }

    stages {

        stage('Checkout Application') {

            steps {

                container('git') {

                    sh '''
                    echo "Using Declarative SCM checkout"

                    ls -la
                    '''

                }

            }

        }

        stage('Validate Project') {

            steps {

                container('git') {

                    sh '''

                    echo "Checking project..."

                    test -f Dockerfile
                    echo "Dockerfile found."

                    test -f requirements.txt
                    echo "requirements.txt found."

                    '''

                }

            }

        }

        stage('Build Docker Image with Kaniko') {

            steps {

                container('kaniko') {

                    sh '''

                    echo "Building image..."

                    /kaniko/executor \
                      --dockerfile=Dockerfile \
                      --context=$WORKSPACE \
                      --destination=${ECR_REPOSITORY}:${IMAGE_TAG}

                    '''

                }

            }

        }

        stage('Update Helm Values') {

            steps {

                container('git') {

                    withCredentials([usernamePassword(
                        credentialsId: 'github-creds',
                        usernameVariable: 'GIT_USERNAME',
                        passwordVariable: 'GIT_PASSWORD'
                    )]) {

                        sh '''

                        echo "Cloning repository for GitOps update"

                        rm -rf gitops-repo

                        git clone https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/Emiliia8888/final-project.git gitops-repo

                        cd gitops-repo

                        echo "Updating image tag..."

                        sed -i "s/^  tag: .*/  tag: ${IMAGE_TAG}/" charts/django-app/values.yaml

                        echo "Current values.yaml:"
                        cat charts/django-app/values.yaml

                        git config user.email "jenkins@localhost"
                        git config user.name "Jenkins"

                        git add charts/django-app/values.yaml

                        git commit -m "Update django image tag to ${IMAGE_TAG}" || echo "No changes"

                        git push origin HEAD:main

                        '''

                    }

                }

            }

        }

    }

    post {

        always {

            container('git') {

                sh '''

                echo "Cleaning workspace permissions"

                chmod -R u+rwX,g+rwX,o+rwX $WORKSPACE || true

                '''

            }

        }

        success {

            echo "Pipeline completed successfully."

        }

        failure {

            echo "Pipeline failed."

        }

    }

}
