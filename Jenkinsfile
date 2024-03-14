pipeline{
    agent any
    // tools {
    //   terraform 'terraform'
    // }
    parameters {
        choice(
            name: 'apply_or_destroy',
            choices: ['apply', 'destroy']
        )
        string(name: 'name')

    }
    stages{

    stage('tf init before ID tag'){
        steps {
            withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', 
            accessKeyVariable: 'AWS_ACCESS_KEY_ID',
            credentialsId: 'aws_creds', 
            secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
            sh "terraform init -upgrade -reconfigure"
                } 
            }
        }
    stage('terraform apply or destroy'){
        steps {
            withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', 
            accessKeyVariable: 'AWS_ACCESS_KEY_ID',
            credentialsId: 'aws_creds', 
            secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
            sh "terraform ${params.apply_or_destroy} -auto-approve"
        }
      }
    }
    stage('Add id tag'){
        steps {
            script{
                if (params.apply_or_destroy == 'apply'){
                    def instance_id = sh(script: 'terraform show -json | jq -r .values.root_module.resources[0].values.id', returnStdout: true).trim()
                    sh """sed -i 's/\\(^ *instance_type *= *"t2.micro" *\\)/\\1\\n  tags = {\\n    InstanceId = \\"${instance_id}\\" \\n  }/' main.tf"""
                    sh """sed -i '/^ *tags = {/ {n; s/\\(^ *InstanceId *=.*\\)/\\1\\n    name = \\"${name}\\"/}' main.tf"""

                }
            }
        } 
    }
    stage('terraform apply and add the id'){
        steps {
            script{
            if (params.apply_or_destroy == 'apply'){
            withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', 
            accessKeyVariable: 'AWS_ACCESS_KEY_ID',
            credentialsId: 'aws_creds', 
            secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
            sh "terraform apply -auto-approve"
            sh "terraform apply -var 'name=${params.name}' -auto-approve"
                        }
                    }
                }
            }
        }
    }
}