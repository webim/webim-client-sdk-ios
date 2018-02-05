Pod::Spec.new do |s|
    
    s.name = 'WebimClientLibrary'
    s.version = '2.10.1'
    
    s.author = { 'WEBIM.RU Ltd' => 'n.lazarev-zubov@webim.ru' }
    s.homepage = 'https://webim.ru/integration/mobile-sdk/ios-sdk-howto/'
    s.license = { :type => 'MIT', :file => 'LICENSE' }
    s.summary = 'Webim.ru client SDK for iOS.'
    
    s.platform = :ios, '5.0'
    s.source = { :git => 'https://github.com/webim/webim-client-sdk-ios.git', :tag => s.version.to_s }
    
    s.dependency 'AFNetworking', '< 2.0.0'
    s.source_files = 'WebimClientLibrary/**/*'
    s.public_header_files = 'WebimClientLibrary/WMBaseSession.h',
                            'WebimClientLibrary/WMChat.h',
                            'WebimClientLibrary/WMMessage.h',
                            'WebimClientLibrary/WMOfflineSession.h',
                            'WebimClientLibrary/WMOperator.h',
                            'WebimClientLibrary/WMSession.h',
                            'WebimClientLibrary/WMFileParams.h',
                            'WebimClientLibrary/WMImageParams.h',
                            'WebimClientLibrary/WMImageSize.h'
    
    s.prefix_header_contents = <<-PREF
    #ifdef __OBJC__
    #import "NSObject+Block.h"
    #endif
                                  PREF
    
end
