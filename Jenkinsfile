#!/usr/bin/env groovy
pipeline{
    agent any
    tools{
        maven "M2_HOME"
    }
    environment {
        IMAGE_NAME = 'gatrimohamedali/java-cicd-project'
    }
    stages{
        stage("Git checkOut"){
            steps{
              script{
                echo "TESTING WEBHOOKS WITH NGROK again"
              }
            }
        }
        stage("Incrementing version"){
          steps{
            script {
              sh 'mvn build-helper:parse-version versions:set \
                -DnewVersion=" \\\${parsedVersion.majorVersion}.\\\${parsedVersion.nextMinorVersion}"\
                versions:commit'
              def matcher = readFile("pom.xml") =~'<version>(.+)</version>'
              def version = matcher[1][1]
              //env.APP_VERSION="$version-$BUILD_NUMBER" some ADDS BUILD NUMBER TO VERSION
              env.APP_VERSION="$version".trim()
            }
          }
        }
        stage("Maven Package"){
            steps{
              script{
                sh "mvn clean package"
              }
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
                    version: "${APP_VERSION}",
                    repository: 'learning',
                    credentialsId: 'nexus_credentials',
                    artifacts: [
                      [
                        artifactId: 'tpAchatProject',
                        classifier: '',
                        file: "target/tpAchatProject-${APP_VERSION}.jar",
                        type: 'jar'
                      ]
                    ]
                  )
                //}
            }
          }
          stage("login docker"){
            steps {
              script{
                withCredentials([usernamePassword(credentialsId:'docker_credentials', passwordVariable:'DOCKER_PASS', usernameVariable:'DOCKER_USER')]){
                  sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
                }
              }
            }
          }
          stage("tag and push docekr image"){
            steps {
              script{
                sh "docker build -t ${IMAGE_NAME}:${APP_VERSION} ."
                sh "docker push ${IMAGE_NAME}:${APP_VERSION}"
              }
            }
          }
          stage("commit the version increment"){
            steps{
              script{
                withCredentials([usernamePassword(credentialsId:'github_credentials',passwordVariable:'GIT_PASS',usernameVariable:'GIT_USER')]){
                  sh "git remote set-url origin https://${GIT_USER}:${GIT_PASS}@github.com/MohamedAliGatri/LearningJen.git"
                  sh "git add ."
                  sh 'git commit -m "jenkins: version bump"'
                  sh 'git push origin HEAD:aws-terraform-deploy'
                }
              }
            }
          }
          stage("cleaning up"){
            steps{
              script{
                sh "docker image rm ${IMAGE_NAME}:${APP_VERSION}"
              }
            }
          }
          
          stage("deploy on jenkins server"){
            steps {
              script{
                echo "Passing env var"
                //sh "envsubst < docker-compose.yml"
                //sh "docker-compose up"
              }
            }
          }

    }
    
}
