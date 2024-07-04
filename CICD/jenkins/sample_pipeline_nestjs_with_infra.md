#before this we have to install postgres(here we install it in container)database with user-postgres,passwd-123456,port-5432,databasename-user-calender,dbversion-14.4 etc. as mention in source code.
docker run -itd --name postgresdb -p 5432:5432 -e "POSTGRES_PASSWORD=123456" -e "POSTGRES_DB=user-calender" postgres:14.4
#here -e specify that setting up enviromental variable for passwd,database name etc.

##########################################################################3
#pipeline with dockerfile and .dockerignore written in pipeline code , build image out of it, sent image to remote server ,
#create conatiner out of it and run it on port 8080 with estabilsh connection to database
pipeline {
    agent any
    stages {
        stage('SCM') {
            steps {
                // Get code from a SC repository
               git credentialsId: 'alchemy_cred', url: 'https://git.repo.in/scm/sp/node-nest-graphql-api.git'
            }
        }    
        stage('write dockerfile') {
            steps {
                 writeFile file:'Dockerfile', text:'''
                     FROM node:18-alpine
                     WORKDIR /usr/src/app #setup working directory 
                     COPY package*.json ./   
                     RUN npm install
                     COPY . .
                     RUN npm run build
                     CMD [ "node", "dist/main.js" ]
                     '''
            }
        }
        stage('write .dockerignore file') {
            steps {
                 writeFile file:'.dockerignore', text: '''
              
                   Dockerfile
                   .dockerignore
                   node_modules
                   npm-debug.log
                   dist
                   '''
            }
        }              
        stage('Build image out of dockerfile') {
            steps {
                sh 'sed -i s/DATABASE_HOST=localhost/DATABASE_HOST=172.31.28.179/g  src/common/envs/development.env' 
                // it will substiude DATABASE_HOST=localhost name inside src/common/envs/development.env with DATABASE_HOST=172.31.28.179 of app server to set coonection between them
                    
                sh 'docker build -t nest-cloud-run:latest .'
            }
        } 
        stage("Push Docker Image to dev env") {
            steps {
                sh 'docker save nest-cloud-run:latest | bzip2 | pv | ssh alchemy docker load'                            
                //bzip2 use to compress and decompress ,pv allows us for the monitoring of data being sent through pipe
            }
        }                                 
//deployment sample
//cicd
		stage('Container Deployment') {
			steps {
                    echo "Container deployment on alchemy"
                    sh '''#!/bin/bash
                    ssh -t -o StrictHostKeyChecking=no alchemy << 'EOF'
                
                sudo docker images nest-cloud-run:latest                
                sudo docker stop nest-cloud-run
                sudo docker rm -f nest-cloud-run
                sudo docker run -itd -p 8080:3000 --name nest-cloud run nest-cloud-run:latest
                sleep 60
                sudo docker logs nest-cloud-run

                exit
                EOF
                '''
 			}

//send email notifications after configure extended email and default plugin
	        post {
               success {
                   emailext body: '$PROJECT_NAME - Build # $BUILD_NUMBER - successful : Check console output at $BUILD_URL to view the results.', subject: 'alchemy_nestjs - Build # $BUILD_NUMBER - success build ', to: 'email@id.com'
                   //sent only success report with parameter mentioned in emailext body 
               }
               
// Send notification to email in case of failure
// When the build is failed, you want to send notification to email you need to set failOnError is to true 
               failure {
                    emailext body: 'failOnError:true message:"Build failed  - $PROJECT_NAME - Build # $BUILD_NUMBER: Check console output at $BUILD_URL to view the results.', subject: 'alchemy_nestjs - Build # $BUILD_NUMBER - failed build ', to: 'email@id.com'   
                      }
                 }
	    }  
        }
   }    



         
