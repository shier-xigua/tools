pipeline {
    agent { label "pod" }
    options { 
        buildDiscarder(logRotator(numToKeepStr: '10'))
		disableConcurrentBuilds()
		timeout(time: 20, unit: 'MINUTES')
		gitLabConnection('gitlab')
    }
    environment {
        IMAGE_NAME= "swr.cn-south-1.myhuaweicloud.com/lz/job:v3"
        HUAWEIYUN = credentials('huaweiyun-swr')
    }
    stages {
        stage('printenv') {
            steps {
                sh "printenv"
            }
        }
        stage('checkout') {
            steps {
                container('tools') {
                    checkout scm    
                }
            }
        }
        stage('login huaweiyun') {
            steps {
                container('tools') {
                    sh "docker login -u cn-south-1@${HUAWEIYUN_USR} -p${HUAWEIYUN_PSW} swr.cn-south-1.myhuaweicloud.com"
                }
            }
        }
        stage('build image') {
            steps {
                container('tools') {
                    sh "docker build . -t ${IMAGE_NAME}"
                }
            }
        }
        stage('push image') {
            steps {
                container('tools') {
                    sh "docker push ${IMAGE_NAME}"
                }
            }
        }
    }
    post {
        success {
           sh "echo '构建镜像成功'" 
        }
        failure {
           sh "echo '构建镜像失败'"
        }
        always {
           sh "echo 'pipeline 结束'"
        }
    }
}


