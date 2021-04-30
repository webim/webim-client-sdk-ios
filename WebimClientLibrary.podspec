Pod::Spec.new do |s|

  s.name = 'WebimClientLibrary'
  s.version = '3.34.4'
  
  s.author = { 'Webim.ru Ltd.' => 'n.lazarev-zubov@webim.ru' }
  s.homepage = 'https://webim.ru/integration/mobile-sdk/ios-sdk-howto/'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.summary = 'Webim.ru client SDK for iOS.'
  
  s.ios.deployment_target = '10.0'
  s.swift_version = '5.0'
  s.source = { :git => 'https://github.com/webim/webim-client-sdk-ios.git', :tag => s.version.to_s }
  
  s.dependency 'SQLite.swift', '0.12.2'
  s.frameworks = 'Foundation'
  s.source_files = 'WebimClientLibrary/**/*'

end
