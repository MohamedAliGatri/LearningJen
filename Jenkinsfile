#!/usr/bin/env groovy
pipeline{
    agent any
    tools{
        maven "M2_HOME"
    }
    environment {
        IMAGE_NAME = 'gatrimohamedali/java-cicd-project'
        APP_VERSION = 1.13
    }
    stages{
        stage("FS trivy scan"){
            steps{
              script{
                sh "trivy fs ."
              }
            }
        }
        stage("Test stage"){
            steps{
              script{
                echo "Testing stage"
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
        stage("Parallel Pushing"){
          parallel{
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
            }
          }
          stage("terraform provisioning"){
            environment{
              AWS_ACCESS_KEY_ID = credentials('aws_access_key')
              AWS_SECRET_ACCESS_KEY = credentials('aws_secret_key')
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
          stage("commit version increment - state file"){
            environment{
              GITHUB_ACCESS_KEY = credentials('github_access_key')
            }
            steps{
              script{
                withCredentials([usernamePassword(credentialsId:'github_credentials',passwordVariable:'GIT_PASS',usernameVariable:'GIT_USER')]){
                  sh "git remote set-url origin https://${GITHUB_ACCESS_KEY}@github.com/MohamedAliGatri/LearningJen.git"
                  sh "git add ."
                  sh 'git commit -m "jenkins: version bump - state file commit"'
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
          stage("deploy on ec2 server"){
            environment{
              DOCKER_CREDS = credentials('docker_credentials')
              FULL_IMAGE_NAME = "${IMAGE_NAME}:${APP_VERSION}"
            }
            steps {
              script{
                echo "waiting for the ec2 to initialize"
                sleep(time: 90, unit: "SECONDS")
                
                def shellCmd = "bash ./server-cmds.sh ${FULL_IMAGE_NAME} ${DOCKER_CREDS_USR} ${DOCKER_CREDS_PSW}"
                def ec2Instance = "ec2-user@${EC2_PUBLIC_IP}"

                sshagent(['ssh_key_to_ec2']) {
                  sh "scp -o StrictHostKeyChecking=no -o ServerAliveInterval=300 server-cmds.sh ${ec2Instance}:/home/ec2-user"
                  sh "scp -o StrictHostKeyChecking=no -o ServerAliveInterval=300 docker-compose.yml ${ec2Instance}:/home/ec2-user"
                  sh "scp -o StrictHostKeyChecking=no -o ServerAliveInterval=300 prometheus.yml ${ec2Instance}:/home/ec2-user"
                  sh "ssh -o StrictHostKeyChecking=no -o ServerAliveInterval=300 ${ec2Instance} ${shellCmd}"
                }
              }
            }
          }

    }
    
}
