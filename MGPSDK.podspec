Pod::Spec.new do |s|
  s.name         = "MGPSDK"
  s.version      = "1.1.1"
  s.summary      = "Gateway iOS SDK"
  s.description  = <<-DESC
    Our iOS SDK allows you to easily integrate payments into your Swift iOS app. By updating a hosted session directly with the Gateway, you avoid the risk of handling sensitive card details on your server.
  DESC
  s.homepage     = "https://github.com/Mastercard-Gateway/gateway-ios-sdk"
  s.license      = { :type => "Apache-2.0", :file => "LICENSE" }
  s.author             = { "Mastercard Payment Gateway Services" => "" }
  s.social_media_url   = ""
  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.9"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"
  s.swift_version = '5.0'
  s.source       = { :git => "https://github.com/Mastercard-Gateway/gateway-ios-sdk.git", :tag => s.version.to_s }
  s.source_files  = "Sources/**/*"
  s.frameworks  = "Foundation"
  s.pod_target_xcconfig = {
    'APPLICATION_EXTENSION_API_ONLY' => 'YES'
  }
end
