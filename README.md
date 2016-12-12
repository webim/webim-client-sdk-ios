# WebimClientLibrary

This library provides [Webim SDK for iOS](https://webim.ru/help/mobile-sdk/ios-sdk-howto/)

## Installation

WebimClientLibrary is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'WebimClientLibrary', :git => 'https://github.com/webim/webim-client-sdk-ios.git', :tag => '2.4.4'
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.
Example application works with demo account. If you are registered user, you can use your account name (see development section)

Webim SDK supports two kinds of chats:
- Realtime chat (when requires immediate response from operator)
- Offline chat (when there are no online operators, will be replied later)

Both could be initiated using SDK's so called "sessions" - WMSesssion and WMOfflineSession. Please, read documentation at [Webim SDK for iOS](https://webim.ru/help/mobile-sdk/ios-sdk-howto/)

### Development
Sample app initializes both online and offline sessions. Depending on your needs, you can use only one of them. Look at WebimController.m for initializing code.

##### Online/Realtime chat
When using realtime session, only one chat is available.
Create that session with your account settings:
- account name
- location
- user fields
- delegate object
Specify your delegate object, which will be informed about changes on your realtime session: new message, start/stop chat, etc..

##### Offline Chat
Offline chats doesn't update unless getHistory* method is called. Thus, your application is responsible for setting updates events for offline chats. History updates a list of chats available for your user.

##### Push Notifications
To be able to receive push notifications, enable them for your app and contact with support team.

## License

webim-client-sdk-ios is available under the MIT license. See the LICENSE file for more info.
