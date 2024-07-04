##Overview
configure jenkins to use sonarqube in CI-CD

##Prerequisites
1 Jenkins installed and Running
2 Sonarqube and Sonarscanner install on jenkins server for jenkins user. 

###Execution
#go to sonarqube dashboard -> administration->my account->security->enter token name-><for jenkins> ->generate.(copy the token on notepad)
                           -> adminstrator->configuration->webhook->name->jenkins->URL->https://<jenkins`s URL>/sonarqube-webhook/ ->save

#go jenkins dashboard ->manage jenkins ->add credentials ->kind ->secret text -> <paste token here> -> id & description -> <sonarsrv> ->save
#go to jenkins dashboards ->configure system->sonarqube server-> name -> <sonarsrv> ->server url -> <https.sonar.clientdrive.in> ->Server authentication token -><select the credentials setup in previous step> -> save
      #note
      > Don't use / (forward slash) after url (if used then it will throgh error while quality gate execution in pipeline) 


#go to sonbarqube dashboard -> add project -> project key -> <project name> ->How do you want to analyze your repository-> locally-> provide a token -> enter name for your token -> generate -> Run analysis on your project -> <select the project type> -> <copy the commands>.
   #commands look like this -> sonar-scanner -Dsonar.projectKey=cloudnetra_dev_ui -Dsonar.sources=. -Dsonar.host.url=https://sonar.store4u.io -Dsonar.login=7aea9c8do89dsjnkus9ik

#go to jenkins pipeline and use below sub stage in pipeline after git checkkout stage
 stage('sonarscan'){
            steps{
                withSonarQubeEnv('sonarsrv') { 
                    sh '''${JENKINS_HOME}/tools/sonar-scanner/bin/sonar-scanner -Dsonar.projectKey=cloudnetra_dev_ui -Dsonar.sources=. -Dsonar.host.url=https://sonar.store4u.io -Dsonar.login=7aea9c8cfe2ba62e2291634334cf774c8ebfdd'''
                }
            }
        }    
     #note
      > On this location sonarscanner is install on jenkins server -> ${JENKINS_HOME}/tools/bin 
      > This is the command generated while creating project in sonarqube -> sonar-scanner -Dsonar.projectKey=cloudnetra_dev_ui -Dsonar.sources=. -Dsonar.host.url=https://sonar.store4u.io -Dsonar.login=7aea9c8cfe2ba62e2291634334cf774c8ebfdd


#optional -> #if want to enable the quality gate for code in sonarqube, use below stage after sonarscan stage  
 stage("Quality Gate") {
            steps {
               timeout(time: 5, unit: 'MINUTES') {
               waitForQualityGate abortPipeline: true  credentialsId: 'sonarsrv'
            }
        }
    }  
      #note 
      > this is the credeteialsID set in jenkins`s manage credentials for sonarqube -> sonarsrv
 
