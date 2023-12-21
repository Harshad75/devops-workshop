def registry = 'https://harshad7777.jfrog.io'
pipeline {
  agent {
    node {
      label 'maven'
    }
  }

environment {
  PATH = "/opt/apache-maven-3.9.6/bin:$PATH"
}

  stages {
    stage("Build the Source Code") {
      steps {
        sh 'mvn clean deploy -Dmaven.test.skip=true'
      }
    }
    stage("Unit Test") {
      steps {
        sh 'mvn surefire-report:report'
      }
    }

    stage('SonarQube analysis') {
      environment {
       scannerHome = tool 'sonar_scanner'
      }
      steps{ 
        withSonarQubeEnv('sonarqube-server') { // If you have configured more than one global server connection, you can specify its name
        sh "${scannerHome}/bin/sonar-scanner"
        }
      }
    }
    stage("Quality Gate"){
      steps {
        script {
          timeout(time: 1, unit: 'HOURS') { // Just in case something goes wrong, pipeline will be killed after a timeout
          def ng = waitForQualityGate() // Reuse taskId previously collected by withSonarQubeEnv
          if (ng.status != 'OK') {
            error "Pipeline aborted due to quality gate failure, Please check the source code and reduce bugs and Code smells: ${ng.status}"
          }
          }    
        }     
      }
    }
    stage("Jar Publish") {
      steps {
        script {
          echo '<--------------- Jar Publish Started --------------->'
          def server = Artifactory.newServer url:registry+"/artifactory" ,  credentialsId:"JFrog-Cred"
          def properties = "buildid=${env.BUILD_ID},commitid=${GIT_COMMIT}";
          def uploadSpec = """{
            "files": [
              {
                "pattern": "jarstaging/(*)",
                "target": "jenkins-integration-libs-release-local/{1}",
                "flat": "false",
                "props" : "${properties}",
                "exclusions": [ "*.sha1", "*.md5"]
                            }
                         ]
                     }"""
          def buildInfo = server.upload(uploadSpec)
          buildInfo.env.collect()
          server.publishBuildInfo(buildInfo)
          echo '<--------------- Jar Publish Ended --------------->'    
        }
      }   
    }   
  }
}
  
