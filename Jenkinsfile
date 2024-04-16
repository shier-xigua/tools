pipeline {
    agent{
        kubernetes{
            label "jenkins-agent"
            cloud 'twelve'
            yaml '''
---
apiVersion: "v1"
kind: "Pod"
metadata:
  labels:
    jenkins: "slave"
    jenkins/label: "jenkins-agent"
  name: "agent"
  namespace: "jenkins"
spec:
  initContainers:
  - name: alpine
    image: alpine:3.9
    imagePullPolicy: IfNotPresent
    command: ["sh","-c","chown -R 1000:1000 /home/jenkins/agent"]
    volumeMounts:
    - name: workspace-volume
      mountPath: "/home/jenkins/agent"
  containers:
  - name: "tools"
    args:
    - "9999"
    command:
    - "sleep"
    image: "swr.cn-south-1.myhuaweicloud.com/lz/job:sonar"
    imagePullPolicy: "IfNotPresent"
    resources: {}
    volumeMounts:
    - mountPath: "/usr/lib/sonar-scanner/conf"
      name: "volume-2"
      readOnly: false
    - mountPath: "/var/run/docker.sock"
      name: "volume-1"
      readOnly: false
    - mountPath: "/root/.kube"
      name: "volume-0"
      readOnly: false
    - mountPath: "/home/jenkins/agent"
      name: "workspace-volume"
      readOnly: false
    workingDir: "/home/jenkins/agent"

  - name: "jnlp"
    image: "jenkins/inbound-agent:3206.vb_15dcf73f6a_9-2"
    imagePullPolicy: "IfNotPresent"
    env:
      - name: JENKINS_AGENT_WORKDIR
        value: /home/jenkins/workspace
    resources:
      requests:
        memory: "256Mi"
        cpu: "100m"
    volumeMounts:
    - mountPath: "/home/jenkins/agent"
      name: "workspace-volume"
      readOnly: false
  hostNetwork: false
  nodeSelector:
    agent: "true"
  restartPolicy: "Never"
  volumes:
  - configMap:
      name: "admin-kubeconfig"
      optional: false
    name: "volume-0"
  - configMap:
      name: "sonar"
      optional: false
    name: "volume-2"
  - hostPath:
      path: "/var/run/docker.sock"
    name: "volume-1"
  - hostPath:
      path: "/opt/jenkins-agent"
    name: "workspace-volume"
'''
        }
    }
    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
		disableConcurrentBuilds()
		timeout(time: 30, unit: 'MINUTES')
    }
    environment {
        IMAGE_NAME= "swr.cn-south-1.myhuaweicloud.com/lz/job:sonar"
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
        stage('deploy') {
            steps {
                container('tools') {
                    sh "sed -i 's#{{ IMAGE }}#${IMAGE_NAME}#g' deploy/*"
                    timeout(time: 1, unit: 'MINUTES') {
                        sh "kubectl apply -f deploy/"
                    }
                }
            }
        }
        stage('kubectl') {
            steps {
                container('tools') {
                    sh "kubectl get pod -n jenkins"
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

