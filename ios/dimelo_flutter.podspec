Pod::Spec.new do |s|
  s.name             = 'dimelo_flutter'
  s.version          = '0.0.2'
  s.summary          = 'Dimelo Flutter plugin'
  s.description      = 'Flutter plugin to integrate Dimelo-iOS SDK'
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }

  # All plugin source files
  s.source_files     = 'Classes/**/*'

  # Dependencies
  s.dependency 'Flutter'
  s.dependency 'Dimelo-iOS', '2.8.8'

  # iOS deployment target
  s.ios.deployment_target = '15.0'

  # Required for Flutter static frameworks
  s.static_framework = true

  # Swift version
  s.swift_version = '5.0'

  # Only your plugin’s resources
  s.resource_bundles = {
    'dimelo_flutter_privacy' => ['Resources/PrivacyInfo.xcprivacy']
  }

  # Enable module import
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
end
