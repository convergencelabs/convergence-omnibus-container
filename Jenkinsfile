nodePod { label ->
  runInNode(label) {
    container('node') {
      npmLogin()

      stage('NPM Install') {
        sh 'npm install'
      }

      stage('Perpare Docker Build') {
        sh '''
        cp -a docker docker-build
        '''
      }

      stage('Copy Admin Console') {
        sh 'cp -a node_modules/@convergence-internal/admin-console/www/ docker-build/admin-console'
      }

      stage('Copy Client') {
        sh '''
        mkdir docker-build/client
        cp -a node_modules/@convergence/convergence/convergence.global.js docker-build/client/convergence.js
        cp -a node_modules/@convergence/convergence/convergence.amd.js docker-build/client/convergence.amd.js
        cp -a node_modules/rxjs/bundles/* docker-build/client/
        '''
      }

      stage('Copy API') {
        sh '''
        cp -a node_modules/@convergence/convergence/docs docker-build/api
        '''
      }
    }
  }
}

sbtPod { label ->
  runInNode(label) {

    stage('Fetch Server') {
      container('sbt') {
        injectIvyCredentials();
        sh 'sbt fetchServerNode'
      }
    }

    def containerName = "convergence-de"
    stage('Docker Build') {
      container('docker') {
        dir('docker-build') {
          dockerBuild(containerName)
        }
      }
    }

    stage('Docker Push') {
      container('docker') {
        dockerPush(containerName, ["latest", env.GIT_COMMIT])
      }
    }
  }
}
