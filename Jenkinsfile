pipeline{
    agent any
    
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
    }
    stage('terraform apply or destroy'){
        steps {
            withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', 
            accessKeyVariable: 'AWS_ACCESS_KEY_ID',
            credentialsId: 'aws_creds', 
            secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
            sh "terraform apply -auto-approve"
        }
      }
    }
    stage('Add id tag'){
        steps {
            script{
                sh"""
                    instance_id=$(terraform show -json | jq -r .values.root_module.resources[0].values.id)
                    sed -i '/^ *instance_type *= *\"t2.micro\"/a \ \ tags = {\n    InstanceId = '\"$instance_id\"'\n  }' your_script_file.tf
                """

            }
        }
    }
    stage('terraform apply and add the id'){
        steps {
            withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', 
            accessKeyVariable: 'AWS_ACCESS_KEY_ID',
            credentialsId: 'aws_creds', 
            secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
            sh "terraform apply -auto-approve"
        }
      }
    }
}