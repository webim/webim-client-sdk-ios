Pod::Spec.new do |s|
  s.name             = 'WebimClientLibrary'
  s.version          = '2.8.0'
  s.summary          = 'Webim.ru client SDK for iOS.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://webim.ru/integration/mobile-sdk/ios-sdk-howto/'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'WEBIM.RU Ltd' => 'vbeskrovnyy@webim.ru' }
  s.source           = { :git => 'https://vbeskrovnyy@stash.olegb.ru/scm/WEBIMCLNTIOS/webim-client-sdk-ios.git', :tag => s.version.to_s }

  s.platform = :ios, '5.0'

  s.source_files = 'WebimClientLibrary/**/*'
  s.public_header_files =	'WebimClientLibrary/WMBaseSession.h',
				'WebimClientLibrary/WMChat.h',
				'WebimClientLibrary/WMMessage.h',
				'WebimClientLibrary/WMOfflineSession.h',
				'WebimClientLibrary/WMOperator.h',
				'WebimClientLibrary/WMSession.h',
                                'WebimClientLibrary/WMFileParams.h',
                                'WebimClientLibrary/WMImageParams.h',
                                'WebimClientLibrary/WMImageSize.h'
  s.dependency 'AFNetworking', '< 2.0.0'

  s.prefix_header_contents = <<-PREF
#ifdef __OBJC__
#import "NSObject+Block.h"
#endif
                                PREF
end
