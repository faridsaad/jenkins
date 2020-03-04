/**
 * This pipeline will build and deploy a Docker image with Kaniko
 * https://github.com/GoogleContainerTools/kaniko
 * without needing a Docker host
 *
 * You need to create a jenkins-docker-cfg secret with your docker config
 * as described in
 * https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/#create-a-secret-in-the-cluster-that-holds-your-authorization-token
 */

podTemplate(yaml: """
kind: Pod
spec:
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug-v0.16.0
    imagePullPolicy: Always
    command:
    - /busybox/cat
    tty: true
    volumeMounts:
      - name: jenkins-docker-cfg
        mountPath: /kaniko/.docker
    env:
    - name: DOCKER_CONFIG
      value: /kaniko/.docker
  volumes:
  - name: jenkins-docker-cfg
    secret:
      secretName: regcred
      items:
      - key: .dockerconfigjson
        path: config.json
"""
  ) {


    node(POD_LABEL) {

    stage('Build with Kaniko') {
      environment {
      }

      git 'https://github.com/faridsaad/jenkins.git'

      def DOCKER_TAG = sh script: 'git rev-parse HEAD', returnStdout: true
      sh "echo Tag1 - ${DOCKER_TAG}"
      sh "echo ${DOCKER_TAG} > commit-id.txt"

      container('kaniko') {
        sh "/kaniko/executor --verbosity=debug -f `pwd`/Dockerfile -c `pwd` --insecure --skip-tls-verify --cache=true --destination=faridsaad/myimage:${DOCKER_TAG}"
      }

    }

    stage('Deploy app') {
        cat commit-id.txt
        def DOCKER_TAG = readFile('commit-id.txt').trim()
        sh "echo Tag2 - ${DOCKER_TAG}"
        kubernetesDeploy(configs: "*.yaml", kubeconfigId: "jenkins-kubeconfig", enableConfigSubstitution: true)
    }

    stage('Test app') {
        httpRequest consoleLogResponseBody: true, responseHandle: 'NONE', url: 'http://myapp.default.svc.cluster.local', validResponseContent: 'Hello'
    }

  }
}

//         DOCKER_TAG = """${sh(script: 'git rev-parse HEAD', returnStdout: true)}"""
    def getDockerTag(){
      def tag = sh script: 'git rev-parse HEAD', returnStdout: true
      return tag
    }
