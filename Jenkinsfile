pipeline{
    agent any
    tools{
        maven "M2_HOME"
    }
    environment {
        IMAGE_NAME = 'gatrimohamedali/java-cicd-project:1.0'
    }
    stages{
        stage("Git checkOut"){
            steps{
                echo "TESTING WEBHOOKS WITH NGROK again"
            }
        }
        stage("Maven Package"){
            steps{
                sh "mvn clean package"
            }
        }
        stage("SonarTest integration"){
            steps{
                withSonarQubeEnv(installationName: 'SonarQubeServer') {
                    sh "mvn sonar:sonar"
                }
            }
        }
        stage('Push to Nexus') {
            steps {
                // Configure Nexus repository credentials
                //withCredentials([usernamePassword(credentialsId: 'nexus_credentials', passwordVariable: 'NEXUS_PASSWORD', usernameVariable: 'NEXUS_USERNAME')]) {
                  // Push JAR file to Nexus repository using Nexus Artifact Uploader plugin
                  nexusArtifactUploader(
                    nexusVersion: 'nexus3',
                    protocol: 'http',
                    nexusUrl: '192.168.0.5:8081',
                    groupId: 'com.esprit.examen',
                    version: '1.2',
                    repository: 'learning',
                    credentialsId: 'nexus_credentials',
                    artifacts: [
                      [
                        artifactId: 'tpAchatProject',
                        classifier: '',
                        file: 'target/tpAchatProject-1.0.jar',
                        type: 'jar'
                      ]
                    ]
                  )
                //}
            }
          }
          stage("login docker"){
            steps {
              withCredentials([usernamePassword(credentialsId:'docker_credentials', passwordVariable:'DOCEKR_PASS', usernameVariable:'DOCKER_USER')]){
              sh "echo $DOCKER_PASS | docker login -u $DOCEKR_USER --password-stdin"
              }
            }
          }
          stage("tag and push docekr image"){
            steps {
              sh " docker build -t ${IMAGE_NAME} ."
              sh "docker push ${IMAGE_NAME}"
            }
          }
          
          stage("deploy on jenkins server"){
            steps {
              sh "docker-compose up"
            }
          }

    }
    
}
