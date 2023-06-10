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
                sh "mvn sonar:sonar"
            }
        }
    }
    
}
