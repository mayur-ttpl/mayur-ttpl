https://www.youtube.com/watch?v=bGDyGH13k1g
https://www.jenkins.io/doc/book/pipeline/shared-libraries/

   || Shared liberary ||

#common pipeline code in version control system that can be used by any number of pipeline just by refering. Multiple teams can use the same lib for there pipeline.
#it is like a common code we are keep somewhere are reuse it by calling it

 
#folder struckture :
#vars-> this directory holds all the global shared library code that can be called in pipeline.all file inside it should have .groovy extention 
#src->directory should look like standard Java source directory structure. This directory is added to the classpath when executing Pipelines.
#resources->all the non-groovy files required for your pipeline can be managed in this folder.

#configure shared library in jenkins inside 'vars'
configure system->Global Pipeline Libraries->add->name->shared-library(use this name to load the library in your pipeline project)->default version->main(A default version can be a branch name, a tag, or even a git commit hash)->load implicity->keep it default all section->source code management->put github repo along with credentials to use shared liberarory

#again come to configure syatem->Global Pipeline Libraries->note the currently map revision ->go to shared libraries git repo ->check the latest comment->it will contain the map revision number->it means mapping is successful--> DONE

#configure it inside pipeline
#before using shared library 
pipeline {
    agent any
    stages {
        stage('Example') {
            steps {
                sh 'echo Hello World'
            }
        }
    }
}


shared library inside--> https://github.com/darinpope/github-api-global-lib
#below used file path inside git  gitrepo-name/vars/helloWorld.groovy
#inside 'helloWorld.groovy:'
def call(Map config = [:]) {
    sh "echo Hello ${config.name}. Today is ${config.dayOfWeek}."
}

#after using shared library inside pipeline 

@Library('shared-library') _  #this _ means inside liberary everything 

def config = [name: 'Newman', dayOfWeek: 'Friday']  #this name and dayOffWeek will replace  ${config.name} and ${config.dayOfWeek} in shared library or we can use it without variable
pipeline {
    agent any
    stages {
        stage('Example') {
            steps {
                helloWorld(config)

            }
        }
     }
  }

# main output is 'echo Hello Newman. Today is Friday.'

#######################################################################
#if we want to use file from shared library resource section 
#inside '/var/filename.groovy'
def call() {
    def scriptcontents = libraryResource "com/planetpope/scripts/linux/infra.sh" ##->this is location and name of script which we want to send along with jenkins pipeline (will be send with SCM file)
    writeFile file: "infra.sh", text: scriptcontents  
    sh "chmod a+x ./infra.sh"  #->will change mode of this script file 
}

#inside pipeline 
@Library('shared-library') _
stage('Example') {
            steps {
                filename()

            }

