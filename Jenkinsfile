pipeline{
    agent any

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
            sh "terraform ${params.apply_or_destroy} -var 'name=${params.name}' -auto-approve"
        }
      }
    }
    stage('Add id tag'){
        steps {
            script{
                if (params.apply_or_destroy == 'apply'){
                def instance_id = sh(script: 'terraform show -json | jq -r .values.root_module.resources[0].values.id', returnStdout: true).trim()

// Escape double quotes in instance_id
def escaped_instance_id = instance_id.replaceAll('"', '\\\\\\"')

sh """awk '
  /^ *tags = {/ {
    getline
    sub(\\(^ *InstanceId *= *\\\\\\\\).*, "\\1\\"${escaped_instance_id}\\"")
  }
  1' main.tf > main.tf.tmp && mv main.tf.tmp main.tf"""



    
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
                        }
                    }
                }
            }
        }
    }
}