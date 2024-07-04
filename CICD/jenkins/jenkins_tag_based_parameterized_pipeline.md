Overview
Setup parameterized Jenkins pipeline for selecting the tag while building the pipeline 

Prerequisites
Installed and setup the Jenkins with all credentials to access the source code repo.
Execution	
Install the ‘git parameter’ plugin from 
Dashboard->Manage Jenkins->Plugin Manager->available plugin
Go to dashboard and open the pipeline 
Go to ‘Configure -> pipeline’ and add the below code at same place (after agent any section) as mention, also use same syntax for checkout stage (remember to replace Git repo url of yours`s )


pipeline {
    agent any
    parameters {
        gitParameter name: 'TAG_NAME',
                     type: 'PT_TAG',
                     defaultValue: 'master'
    }
    stages {
        stage('checkout') {
            steps {
                checkout([$class: 'GitSCM',branches: [[name: "${params.TAG_NAME}"]],doGenerateSubmoduleConfigurations: false,extensions: [],gitTool: 'Default',submoduleCfg: [],userRemoteConfigs: [[url: 'https://github.com/example/website.git']]
                        ])
            }
        }
    }
}

Apply and save 
After this build pipeline manually once to setup the parameter .


Afterword it will prompt to select the tag while build. 


 

Testing
Create the new tag (here I created as a version) in git and push to remote using commands 
$ git tag -a v1.40 -m "for testing the tag parameter for v1.40"
$ git push origin master v1.40
 

Confirm the pushed tag in github (central repository) 



same tag is updated in Jenkins parameter selection section while build 


