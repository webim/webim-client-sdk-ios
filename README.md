# WebimClientLibrary

This library provides [_Webim SDK_ for _iOS_](https://webim.ru/integration/mobile-sdk/ios-sdk-howto/).

## Installation

_WebimClientLibrary_ is available through [_CocoaPods_](http://cocoapods.org). To install it, simply add the following line to your **Podfile**:
```
pod 'WebimClientLibrary', :git => 'https://github.com/webim/webim-client-sdk-ios.git', :tag => '3.1.2'
```

In the "Build Settings" of your project in the "Swift Compiler – Language" "Swift Language Version" for _WebimClientLibrary_ target must be setted to "Swift 4.0".

### Objective-C

Trying to integrate _WebimClientLibrary_ into your Objective-C code? Try out our [_WebimClientLibraryWrapper_](https://github.com/webim/webim-client-sdk-ios-wrapper).

> Previous _Objective-C_ version (version numbers 2.x.x) can be reached from **version2** branch.

> If you're already using previous version and don't plan to jump on the new one you don't have to update your **Podfile**, depencies on version numbers 2.7.0 and lower will work properly. But for all renewals of the previous version usage, you have to switch your depency on the **version2** branch.

## Example

To run the example project, clone the repo and run `pod install` from the **Example** directory first.

If you don't have _CocoaPods_ installed you should firstly run `sudo gem install cocoapods`.

> At the moment this example is not a perfectly working app, but it gives an idea of SDK logics and guides a developer of a real app for proper usage of provided classes and methods.

## Usage

### Session

SDK functionality usage starts with session object creating.

`Webim` class method `newSessionBuilder()` returns session builder object (class `SessionBuilder`) (both of this classes and their methods are described inside **Webim.swift** file). Then setting session parameters methods are to be called on the created `SessionBuilder` object. After all necessary parameters are set, method `build()` is to be called. This method returns `WebimSession` object.

Typical usage example:
```
let webimSession = try Webim.newSessionBuilder().set(accountName: "ACCOUNT_NAME").set(location: "LOCATION_NAME").build()
```

All parameters that can be set while creating a session and all errors that can be thrown are also described in **Webim.swift** file. Account name and locations are the only required of them.

After the session is created it must be started by `resume()` method (since a session object is initially paused).

Session can be paused (`pause()` method) and resumed (`resume()` method) as well as destroyed (`destroy()` method) if necessary. All of this methods are described in **WebimSession.swift** file.

### MessageStream

All message stream methods are described in **MessageStream.swift** file.

For this methods usage ability the `MessageStream` class object is have to be getted through `getStream()` method by `WebimSession` class object.

Methods examples:
`send(message:)` – send message,
`rateOperatorWith(id:,byRating:)` – rate operator,
`closeChat()` – close chat.

### MessageTracker

`new(messageTracker:)`  method by `MessageStream` object creates `MessageTracker` object, which can be used to control a message stream inside an app.

E.g. `getNextMessages(byLimit:,completion:)` method requests a certain amount of messages from the history.

Methods descriptions can be found inside **MessageTracker.swift** file.

### MessageListener

`MessageListener` protocol describes methods which can help to track changes in the message stream. An app must have a class which implements this protocol methods: `added(message:,after:)`, `removed(message:)`, `removedAllMessages()`, `changed(message:,to:)`. This methods are called automatically when new message is added, a message is deleted, all messages are deleted and a message is changed respectively.

Full methods descriptions can be found inside **MessageListener.swift** file.

### Message

`MessageListener` protocol methods operate on `Message` class objects which is described inside **Message.swift** file.

All necessary information about specific message can be getted through  `Message` class objects methods: unique message number (`getID()` method), message text (`getText()` method), attached file info (`getAttachment()` method) etc.

All related tools (methods for working with attachments, message types etc.) are also described in **Message.swift** file.

### Additional features

Methods for getting information about specific operator are described inside**Operator.swift** file. Operator object can be getted through `MessageStream` object `getCurrentOperator()` method.

Methods for working with remote notifications by _Webim_ service are described inside **WebimRemoteNotification.swift** file.

Specific remote notification object can be getted through `Webim` class `parse(remoteNotification:)` method. This class also has method `isWebim(remoteNotification:)` which can be used to easily discover whether the notification is send by _Webim_ service or not.

**FatalErrorHandler.swift** contains `FatalErrorHandler` protocol description. Its methods can be implemented by an app for tracking errors which can arise in progress. All kinds of specific errors are described inside the same file.

**MessageStream.swift** also contains additional protocols descriptions which can be implemented by an app classes for tracking different particular changes. E.g. `ChatStateListener` protocol methods are called when chat state is changed (all the specific chat states are described in the same file).

### Conclusion

Entities and methods described above are all that it necessary for working in an app with _Webim_ service and even more.

Abilities described In this manual are not all of the existing ones, so after necessary minimum is implemented it is recommended to get acquainted with full list of protocols and methods listed in SDK public files.

All public interfaces, classes and methods are described inside 10 files (in alphabetical order):
* **FatalErrorHandler.swift**,
* **Message.swift**,
* **MessageListener.swift**,
* **MessageStream.swift**,
* **MessageTracker.swit**,
* **Operator.swift**,
* **Webim.swift**,
* **WebimError.swift**,
* **WebimRemoteNotification.swift**,
* **WebimSession.swift**.

There's no need in every class, protocol, method etc. description in this manual because all them have exhaustive descriptions inside SDK public files.

## Additional information

_WebimClientLibrary_ uses [_SQLite.swift_](https://github.com/stephencelis/SQLite.swift). (There's no need to add an appropriate depency in Podfile.)

In the sake of ease of several functionalities implementation Example app uses:
* [_Cosmos_](https://github.com/evgenyneu/Cosmos) – for visual implementation of operator rating mechanism.
* [_PopupDialog_](https://github.com/Orderella/PopupDialog) – for implemetation of pop-up dialogs.
* [_SnapKit_](https://github.com/SnapKit/SnapKit) – for AutoLayout mechanism implementation inside the code.
* [_SlackTextViewController_](https://github.com/slackhq/SlackTextViewController) – for chat stream displaying inside Table View.
* [_Timberjack_](https://github.com/andysmart/Timberjack) – for logging of outgoing network requests and appropriate server responses.


## License

_WebimClientLibrary_ is available under the MIT license. See the LICENSE file for more info.
