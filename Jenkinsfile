node {
  stage 'Checkout'
  checkout scm

  stage 'Test'
  sh 'xcodebuild clean build test -workspace MPGSDK.xcworkspace -scheme MPGSDK-iOS -destination "platform=iOS Simulator,name=iPhone X"  | /usr/local/bin/xcpretty -r junit'
  junit allowEmptyResults: true, testResults: 'build/reports/junit.xml'
}
