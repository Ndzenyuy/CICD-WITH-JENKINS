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
                sh 'mvn -DskipTests install'
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
                    echo "Downloading OWASP Dependency-Check..."
                    wget https://github.com/jeremylong/DependencyCheck/releases/latest/download/dependency-check.zip -O dc.zip
                    
                    unzip -q dc.zip -d dependency-check
                    chmod +x dependency-check/bin/dependency-check.sh
                    
                    echo "Running dependency-check..."
                    dependency-check/bin/dependency-check.sh \
                        --project "Ecommerce" \
                        --scan ./src \
                        --format "ALL" \
                        --out ./odc-reports \
                        --failOnCVSS 7 || true
                    
                    echo "Scan completed. Reports saved in odc-reports/"
                '''
            }
          }        
        }

        stage('Building image') {
            steps{
              script {
                sh 'ls -la'
                sh 'docker build -t $IMAGE_NAME:$BUILD_NUMBER .'
              }
            }
        }  
        stage('Push to Dockerhub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'DOCKER_LOGIN',  // ID from Jenkins credentials
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]){
                    sh'''                    
                      echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                      docker push $IMAGE_NAME:$BUILD_NUMBER
                      docker logout                      
                    '''                   
                }
                
            }
        } 
        stage('Remove Images')   {
            steps {
                script {
                    sh 'docker rmi  $IMAGE_NAME:$BUILD_NUMBER'
                }
            }
        }  
        
    }
}