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

  def getDockerTag(){
    def tag = sh script: 'git rev-parse HEAD', returnStdout: true
    return tag
  }

  environment {
     DOCKER_TAG = getDockerTag()
  }

  node(POD_LABEL) {
    stage('Build with Kaniko') {
      git 'https://github.com/faridsaad/jenkins.git'
      container('kaniko') {
        sh '/busybox/cat /kaniko/.docker/config.json'
        sh '/kaniko/executor --verbosity=debug -f `pwd`/Dockerfile -c `pwd` --insecure --skip-tls-verify --cache=true --destination=faridsaad/myimage:${DOCKER_TAG}'
      }
    }
  }
}
