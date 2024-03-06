pipeline{
    agent any

    parameters {
        choice(
            name: 'apply_or_destroy',
            choices: ['apply', 'destroy']
        )
        string(name: '')

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
            sh "terraform -var 'name=${params.name}' ${params.apply_or_destroy} -auto-approve"
        }
      }
    }
    stage('Add id tag'){
        steps {
            script{
                if (params.apply_or_destroy == 'apply'){
                def instance_id = sh(script: 'terraform show -json | jq -r .values.root_module.resources[0].values.id', returnStdout: true).trim()
                sh """sed -i 's/\\(^ *instance_type *= *"t2.micro" *\\)/\\1\\n  tags = {\\n    InstanceId = \\"${instance_id}\\" \\n  }/' main.tf"""
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