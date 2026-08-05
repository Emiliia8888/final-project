pipeline {

    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod

spec:

  initContainers:

  - name: ecr-login
    image: amazon/aws-cli:latest
    command:
      - sh
      - -c
    args:
      - |
        aws ecr get-login-password --region eu-central-1 > /tmp/pass

        mkdir -p /kaniko/.docker

        AUTH=\$(echo -n AWS:\$(cat /tmp/pass) | base64)

        cat > /kaniko/.docker/config.json <<EOF
        {
          "auths": {
            "034255117140.dkr.ecr.eu-central-1.amazonaws.com": {
              "username": "AWS",
              "password": "\$(cat /tmp/pass)",
              "auth": "\$AUTH"
            }
          }
        }
        EOF

    env:

    - name: AWS_REGION
      value: eu-central-1

    volumeMounts:

    - name: docker-config
      mountPath: /kaniko/.docker


  containers:

  - name: kaniko
    image: gcr.io/kaniko-project/executor:latest
    command:
      - /busybox/cat
    tty: true

    volumeMounts:

    - name: docker-config
      mountPath: /kaniko/.docker


  - name: git
    image: alpine/git
    command:
      - cat
    tty: true


  volumes:

  - name: docker-config
    emptyDir: {}

"""
        }
    }


    environment {

        AWS_REGION = "eu-central-1"

        ECR_REPO = "034255117140.dkr.ecr.eu-central-1.amazonaws.com/django-app-gitops"

        GIT_REPO = "https://github.com/Emiliia8888/Lesson-8-9.git"

        HELM_REPO = "https://github.com/Emiliia8888/helm-django.git"

        IMAGE_TAG = "${BUILD_NUMBER}"

    }


    stages {


        stage('Checkout Repository') {

            steps {

                container('git') {

                    withCredentials([
                        usernamePassword(
                            credentialsId: 'github-creds',
                            usernameVariable: 'GIT_USER',
                            passwordVariable: 'GIT_TOKEN'
                        )
                    ]) {

                        sh """

                        git clone https://${GIT_USER}:${GIT_TOKEN}@github.com/Emiliia8888/Lesson-8-9.git .

                        git checkout main

                        """

                    }

                }

            }

        }


        stage('Build Docker Image') {

            steps {

                container('kaniko') {

                    sh """

                    /kaniko/executor \
                      --context=dir://. \
                      --dockerfile=Dockerfile \
                      --destination=${ECR_REPO}:${IMAGE_TAG}

                    """

                }

            }

        }


        stage('Update Helm Values') {

            steps {

                container('git') {

                    withCredentials([
                        usernamePassword(
                            credentialsId: 'github-creds',
                            usernameVariable: 'GIT_USER',
                            passwordVariable: 'GIT_TOKEN'
                        )
                    ]) {

                        sh """

                        rm -rf helm-django

                        git clone https://${GIT_USER}:${GIT_TOKEN}@github.com/Emiliia8888/helm-django.git


                        cd helm-django


                        sed -i "s/tag:.*/tag: ${IMAGE_TAG}/g" charts/django-app/values.yaml


                        git config user.email "jenkins@example.com"

                        git config user.name "Jenkins"


                        git add charts/django-app/values.yaml


                        git commit -m "Update image tag ${IMAGE_TAG}" || true


                        git push origin main


                        """

                    }

                }

            }

        }


    }


    post {

        success {

            echo "Deployment update completed successfully"

        }


        failure {

            echo "Pipeline failed"

        }

    }

}
