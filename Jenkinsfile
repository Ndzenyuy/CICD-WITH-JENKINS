pipeline {
    agent any
    tools {
        maven "MAVEN3.9.9"
        jdk "JDK21"
    }  

    environment {        
        SONARSERVER = 'sonarserver'
        SONARSCANNER = 'sonarscanner'
        IMAGE_NAME = 'ndzenyuy/ecommerce-app'
        IMAGE_TAG  = 'latest'
    }
 

    stages {
        stage('Build'){
            steps {
                sh 'mvn clean install -DskipTests'
            }
            post {
                success {
                    echo "Now Archiving."
                    archiveArtifacts artifacts: '**/*.war'
                }
            }
        }

        stage('Test'){
            steps {
                sh 'mvn test'
            }

        }

        stage('Checkstyle Analysis'){
            steps {
                sh 'mvn checkstyle:checkstyle'
            }
        }

        stage('Sonar Analysis') {
            environment {
                scannerHome = tool "${SONARSCANNER}"
            }
            steps {
               withSonarQubeEnv("${SONARSERVER}") {
                   sh '''${scannerHome}/bin/sonar-scanner -Dsonar.projectKey=cicd-jenkins \
                   -Dsonar.projectName=cicd-jenkins \
                   -Dsonar.projectVersion=1.0 \
                   -Dsonar.organization=jenkins-cicd1 \
                   -Dsonar.sources=src/ \
                   -Dsonar.java.binaries=target/test-classes/com/visualpathit/account/controllerTest/ \
                   -Dsonar.junit.reportsPath=target/surefire-reports/ \
                   -Dsonar.jacoco.reportsPath=target/jacoco.exec \
                   -Dsonar.java.checkstyle.reportPaths=target/checkstyle-result.xml'''
              }
            }
        }
        stage('OWASP Dependency Check') {
            steps {
                sh '''
                echo "Installing unzip..."
                sudo apt-get update && sudo apt-get install -y unzip

                echo "Downloading OWASP Dependency-Check CLI..."
                curl -L -o dependency-check.zip https://github.com/jeremylong/DependencyCheck/releases/download/v8.4.0/dependency-check-8.4.0-release.zip

                echo "Unzipping..."
                unzip -o -q dependency-check.zip -d dependency-check-dir

                echo "Listing dependency-check-dir contents:"
                ls -l dependency-check-dir/dependency-check/bin/

                echo "Setting executable permission..."
                chmod +x dependency-check-dir/dependency-check/bin/dependency-check.sh

                echo "Running OWASP Dependency-Check..."
                ./dependency-check-dir/dependency-check/bin/dependency-check.sh --version || echo "Failed to run dependency-check.sh"

                ./dependency-check-dir/dependency-check/bin/dependency-check.sh \
                    --project "MyProject" \
                    --scan . \
                    --format HTML \
                    --out owasp-report \
                    --failOnCVSS 7 || true

                echo "OWASP scan complete, reports in owasp-report/"
                '''
            }
        }

        stage('Building image') {
            steps{
              script {
                sh 'docker build -t $IMAGE_NAME:$BUILD_NUMBER .'
                sh 'docker tag $IMAGE_NAME:$BUILD_NUMBER $IMAGE_NAME:$IMAGE_TAG'
              }
            }
        }        
        
    }
}