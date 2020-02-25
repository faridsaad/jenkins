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
    image: gcr.io/kaniko-project/executor:debug-a1af057f997316bfb1c4d2d82719d78481a02a79
    imagePullPolicy: Always
    command:
    - /busybox/cat
    tty: true
    volumeMounts:
      - name: jenkins-docker-cfg
        mountPath: /kaniko/.docker
    env:
    - name: DOCKER_CONFIG
      value: /kaniko/.docker/
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
      git 'https://github.com/faridsaad/jenkins.git'
      container('kaniko') {
        sh '/busybox/cat /kaniko/.docker/config.json'
        sh '/kaniko/executor -f `pwd`/Dockerfile -c `pwd` --insecure --skip-tls-verify --cache=true --destination=faridsaad/myimage:1'
      }
    }
  }
}

