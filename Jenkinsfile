pipeline {
  agent any

  stages {
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar' 
            }
        }   
      stage('Unit Tests - JUnit and Jacoco') {
            steps {
              sh "mvn test"              
            }
            post {
              always{
                junit 'target/surefire-reports/*.xml'
                jacoco execPattern: 'target/jacoco.exec'
              }
            }
      }
stage('SonarQube - SAST') {
      steps {
           sh "mvn sonar:sonar -Dsonar.projectKey=numeric-application -Dsonar.host.url=http://13.91.86.55:9000 -Dsonar.java.jdkHome=/Library/Java/JavaVirtualMachines/jdk1.8.0_301.jdk/Contents/Home"
        }
	}	
	

      stage('Docker Build and Push') {
            steps {
              withDockerRegistry([credentialsId: "docker-hub", url: ""]) {
              sh 'printenv'
              sh 'sudo docker build -t tirth92/numeric-app:""$GIT_COMMIT"" .'
              sh 'docker push tirth92/numeric-app:""$GIT_COMMIT""'              
            }      
        }   
    }
    stage('Kubernetes Deployment - DEV') {
            steps {
              withKubeConfig([credentialsId: 'kubeconfig']) {
              sh "sed -i 's#replace#tirth92/numeric-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
              sh "kubectl apply -f k8s_deployment_service.yaml"              
            }      
        }   
    }
}
}

