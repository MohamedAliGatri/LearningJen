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
        /*stage("Maven Package"){
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
          }*/
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
          stage("terraform provisioning"){
            environment{
              AWS_ACCESS_KEY_ID = credentials('aws_access_key')
              AWS_SECRET_ACCESS_KEY = credentials('aws_secret_access_key')
            }
            steps{
              script{
                dir('terraform'){
                  sh 'terraform init'
                  sh 'terraform apply --auto-approve'
                  env.EC2_PUBLIC_IP = sh(
                    script: "terraform output ec2_ip",
                    returnStdout: true
                  ).trim()
                }
              }
            }
          }
          stage("deploy on ec2 server"){
            environment{
              DOCKER_CREDS = credentials('docker_credentials')
            }
            steps {
              script{
                echo "waiting for the ec2 to initialize"
                sleep(time: 90, unit: "SECONDS")

                def shellCmd = "bash ./server-cmds.sh ${IMAGE_NAME} ${DOCKER_CREDS_USR} ${DOCKER_CREDS_PSW}"
                def ec2Instance = "ec2-user@${EC2_PUBLIC_IP}"

                sshagent(['ssh_key_to_ec2']) {
                       sh "scp -o StrictHostKeyChecking=no server-cmds.sh ${ec2Instance}:/home/ec2-user"
                       sh "scp -o StrictHostKeyChecking=no docker-compose.yaml ${ec2Instance}:/home/ec2-user"
                       sh "ssh -o StrictHostKeyChecking=no ${ec2Instance} ${shellCmd}"
                   }


              }
            }
          }

    }
    
}
