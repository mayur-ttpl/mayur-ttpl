pipeline {
    agent {
        label "master"
    }
     parameters {
        choice(
            name: 'Infra_env',
            choices: ['dev','prod','uat'],
            description: 'Name of the app infra to create'
        )
        choice(
            name: 'App_name',
            choices: ['Segue','Puerto','IdentityConnectorApi','InventoryManagementConnectorApi','ClinicianMobileApp','DocumentServiceApi'],
            description: 'Name of the app of which you want to create the infrastructure of' 
        )
        choice(
            name: 'Operations',
            choices: ['create', 'destroy'],
            description: 'Select whether you want to create or destroy the infrastructure'
        )
    }

    stages {
        stage('terraform-plan-for-create') {
            when {
                expression { 
                    return ( ( params.Operations == 'create'))
                }
            }
            steps {
                dir("${App_name}/${Infra_env}") {
                    script {
                        sh "terraform init"
                        sh "terraform plan"
                    }
                }
            }
        }

        stage("review-and-approve") {
            when {
                allOf {
                    expression { env.GIT_BRANCH == 'origin/main' }
                }
            }
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    input "Have you reviewed the terraform plan for changes? Do you want to proceed with it?"
                }
            }
        }

        stage('terraform-apply') {
            when {
                allOf {
                    expression { params.Operations == 'create' }
                    expression { env.GIT_BRANCH == 'origin/main' }
                }
            }

            steps {
                dir("${App_name}/${Infra_env}") {
                    script {
                        sh "terraform apply -auto-approve"
                    }
                    // archiveArtifacts 'terraform_apply_logs'
                }
            }
        }

        stage('terraform-plan-for-destroy') {
            when {
                allOf{
                    expression { params.Operations == 'destroy' }
                }
            }

            steps {
                dir("${App_name}/${Infra_env}") {
                    script {
                        sh "terraform plan -destroy"             
                    }
                }
            }
        }

        stage('terraform-destroy') {
            when {
                allOf{
                    expression { params.Operations == 'destroy' }
                    expression { env.GIT_BRANCH == 'origin/main' }
                }
            }

            steps {
                dir("${App_name}/${Infra_env}") {
                    script {
                        sh "terraform destroy -auto-approve"             
                    }
                }
            }
        }
        
        

 }
}
