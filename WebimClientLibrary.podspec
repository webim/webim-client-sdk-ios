Pod::Spec.new do |s|

  s.name             = 'WebimClientLibrary'
  s.version          = '3.4.0'
  s.summary          = 'Webim.ru client SDK for iOS.'
  s.homepage         = 'https://webim.ru/integration/mobile-sdk/ios-sdk-howto/'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Webim.ru Ltd.' => 'n.lazarev-zubov@webim.ru' }
  s.source           = { :git => 'https://github.com/webim/webim-client-sdk-ios.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'WebimClientLibrary/**/*'

  s.frameworks = 'Foundation'

  s.dependency 'SQLite.swift'
  s.dependency 'CryptoSwift'

end
