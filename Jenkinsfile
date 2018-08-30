pipeline {
  agent any
  environment {
    PATH = "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
  }
  stages {
    stage ('Checkout') {
      steps {
        checkout scm
      }
    }

    stage ('Install Gems') {
      steps {
        sh 'bundle install'
      }
    }

    stage ('Test') {
      steps {
        sh 'bundle exec fastlane test'
      }
    }

    stage ('Generate Docs') {
      when {
        anyOf {
          buildingTag()
          branch 'release/*'
          branch 'master'
        }
      }
      steps {
        sh 'bundle exec fastlane update_docs'
        publishHTML (target: [
          allowMissing: true,
          alwaysLinkToLastBuild: false,
          keepAll: true,
          reportDir: 'docs',
          reportFiles: 'index.html',
          reportName: "Documentation"
        ])
      }
    }
  }
  post {
        always {
          archiveArtifacts artifacts: 'fastlane/test_output/report.html'
          junit allowEmptyResults: true, testResults: 'fastlane/test_output/report.junit'

          publishHTML (target: [
            allowMissing: true,
            alwaysLinkToLastBuild: false,
            keepAll: true,
            reportDir: 'fastlane/test_output/xcov',
            reportFiles: 'index.html',
            reportName: "XCov Report"
          ])

          publishHTML (target: [
            allowMissing: true,
            alwaysLinkToLastBuild: false,
            keepAll: true,
            reportDir: 'fastlane/test_output',
            reportFiles: 'report.html',
            reportName: "Test Report"
          ])
        }
    }
}
