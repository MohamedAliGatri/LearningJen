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
        stage("SonarTest integration"){
            steps{
                withSonarQubeEnv() {
                    sh "mvn sonar:sonar -Dsonar.projectKey=project -Dsonar.projectName='project'"
                }
            }
        }
    }
    
}