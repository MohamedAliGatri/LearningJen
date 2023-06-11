pipeline{
    agent any
    tools{
        maven "MAVEN"
    }
    stages{
        stage("Git checkOut"){
            steps{
                echo "TESTING WEBHOOKS WITH NGROK again"
            }
        }
        /*stage("SonarTest integration"){
            steps{
                withSonarQubeEnv(installationName: 'sonar') {
                    sh "mvn sonar:sonar"
                }
            }
        }*/
        stage("Maven Package"){
            steps{
                sh "mvn clean package"
            }
        }
            stage('Push to Nexus') {
              steps {
                // Configure Nexus repository credentials
                withCredentials([usernamePassword(credentialsId: 'nexus', passwordVariable: 'NEXUS_PASSWORD', usernameVariable: 'NEXUS_USERNAME')]) {
                  // Push JAR file to Nexus repository using Nexus Artifact Uploader plugin
                  nexusArtifactUploader(
                    nexusVersion: 'nexus3',
                    protocol: 'http',
                    nexusUrl: 'http://192.168.0.2:8081/',
                    groupId: 'com.esprit.examen',
                    version: '1.0',
                    repository: 'learning',
                    credentialsId: 'nexus',
                    artifacts: [
                      [
                        artifactId: 'tpAchatProject',
                        classifier: '',
                        file: 'target/tpAchatProject-1.0.jar',
                        type: 'jar'
                      ]
                    ]
                  )
                }
              }
            }
    }
    
}
