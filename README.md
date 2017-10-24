# WebimClientLibrary

This library provides [Webim SDK for iOS](https://webim.ru/help/mobile-sdk/ios-sdk-howto/)

## Installation

WebimClientLibrary is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'WebimClientLibrary', :git => 'https://github.com/webim/webim-client-sdk-ios.git', :tag => '2.7.0'
```

> Latest _Swift_ version can be found at **master** branch.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.
Example application works with _demo_ account. If you are registered user, you can use your account name (see development section).

Webim SDK supports two kinds of chats:
- Realtime chat (when requires immediate response from operator).
- Offline chat (when there are no online operators, will be replied later).

Both could be initialized using SDK's so called "sessions" - `WMSesssion` and `WMOfflineSession`. Please, read documentation at [Webim SDK for iOS](https://webim.ru/help/mobile-sdk/ios-sdk-howto/)

### Development

Sample app initializes both online and offline sessions. Depending on your needs, you can use only one of them. Look at **WebimController.m** for initializing code.

##### Online/Realtime chat
When using realtime session, only one chat is available.
Create that session with your account settings:
- account name,
- location,
- user fields,
- delegation object.
Specify your delegate object, which will be informed about changes on your realtime session: new message, start/stop chat etc.

##### Offline Chat
Offline chats doesn't update unless `getHistory` method is called. Thus, your application is responsible for setting updates events for offline chats. History updates a list of chats available for your user.

##### Push Notifications
To be able to receive push notifications, enable them for your app and contact with support team.

## Usage

### Structure

APIs are collected inside `WMSesssion` class, which notifies an app of chat state changes through delegation mechanism. To start it is necessary to initialize a session object and provide a delegate for this object. Any view controller which manages chat views can become session delegate and track session changes. Delegate must conform `WMSessionDelegate` which is described inside **WMSession.h** file.

One should also be regisered user of _Webim_ service and have account name and location name to use in the app. `WMSession` object works with only one specific location.

Session can be initialized by this method:
```
- (id)initWithAccountName:(NSString *)accountName location:(NSString *)location delegate:(id<WMSessionDelegate>)delegate visitorFields:(NSDictionary *)visitorFields;
```

Parameter accountName is one's accountName (e.g. "demo") or full URL to service API (e.g. "https://demo.webim.ru/") if _Webim_ servide is located on one's domain.

Parameter visitorFields is optional and is used for user identification (see [here](https://webim.ru/help/identification/)). For the proper dictionary keys usage one can use appropriate constants declared in **WMSession.h** file:
```
extern NSString *const WMVisitorParameterDisplayName;
extern NSString *const WMVisitorParameterPhone;
extern NSString *const WMVisitorParameterEmail;
extern NSString *const WMVisitorParameterICQ;
extern NSString *const WMVisitorParameterProfileURL;
extern NSString *const WMVisitorParameterAvatarURL;
extern NSString *const WMVisitorParameterID;
extern NSString *const WMVisitorParameterLogin;
extern NSString *const WMVisitorParameterCRC;
```

Online session uses asynchronous approach with completion handler blocks described as:
```
typedef void (^WMResponseCompletionBlock)(BOOL successful);
```

### Start to work

Session should be started by this method:
```
- (void)startSession:(WMResponseCompletionBlock)block;
```
After the session is started successfully this delegate method will be called:
```
— (void)sessionDidReceiveFullUpdate:(WMSession *)session;
```
This method can be called any time, not only right after session is started. This method calling indicates that all parameters related to work with SDK should be renewed,

Session can be stopped by this method:
```
— (void)stopSession;
```
After this method is called all data renewal and delegate methods calls are ended.

Internal session parameters (such as state, chat, operator) can be changed during the work. This changes are indicated by delegate methods calls. For example:
```
— (void)sessionDidChangeStatus:(WMSession *)session;
```
```
— (void)session:(WMSession *)session didChangeOnlineStatus:(WMSessionOnlineStatus)onlineStatus;
```
```
— (void)session:(WMSession *)session didChangeOperatorTyping:(BOOL)typing;
```

To enable remote notifications device token (getted from APNs) should be passed through one of this methods:
```
+ (void)setDeviceToken:(NSData *)deviceToken;
```
```
— (void)setDeviceToken:(NSData *)deviceToken completion:(WMResponseCompletionBlock)block;
```
```
+ (void)setDeviceTokenString:(NSString *)token;
```

### Chat call

For chat usage it is only one session state can be interesting – `WMSessionStateOfflineMessage`. It means that there are no operators online and chat will be closed. Most likely with the first session start a chat won't be initialized, i.e. `session.chat == nil` or `session.chat.state == WMChatStateUnknown`. Nevertheless chat can exist after repeated initialization. If so one should display this chat – it already contains some messages.

`WMChat` can have several states:
```
 typedef enum {
 WMChatStateUnknown,
 WMChatStateQueue,
 WMChatStateChatting,
 WMChatStateClosed,
 WMChatStateClosedByVisitor,
 WMChatStateClosedByOperator,
 WMChatStateInvitation
 } WMChatState;
```
Chat should be displayed if it have one of this states: `WMChatStateQueue`, `WMChatStateChatting`, `WMChatStateClosedByOperator`. If delegate object monitors chat states any other state causes closing chat. If so all requests (message sending, chat closing etc.) will return an error.

Before chat is started it is necessary to make sure if there are operators online. This can be known by `WMSessionOnlineStatus` type `onlineStatus` property. `WMSessionOnlineStatusOnline` indicates that online chat is possible, `WMSessionOnlineStatusBusyOnline` – that online chat queue is full, `WMSessionOnlineStatusOffline` – that offline chat is possible, `WMSessionOnlineStatusBusyOffline` – that offline chat queue is full.

If chat doesn't exist it can be initialized by session methods:
```
`- (NSString *)startChat:(WMResponseCompletionBlock)block;`
```
```
- (NSString *)startChatWithClientSideId:(NSString *)clientSideId completionBlock:(WMResponseCompletionBlock)completionBlock;
```
For chat local identification one can use `clientSideId` parameter. This is an unique string which can be compared with one that is received in delegate method call. Both of last methods return this parameter. The second one takes `clientSideId` optionally generated by an app. If success depend on chat state one of the following delegate methods will be called:
```
— (void)session:(WMSession *)session didStartChat:(WMChat *)chat;
```
```
— (void)sessionDidChangeChatStatus:(WMSession *)session;
```

### Chat usage

To close chat this method should be used:
```
— (void)closeChat:(WMResponseCompletionBlock)block;
```
It calls appropriate delegate methods and changes the chat state.

Initialized chat contains pointer on array of messages of this chat. Messages are objects of type desribed in **WMMessage.h**. Conditionally they can be divided on messages:
* by visitor,
* by operator,
* system messages.

To send a message one should call this session object method:
```
- (NSString *)sendMessage:(NSString *)message withClientSideId:(NSString *)clientSideId successBlock:(void (^)(NSString *clientSideId))successBlock failureBlock:(void (^)(NSString *clientSideId, WMSessionError error))failureBlock;
```
Method parameters:
* message – message text,
* clientSideId – optional app generated unique ID,
* successBlock – completion that to be called if succeed.
* failureBlock – completion that should be called if failed.
Nethod returns client or SDK generated message unique ID.

After message is delivered or new message is arrived this delegate method is called:
```
— (void)session:(WMSession *)session didReceiveMessage:(WMMessage *)message;
```
When using online session one can get information about an operator from `WMMessage` object through its properties:
* `senderUID` – operator unique ID,
* `senderName` – operator name,
* `senderAvatarURL` – operator avatar image file URL.

Sending file method is similar:
```
- (NSString *)sendFile:(NSData *)fileData name:(NSString *)fileName mimeType:(NSString *)mimeType withClientSideId:(NSString *)clientSideId successBlock:(void (^)(NSString *clientSideId))succcessBlock failureBlock:(void(^)(NSString *clientSideId, WMSessionError error))failureBlock;
```
Mime type should be used as [there](https://iana.org/assignments/media-types/media-types.xhtml). For example: `fileName = @"image.png"` and `mimeType = @"image/png"`.

This kind of messages contain `WMFileParams` type `fileParams` field. This field has attachment description, such as file size and name and content type. If a file is an image `fileParams` has `imageParams` property of type `WMImageParams` (which desribes the image size to download).

For `WMMessageKindFileFromOperator` and `WMMessageKindFileFromVisitor` kinds messages attachment can be downloaded at URL getted through this method call:
```
- (NSURL *)attachmentURLForMessage:(WMMessage *)message;
```

Realtime chat can indicate typing visitor state through this method:
```
— (void)setComposingMessage:(BOOL)isComposing draft:(NSString *)draft;
```
After a call with `isComposing` parameter setted to `YES` the one should call the same method with this parameter setted to `NO` for appropriate displaying information for an operator. Text that typed by visitor at the moment can be passed by `draft` parameter. Empty `draft` parameter clears stored draft.

If operator was changed or takes chat in hand this delegate method is called:
```
— (void)session:(WMSession *)session didUpdateOperator:(WMOperator *)chatOperator
```
History messages operator is undefined.

To refresh chat this session method can be used:
```
— (void)refreshSessionWithCompletionBlock:(WMResponseCompletionBlock)block;
```

This delegate method track possible errors:
```
— (void)session:(WMSession *)session didReceiveError:(WMSessionError)errorID;
```
E.g. if network is unreachable session methods will return `WMSessionErrorNetworkError` error. For network connection status this delegate method is called:
```
— (void)session:(WMSession *)session didChangeConnectionStatus:(WMSessionConnectionStatus)status;
```
The most expected app behavior after connection status is changed are user notification or chat usage limitations.

Operator can be rated through this method:
```
— (void)rateOperator:(NSString *)authorID withRate:(WMOperatorRate)rate completion:(WMResponseCompletionBlock)block;
```
Possible rates are described by:
```
enum WMOperatorRate {
WMOperatorRateOneStar,
WMOperatorRateTwoStars,
WMOperatorRateThreeStars,
WMOperatorRateFourStars,
WMOperatorRateFiveStars
};
```

### Offline mode

Visitor can chat in offline mode. In this case an answer delay is not so important as storaging time and chats handling strategy by a server. `WMOfflineSession` is responsible for this kind of chats. It also should be initialized first:
```
— (id)initWithAccountName:(NSString *)accountName location:(NSString *)location token:(NSString *)token platform:(NSString *)platform visitorFields:(NSDictionary *)visitorFields;
```
`token` parameter is necessary to define the user (i.e. it should be unique). Moreover, this token should not be changed after an app is closed and is open again (otherwise visitor data is lost). If this token is APNs device token _Webim_ service will be sending remote notifications when some event occured. `platform` parameter can be used to define remote notifications way (to use this parameter one should ask _Webim_ service support team).

Chat data is stored inside class property:
```
@property (nonatomic, strong) NSMutableArray *appealsArray;
```
This array contains `WMChat` class objects. Every chat object has a pointer to its messages. Generally chats and messages are sorted by creation date.

For traffic overusage prevention SDK stores its stat on disc. It is supposed that an app will periodically request new messages from server:
```
— (void)getHistoryForced:(BOOL)forced completion:(void (^)(BOOL successful, id changes, NSError *error))block;
```
`forced` parameter shows if all history is wanted to receive. It is not recommended to set this parameter to `YES` too often because it will cause traffic overusage. This (and others) completion block has parameters:
* flag that indicates if request succeeded,
* one or several objects that are supposed to matter if request succeeded.
* error if request failed.
Error can be `Webim` one described by `WMSessionError` inside **WMBaseSession.h** file. The rest can be ones of `NSURLConnection` or fatal server errors (e.g HTTP-code 500).

This `changes` parameter contains modifications occured after the method was call last time. In fact it's a dictionary with keys:
```
extern NSString *const WMOfflineChatChangesNewChatsKey;
```
```
extern NSString *const WMOfflineChatChangesModifiedChatsKey;
```
```
extern NSString *const WMOfflineChatChangesMessagesKey;
```
By the help of this keys the one can detect added or changed chats and messages added to this chats. Chat for message can be retrieved through this method:
```
— (WMChat *)chatForMessage:(WMMessage *)message;
```

To create new chat and send message in existing at app side chat this method can be called:
```
- (void)sendMessage:(NSString *)text inChat:(WMChat *)chat departmentKey:(NSString *)departmentKey onDataBlock:(void (^)(BOOL successful, WMChat *chat, WMMessage *message, NSError *error))block completion:(void (^)(BOOL successful))completion;
```
If `chat` parameter is `nil` this method creates new chat with this one new message. Other way message will be created inside this chat. `onDataBlock` is called after server responce and contains requested new messages and chat objects. `completion` block is called after data is recorded to storage.

Send image method is similar:
```
- (void)sendImage:(NSData *)imageData type:(WMChatAttachmentImageType)type inChat:(WMChat *)chat departmentKey:(NSString *)departmentKey onDataBlock:(void (^)(BOOL successful, WMChat *chat, WMMessage *message, NSError *error))block completion:(void (^)(BOOL successful))completion;
```
`imageData` parameter must contain image of type _png_ or _jpeg_.

Send file method:
```
- (void)sendFile:(NSData *)fileData name:(NSString *)fileName mimeType:(NSString *)mimeType inChat:(WMChat *)chat departmentKey:(NSString *)departmentKey onDataBlock:(void (^)(BOOL successful, WMChat *chat, WMMessage *message, NSError *error))block completion:(void (^)(BOOL successful))completion;
```
This message type is `WMMessageKindFileFromVisitor`.

Image can be loaded through this method:
```
— (void)dowloadImageForMessage:(WMMessage *)message completion:(void (^)(BOOL successful, UIImage *image, NSError *error))block;
```
Image URL can be retireved through this one:
```
— (NSURL *)attachmentURLForMessage:(WMMessage *)message;
```

SDK does not store attached files. Loading and displaying it is a client app prerogative.

To prevent frequent files' downloading it is recommended to use image cache (inside memory or inside disc storage).

After an operator gave a reply appropriate chat is marked as unreaded. After displaying it to a user it is necessary to mark it as read by calling this session method:
```
— (void)markChatAsRead:(WMChat *)chat completion:(void (^)(BOOL successful, NSError *error))block;
```

Chat can be deleted through this  method:
```
— (void)deleteChat:(WMChat *)chat completion:(void (^)(BOOL successful, NSError *error))block;
```

### User change

Only one offline session can be active. To receive another user data the one should:
* stop requesting history,
* stop monitor session,
* call `[WMSession clearCachedUserData];`,
* create new session,
* request new session history.

## License

_WebimClientLibrary_ is available under the MIT license. See the **LICENSE** file for more info.
