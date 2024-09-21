pipeline {
  agent any

  environment {
    deploymentName = "devsecops"
    containerName = "devsecops-container"
    serviceName = "devsecops-svc"
    imageName = "tirth92/numeric-app:${GIT_COMMIT}"
    applicationURL="http://13.91.86.55"
    applicationURI="/increment/99"
  }

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
            
      }
      stage('SonarQube - SAST') {
            steps { 
                withSonarQubeEnv('SonarQube') {        
                    sh "mvn sonar:sonar -Dsonar.projectKey=numeric-application -Dsonar.host.url=http://13.91.86.55:9000"
                }
             timeout(time: 2, unit: 'MINUTES'){
                  script {
                        waitForQualityGate abortPipeline: true
                    }
                 }
             }  
      }

    //  stage('Vulnerability Scan - Docker') {
    //       steps {
    //          sh "mvn dependency-check:check"
    //       }
            
    // }

      stage('Vulnerability Scan - Docker') {
        steps {
          parallel(
            	"Dependency Scan": {
         		    sh "mvn dependency-check:check"
	 		        },
	 		        "Trivy Scan":{
	 			        sh "bash trivy-docker-image-scan.sh"
	 		        },
              "OPA-Conftest": {
                sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-docker-security.rego Dockerfile'
              }
			      )
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
     // stage('Vulnerability Scan - Kubernetes') {
     //      steps {
     //       sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-k8s-security.rego k8s_deployment_service.yaml'
     //      }
     // }

      stage('Vulnerability Scan - Kubernetes') {
        steps {
          parallel(
            "OPA Scan" : {
              sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-k8s-security.rego k8s_deployment_service.yaml'
            },
            "Kubesec Scan" :{
              sh "bash kubesec-scan.sh"
            },
            "Trivy Scan" :{
              sh "bash trivy-k8s-scan.sh"
            }
          )
        }
      }
    
    


    //stage('Kubernetes Deployment - DEV') {
    //        steps {
    //          withKubeConfig([credentialsId: 'kubeconfig']) {
    //          sh "sed -i 's#replace#tirth92/numeric-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
    //          sh "kubectl apply -f k8s_deployment_service.yaml"              
    //        }      
    //    }   
    // }
    //}


    stage('K8S Deployment - DEV') {
      steps {
         parallel(
           "Deployment": {
             withKubeConfig([credentialsId: 'kubeconfig']) {
               sh "bash k8s-deployment.sh"
             }
           },
           "Rollout Status": {
             withKubeConfig([credentialsId: 'kubeconfig']) {
               sh "bash k8s-deployment-rollout-status.sh"
             }
           }
         )
       }
     } 

  //   stage('Integration Tests - DEV') {
  //     steps {
  //       script {
  //         try {
  //           withKubeConfig([credentialsId: 'kubeconfig']) {
  //             sh "bash integration-test.sh"
  //           }
  //         } catch (e) {
  //           withKubeConfig([credentialsId: 'kubeconfig']) {
  //             sh "kubectl -n default rollout undo deploy ${deploymentName}"
  //           }
  //           throw e
  //         }
  //       }
  //     }
  //   }

     stage('OWASP ZAP - DAST') {
       steps {
         withKubeConfig([credentialsId: 'kubeconfig']) {
           sh 'bash zap.sh'
         }
       }
     }

  // post { 
  //      always { 
  //         junit 'target/surefire-reports/*.xml'
  //         jacoco execPattern: 'target/jacoco.exec'
  //         dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
  //           publishHTML([allowMissing: false, alwaysLinkToLastBuild: true, keepAll: true, reportDir: 'owasp-zap-report', reportFiles: 'zap_report.html', reportName: 'OWASP ZAP HTML Report', reportTitles: 'OWASP ZAP HTML Report', useWrapperFileDirectly: true])
 // }
//}

}
}
