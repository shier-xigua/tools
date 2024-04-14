pipeline {
    agent { label: 'pod' }
    options { 
        buildDiscarder(logRotator(numToKeepStr: '10'))
		disableConcurrentBuilds()
		timeout(time: 20, unit: 'MINUTES')
		gitLabConnection('gitlab')
    }
    envirment {
        IMAGE_NAME= 'swr.cn-south-1.myhuaweicloud.com/lz/job:v3'
        DINGTALK_CREDS = credentials('ding')
        HUAWEIYUN = credentials('huaweiyun-swr')
    }
    stages {
        stage('printenv') {
            steps {
                sh 'printenv'
            }
        }
        stage('cheout') {
            steps {
                cheout scm
            }
        }
        stage('login huaweiyun') {
            steps {
                sh 'docker login -u cn-south-1@HUAWEIYUN_USR -p HUAWEIYUN_PSW swr.cn-south-1.myhuaweicloud.com'
            }
        }
        stage('build image') {
            steps {
                sh 'docker build . -t ${IMAGE_NAME}'
            }
        }
        stage('push image') {
            steps {
                sh 'docker push ${IMAGE_NAME}'
            }
        }
    }
    post {
        success {
           sh '构建镜像成功' 
        }
        failure {
           sh '构建镜像失败'
        }
        always {
           sh 'pipeline 结束'
        }
    }
}
