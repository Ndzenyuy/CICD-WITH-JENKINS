pipeline {
    agent any
    tools {
        maven "MAVEN3.9.9"
        jdk "JDK17"
    }  
  

    stages {
        stage('Build'){
            steps {
                sh 'mvn -DskipTests install'
            }
        }
    }
}