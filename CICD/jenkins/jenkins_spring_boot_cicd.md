pipeline {
    agent none
    stages {

	// Stage Unit Test BPD API
        stage("Application JUnit Test") {
                agent {
                    label "master"
                }
                stages {
                    stage("Clean Work Space"){
                    	steps{
                    		//cleanWs deleteDirs: true
                    		echo ''
                    		sh 'sudo chown -R jenkins:jenkins /var/lib/jenkins/workspace'
                    	}
                    }
                    stage("GitCheckout") {
                        steps {
                            checkout([$class: 'GitSCM', branches: [[name: '${BRANCH_SPECIFIER_PARAM}']], extensions: [], userRemoteConfigs: [[credentialsId: 'Github_creds', url: 'https://repo-url']]])
						   script {
								def output = sh(script:'''#!/bin/bash 
								git log --stat -1
								''',returnStdout: true).trim()
							   env.CHANGES = output
							}
                        }
                    }
                    stage("list path") {
                        steps {
                            sh 'pwd'
                            sh 'ls -ltrh'
                        }
                    }
		            stage("CodeScanSonarQube") {
                        steps {
                            withSonarQubeEnv('sonarsrv') {
                                sh 'echo Feature BPD API selected for scan'
                                sh 'sudo mvn clean org.sonarsource.scanner.maven:sonar-maven-plugin:3.9.0.2155:sonar -Dsonar.projectKey=dev_bpd_api -Dsonar.projectName=dev_bpd_api -Dsonar.sources=. -Dsonar.exclusions=src/test/** -Dsonar.java.binaries=target/sonar -Dsonar.host.url=https://sonar.url.com -Dsonar.login=<token>'
                                sh 'sleep 10'
                            }     			    
                        }
                    }
                    /*stage("Quality Gate") {
        		        steps {
        			        timeout(time: 5, unit: 'MINUTES') {
        			            waitForQualityGate abortPipeline: false, credentialsId: 'sonarsrv'
        			        }
        		        }
        		    }*/
        	        stage('BPD API Unit Test') {
			            steps {
			                sh '''
#!/bin/bash
set +x
PORT=8080
APP_DB_URL=jdbc:mysql://127.0.0.1:3306/devlh2hDevAppDB
APP_DB_USER=<user-here>
APP_DB_PASS=<passwd>
SETTING_DB_URL=jdbc:mysql://127.0.0.1:3306/devlh2hDevDB
SETTING_DB_USER=<user>
SETTING_DB_PASS=<passwd>
AWS_ACCESSKEY=<key>
AWS_SECRETKEY=<secretkey>
AWS_REGION=us-east-1
AWS_BUCKET=<bucket name here>
AWS_KEY=cloudfiles
LC_ISSUER=cognito:lc
AUTH_REGION_NAME=us-east-1
AUTH_POOL_ID=
AUTH_CLIENT_ID=
AUTH_SECRETKEY=
NOTIFICATION_QUEUE_NAME=
DELIVERYPROCESSING_QUEUE_NAME=
SPRING_PROFILES_ACTIVE=test
VALERE_ORG_ID=
VALERE_SERVER=
BPD_API_ID=

cat << EOF > src/test/resources/application.properties
server.port=${PORT}

# App DataSource
spring.datasource-app.url=${APP_DB_URL}
spring.datasource-app.username=${APP_DB_USER}
spring.datasource-app.password=${APP_DB_PASS}

# Setting DataSource
spring.datasource-setting.url=${SETTING_DB_URL}
spring.datasource-setting.username=${SETTING_DB_USER}
spring.datasource-setting.password=${SETTING_DB_PASS}
logging.level.org.springframework.boot.autoconfigure.security.servlet.UserDetailsServiceAutoConfiguration=ERROR

amazon.aws.access-key=${AWS_ACCESSKEY}
amazon.aws.secret-key=${AWS_SECRETKEY}
amazon.aws.region=${AWS_REGION}
amazon.aws.bucket=${AWS_BUCKET}
amazon.aws.key-name=${AWS_KEY}
amazon.cognito.auth-region-name=${AUTH_REGION_NAME}
amazon.cognito.auth-pool-id=${AUTH_POOL_ID}
amazon.cognito.auth-client-id=${AUTH_CLIENT_ID}
amazon.cognito.auth-secret-key=${AUTH_SECRETKEY}
sqs.notification-queue-name=${NOTIFICATION_QUEUE_NAME}
sqs.delivery-queue-name=${DELIVERYPROCESSING_QUEUE_NAME}
spring.profiles.active=${SPRING_PROFILES_ACTIVE}
valere.server=${VALERE_SERVER}
valere.organization-id=${VALERE_ORG_ID}
bpd.api-id=test
EOF
set -x
'''
                        }
                    }
        		    stage('Unit Test') {
        		    	steps {
        				//sh "sudo ./mvnw -Punit-test test"
        				echo ''
        		    	}
        		    }
        		    stage('Integration Test') {
        		    	steps {
        				//sh "sudo ./mvnw -Pintegration-test test"
        				echo ''
        		    	}
        		    }
                }                    
                post {
                    always {
                        //junit '**/target/surefire-reports/TEST-*.xml'
                        echo ''
                    }
                    failure {
                        
                        emailext attachLog: true, body: "Unit Test Job failed Branch: ${BRANCH_SPECIFIER_PARAM} and Build: ${BUILD_ENVIRONMENT_NAME}", compressLog: true, subject: "Job Failed Branch: ${BRANCH_SPECIFIER_PARAM} and Build: ${BUILD_ENVIRONMENT_NAME}", to: 'mail id here'
                        
                        slackSend color: "#FF0000", message:"Unit Test Failed- ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)"
                    }
                    success {
                        
                        emailext attachLog: true, body: "Unit Test Job success Branch: ${BRANCH_SPECIFIER_PARAM} and Build: ${BUILD_ENVIRONMENT_NAME}", compressLog: true, subject: "Job success Branch: ${BRANCH_SPECIFIER_PARAM} and Build: ${BUILD_ENVIRONMENT_NAME}", to: ''
                        
                        slackSend color: "#008000", message:"Unit Test success - ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)"
                    }
                }
        }   
        // End Unit Test Stage
    
	// Stage 1 Build BPD API
        stage("Build And Test Image") {
                agent {
                    label "master"
                }
                stages {
                    stage("Build feature BPD API") {
                        steps {
                            sh '''echo Branch: ${BRANCH_SPECIFIER_PARAM} and Build: ${BUILD_ENVIRONMENT_NAME}'''
                            sh 'sudo mvn -DskipTests -Dspring.profiles.active=dev clean install'
                            sh 'sudo mvn -DskipTests -Dspring.profiles.active=dev package'
                            //sh 'sudo mvn clean install -Dspring.profiles.active=dev -DskipTests'
                        }
                    }
                    stage("Build Docker Container Image") {
                        steps {
                            sh '''echo 'FROM openjdk:11.0.4-jre
COPY target/*.jar /app.jar
EXPOSE 8080
ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/app.jar"]
 '>Dockerfile'''
                            sh '''#!/bin/bash
				echo ------------------------------------
				echo Branch: ${BRANCH_SPECIFIER_PARAM} and Build: ${BUILD_ENVIRONMENT_NAME}
				echo ------------------------------------
				
				GITID=`date +%s`
				DOCKER_CMD=`which docker`
				DOCKER_TAG="stratice/bpd_api_${BUILD_ENVIRONMENT_NAME}:${GITID}"
				
				echo "Remove docker existing image from jenkins"
				sudo docker rmi -f "${DOCKER_TAG}"
				
				echo ${DOCKER_TAG} > DOCKER_TAG_bpd_api.txt
				sudo ${DOCKER_CMD} build --rm --no-cache=false -t ${DOCKER_TAG} .
				'''
                        }
                    }
                    stage("Test Container Image") {
                        steps {

                            sh '''
cat << EOF > env_file_bpd_api
PORT=8080
APP_DB_URL=
APP_DB_USER=
APP_DB_PASS=
SETTING_DB_URL=
SETTING_DB_USER=
SETTING_DB_PASS
AWS_ACCESSKEY=
AWS_SECRETKEY=
AWS_REGION=us-east-1
AWS_BUCKET=
AWS_KEY=cloudfiles
LC_ISSUER=cognito:lc
AUTH_REGION_NAME=us-east-1
AUTH_POOL_ID=
AUTH_CLIENT_ID=
AUTH_SECRETKEY=
NOTIFICATION_QUEUE_NAME=valereqa-notifications
DELIVERYPROCESSING_QUEUE_NAME=valereqa-deliveryprocessing
SPRING_PROFILES_ACTIVE=dev
VALERE_ORG_ID=
VALERE_SERVER=
BPD_API_ID=
SENTRY_DSN=
SENTRY_SAMPLE_RATE=1.0
java.io.tmpdir=/tmp/
EOF'''
                            sh '''#!/bin/bash
DOCKER_TAG=`cat DOCKER_TAG_bpd_api.txt`
sudo docker run -itd -p 8004:8080 --name bpd_api_dev --env-file env_file_bpd_api ${DOCKER_TAG}'''
                            sh 'sleep 60 && sudo docker logs bpd_api_dev'
                            sh 'sudo docker stop bpd_api_dev'
                            sh 'sudo docker rm -f bpd_api_dev'
                        }
                    }                                                                                
                }                    
                post {
                    always {
                        sh 'echo Branch: ${BRANCH_SPECIFIER_PARAM} and Build: ${BUILD_ENVIRONMENT_NAME}'
                    }
                    failure {
                        
                        emailext attachLog: true, body: "Job failed Branch: ${BRANCH_SPECIFIER_PARAM} and Build: ${BUILD_ENVIRONMENT_NAME}", compressLog: true, subject: "Job Failed Branch: ${BRANCH_SPECIFIER_PARAM} and Build: ${BUILD_ENVIRONMENT_NAME}", to: ''
                        
                        slackSend color: "#FF0000", message:"Build failed stage 1 - ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)"
                    }
                    success {
                        
                        emailext attachLog: true, body: "Job success Branch: ${BRANCH_SPECIFIER_PARAM} and Build: ${BUILD_ENVIRONMENT_NAME}", compressLog: true, subject: "Job success Branch: ${BRANCH_SPECIFIER_PARAM} and Build: ${BUILD_ENVIRONMENT_NAME}", to: ''
                        
                        slackSend color: "#008000", message:"Build success stage 1  - ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)"
                    }
                }
        }   
        // End 1st Stage
            
	// Stage 2nd deployment
        stage('Docker Image Verify') {
            matrix {
                agent {
                    label "master"
                }
                axes {
                    axis {
                        name 'PLATFORM1'
                        values 'bpd-poc-app-server'
                    }
                }
                stages {
                    stage("Verify Container Image on App Server") {
                        steps {
                          script{
                            sh 'echo "Verify image on ${PLATFORM1}"'
                            sh '''#!/bin/bash
                            	
                            	scp -r $HOME/workspace/${JOB_NAME}/DOCKER_TAG_bpd_api.txt ubuntu@${PLATFORM1}:/tmp/DOCKER_TAG_bpd_api.txt
                            	scp -r $HOME/workspace/${JOB_NAME}/env_file_bpd_api ubuntu@${PLATFORM1}:/tmp/env_file_bpd_api
                            	
                            	ssh -t -o StrictHostKeyChecking=no -o LogLevel=ERROR -o UserKnownHostsFile=/dev/null ubuntu@${PLATFORM1} << 'EOF'
				export DOCKER_TAG=`cat /tmp/DOCKER_TAG_bpd_api.txt`
				echo "sudo docker images --format "{{.Repository}} has the following {{.ID}}" | egrep "${DOCKER_TAG}""
				sudo docker images --format "{{.Repository}} has the following {{.ID}}" | egrep "${DOCKER_TAG}"
				export RET=`echo $?`
				if [ "$RET" == '0' ];then
					echo "Docker image already present on the server with same tag: ${DOCKER_TAG}"
					echo "Remove docker image or rename image"
				    	exit 3
				else 
					echo "No docker image found "${DOCKER_TAG}""
				fi
				exit
				EOF
				'''
			   }
                        }
                    }
                    stage("Push Docker Image to dev env") {
                        steps {
                            sh 'export DOCKER_TAG=`cat $HOME/workspace/${JOB_NAME}/DOCKER_TAG_bpd_api.txt` && sudo docker save ${DOCKER_TAG} | bzip2 | pv | ssh ubuntu@${PLATFORM1} sudo docker load'                            
                        }
                    }                                 
                }
                post {
                    always {
                        sh 'echo ${PLATFORM1}'
                    }
                    failure {
                        
                        emailext attachLog: true, body: "Job failed on ${PLATFORM1} for docker image validation", compressLog: true, subject: "Job Failed ${PLATFORM1}", to: ''
                        
                        slackSend color: "#FF0000", message:"Build failed stage 2 - ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)"
                    }
                    success {
                        
                        emailext attachLog: true, body: "Job success on ${PLATFORM1} for docker image validation", compressLog: true, subject: "Job success ${PLATFORM1}", to: ''
                        
                        slackSend color: "#008000", message:"Build success stage 2  - ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)"
                    }
                }
            }
        }
        // End 2nd Stage
                
	// Stage 3rd deployment
        stage('Deploy App') {
            matrix {
                agent {
                    label "master"
                }
                axes {
                    axis {
                        name 'PLATFORM'
                        values 'bpd-poc-app-server'
                    }
                }
                stages {
                    stage('Container Deployment') {
                        steps {
                            echo "Container deployment on ${PLATFORM}"
                            sh '''#!/bin/bash
                            	ssh -t -o StrictHostKeyChecking=no ubuntu@${PLATFORM} << 'EOF'
				export DOCKER_TAG=`cat /tmp/DOCKER_TAG_bpd_api.txt`
				echo "sudo docker images "${DOCKER_TAG}""
				sudo docker images "${DOCKER_TAG}"
				
				sudo docker stop bpd_api_dev
				sudo docker stop bpd_api_prod bpd_api_uat
				sudo docker rm -f bpd_api_prod bpd_api_uat bpd_api_dev

				sudo docker run --restart always -itd -p 8004:8080 --name bpd_api_dev --env-file /tmp/env_file_bpd_api ${DOCKER_TAG}
				sleep 60
				sudo docker logs bpd_api_dev
				rm -rf /tmp/env_file_bpd_api /tmp/DOCKER_TAG_bpd_api.txt
				exit
				EOF
				'''
                            sh 'echo '
                        }
                    }
                }
                post {
                    always {
                        sh 'echo ${PLATFORM}'
                        cleanWs()
                    }
                    failure {
                        
                        emailext attachLog: true, body: "Job failed on ${PLATFORM}\n\n- Last Changes in code: ${CHANGES}\n", compressLog: true, subject: "Job Failed ${PLATFORM}", to: ''
                        
                        slackSend color: "#FF0000", message:"Build failed stage 3 - ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)"
                    }
                    success {
                        
                        emailext attachLog: true, body: "Job success ${PLATFORM}\n\n- Last Changes in code: ${CHANGES}\n", compressLog: true, subject: "Job success ${PLATFORM}", to: ''
			            
			            slackSend color: "#008000", message:"Build deployed successfully stage 3 - ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)"
			            build job: 'dev_bpd_automation_test', parameters: [string(name: 'TAGNAME', value: '@inPatient')]			            
                    }
                }
            }
        }
        // End 3rd Stage
        
    }
}
