#  _WebimClientLibrary_ Reference Book

-   [Webim class](#webim)
    -   [Class method newSessionBuilder()](#new-session-builder)
    -   [Class method parse(remoteNotification:)](#parse-remote-notification)
    -   [Class method isWebim(remoteNotification:)](#is-webim-remote-notification)
    -   [RemoteNotificationSystem enum](#remote-notification-system)
        -   [APNS case](#apns)
        -   [NONE case](#none)
-   [SessionBuilder class](#session-builder)
    -   [Instance method set(accountName:)](#set-account-name)
    -   [Instance method set(location:)](#set-location)
    -   [Instance method set(appVersion:)](#set-app-version)
    -   [Instance method set(visitorFieldsJSONString jsonString:)](#set-visitor-fields-json-string-json-string)
    -   [Instance method set(visitorFieldsJSONData jsonData:)](#set-visitor-fields-json-data-json-data)
    -   [Instance method set(pageTitle:)](#set-page-title)
    -   [Instance method set(fatalErrorHandler:)](#set-fatal-error-handler)
    -   [Instance method set(remoteNotificationSystem:)](#set-remote-notification-system)
    -   [Instance method set(deviceToken:)](#set-device-token)
    -   [Instance method set(isLocalHistoryStoragingEnabled:)](#set-is-local-history-storaging-enabled)
    -   [Instance method set(isVisitorDataClearingEnabled:)](#set-is-visitor-data-clearing-enabled)
    -   [Instance method build()](#build)
    -   [SessionBuilderError enum](#session-builder-error)
        -   [NIL_ACCOUNT_NAME case](#nil-account-name)
        -   [NIL_LOCATION case](#nil-location)
        -   [INVALID_REMOTE_NOTIFICATION_CONFIGURATION case](#invalid-remote-notification-configuration)
-   [WebimSession protocol](#webim-session)
    -   [resume() method](#resume)
    -   [pause() method](#pause)
    -   [destroy() method](#destroy)
    -   [getStream() method](#get-stream)
    -   [change(location:) method](#change-location)
-   [MessageStream protocol](#message-stream)
    -   [getChatState() method](#get-chat-state)
    -   [getLocationSettings() method](#get-location-settings)
    -   [getCurrentOperator() method](#get-current-operator)
    -   [getLastRatingOfOperatorWith(id:) method](#get-last-rating-of-operator-with-id)
    -   [rateOperatorWith(id:,byRating rating:) method](#rate-operator-with-id-by-rating-rating)
    -   [startChat() method](#start-chat)
    -   [closeChat() method](#close-chat)
    -   [setVisitorTyping(draftMessage:) method](#set-visitor-typing-draft-message)
    -   [send(message:,isHintQuestion:) method](#send-message-is-hint-question)
    -   [send(file:,filename:,mimeType:,completionHandler:) method](#send-file-filename-mime-type-completion-handler)
    -   [new(messageTracker messageListener:) method](#new-message-tracker-message-listener)
    -   [set(chatStateListener:) method](#set-chat-state-listener)
    -   [set(currentOperatorChangeListener:) method](#set-current-operator-change-listener)
    -   [set(operatorTypingListener:) method](#set-operator-typing-listener)
    -   [set(locationSettingsChangeListener:) method](#set-location-settings-change-listener)
    -   [set(sessionOnlineStatusChangeListener:) method](#set-session-online-status-change-listener)
-   [SendFileCompletionHandler protocol](#send-file-completion-handler)
    -   [onSuccess(messageID:) method](#on-success-message-id)
    -   [onFailure(messageID:,error:) method](#on-failure-message-id-error)
-   [LocationSettings protocol](#location-settings)
    -   [areHintsEnabled() method](#are-hints-enabled)
-   [ChatStateListener protocol](#chat-state-listener)
    -   [changed(state previousState:,to newState:) method](#changed-state-previous-state-to-new-state)
-   [CurrentOperatorChangeListener protocol](#current-operator-change-listener)
    -   [changed(operator previousOperator:,to newOperator:) method](#changed-operator-previous-operator-to-new-operator)
-   [OperatorTypingListener protocol](#operator-typing-listener)
    -   [onOperatorTypingStateChanged(isTyping:) method](#on-operator-typing-state-changed-is-typing)
-   [LocationSettingsChangeListener protocol](#location-settings-shange-listener)
    -   [changed(locationSettings previousLocationSettings:,to newLocationSettings:) method](#changed-location-settings-previous-location-settings-to-new-location-settings)
-   [SessionOnlineStatusChangeListener protocol](#session-online-status-change-listener)
    -   [changed(sessionOnlineStatus previousSessionOnlineStatus:,to newSessionOnlineStatus:) method](#changed-session-online-status-previous-session-online-status-to-new-session-online-status)
-   [ChatState enum](#chat-state)
    -   [CHATTING case](#chatting)
    -   [CLOSED_BY_OPERATOR case](#closed-by-operator)
    -   [CLOSED_BY_VISITOR case](#closed-by-visitor)
    -   [INVITATION case](#invitation)
    -   [NONE case](#none-chat-state)
    -   [QUEUE case](#queue)
    -   [UNKNOWN case](#unknown)
-   [SendFileError enum](#send-file-error)
    -   [FILE_SIZE_EXCEEDED case](#file-size-exceeded)
    -   [FILE_TYPE_NOT_ALLOWED case](#file-type-not-allowed)
-   [SessionOnlineStatus enum](#session-online-status)
    -   [BUSY_OFFLINE case](#busy-offline)
    -   [BUSY_ONLINE case](#busy-online)
    -   [OFFLINE case](#offline)
    -   [ONLINE case](#online)
    -   [UNKNOWN case](#unknown-session-online-status)
-   [MessageTracker protocol](#message-tracker)
    -   [getLastMessages(byLimit limitOfMessages:,completion:) method](#get-last-messages-by-limit-limit-of-messages-completion)
    -   [getNextMessages(byLimit limitOfMessages:,completion:) method](#get-next-nessages-by-limit-limit-of-messages-completion)
    -   [getAllMessages(completion:) method](#get-all-messages-completion)
    -   [resetTo(message:) method](#reset-to-message)
    -   [destroy() method](#destroy-message-tracker)
-   [MessageListener protocol](#message-listener)
    -   [added(message newMessage:,after previousMessage:) method](#added-message-new-message-after-previous-message)
    -   [removed(message:) method](#removed-message)
    -   [removedAllMessages() method](#removed-all-messages)
    -   [changed(message oldVersion:,to newVersion:) method](#changed-message-old-version-to-new-version)
-   [Message protocol](#message)
    -   [getAttachment() method](#get-attachment)
    -   [getData() method](#get-data)
    -   [getID() method](#get-id)
    -   [getOperatorID() method](#get-operator-id)
    -   [getSenderAvatarFullURLString() method](#get-sender-avatar-full-url-string)
    -   [getSenderName() method](#get-sender-name)
    -   [getSendStatus() method](#get-send-status)
    -   [getText() method](#get-text)
    -   [getTime() method](#get-time)
    -   [getType() method](#get-type)
    -   [isEqual(to message:) method](#is-equal-to-message)
-   [MessageAttachment protocol](#message-attachment)
    -   [getContentType() method](#get-content-type)
    -   [getFileName() method](#get-file-name)
    -   [getImageInfo() method](#get-image-info)
    -   [getSize() method](#get-size)
    -   [getURLString() method](#get-url-string)
-   [ImageInfo protocol](#image-info)
    -   [getThumbURLString() method](#get-thumb-url-string)
    -   [getHeight() method](#get-height)
    -   [getWidth() method](#get-width)
-   [MessageType enum](#message-type)
    -   [ACTION_REQUEST case](#action-request)
    -   [FILE_FROM_OPERATOR case](#file-from-operator)
    -   [FILE_FROM_VISITOR case](#file-from-visitor)
    -   [INFO case](#info)
    -   [OPERATOR case](#operator)
    -   [OPERATOR_BUSY case](#operator-busy)
    -   [VISITOR case](#visitor)
-   [MessageSendStatus enum](#message-send-status)
    -   [SENDING case](#sending)
    -   [SENT case](#sent)
-   [Operator protocol](#operator-protocol)
    -   [getID() method](#get-id-operator)
    -   [getName() method](#get-name)
    -   [getAvatarURLString() method](#get-avatar-url-string)
-   [WebimRemoteNotification protocol](#webim-remote-notification)
    -   [getType() method](#get-type-webim-remote-notification)
    -   [getEvent() method](#get-event)
    -   [getParameters() method](#get-parameters)
-   [NotificationType enum](#notification-type)
    -   [OPERATOR_ACCEPTED case](#operator-accepted)
    -   [OPERATOR_FILE case](#operator-file)
    -   [OPERATOR_MESSAGE case](#operator-message)
-   [NotificationEvent enum](#notification-event)
    -   [ADD case](#add)
    -   [DELETE case](#delete)
-   [FatalErrorHandler protocol](#fatal-error-handler)
    -   [on(error:) method](#on-error)
-   [FatalErrorType enum](#fatal-error-type)
    -   [ACCOUNT_BLOCKED case](#account-blocked)
    -   [PROVIDED_VISITOR_EXPIRED case](#provided-visitor-fields)
    -   [UNKNOWN case](#unknown-fatal-error-type)
    -   [VISITOR_BANNED case](#visitor-banned)
    -   [WRONG_PROVIDED_VISITOR_HASH case](#wrong-provided-visitor-hash)
-   [WebimError protocol](#webim-error)
    -   [getErrorType() method](#get-error-type)
    -   [getErrorString() method](#get-error-string)
-   [AccessError enum](#access-error)
    -   [INVALID_THREAD case](#invalid-thread)
    -   [INVALID_SESSION case](#invalid-session)

<h2 id="webim">Webim class</h2>

Set of static methods which are used for session object creating and working with remote notifications that are sent by _Webim_ service.

<h3 id="new-session-builder">Class method newSessionBuilder()</h3>

Returns [SessionBuilder class](#session-builder) instance that is necessary to create `WebimSession` class instance.

<h3 id ="parse-remote-notification">Class method parse(remoteNotification:)</h3>

Converts _iOS_ remote notification object into [WebimRemoteNotification](#webim-remote-notification) object.
`remoteNotification` parameter takes `[AnyHashable: Any]` dictionary (which can be taken inside `application(_ application:,didReceiveRemoteNotification userInfo:)` `AppDelegate` class method from `userInfo` parameter).
Method can return `nil` if `remoteNotification` parameter value doesn't fit to _Webim_ service remote notification format or if it doesn't contain any useful payload.
Preliminarily you can call [method isWebim(remoteNotification:)](#is-webim-remote-notification) on this value to know if this notification is send by _Webim_ service.

<h3 id ="is-webim-remote-notification">Class method isWebim(remoteNotification:)</h3>

Allows to know if particular remote notification object represents Webim service remote notification.
`remoteNotification` parameter takes `[AnyHashable: Any]` dictionary (which can be taken inside `application(_ application:,didReceiveRemoteNotification userInfo:)` `AppDelegate` class method from `userInfo` parameter).
Returns `true` or `false`.

<h3 id ="remote-notification-system">RemoteNotificationSystem enum</h3>

Enumerates push notifications systems that can be used with _WebimClientLibrary_. Enum values are used to be passed to [method set(remoteNotificationSystem:)](#set-remote-notification-system) [SessionBuilder class](#session-builder) instance method.

<h4 id ="apns">APNS case</h4>

_Apple Push Notification System_.

<h4 id ="none">NONE case</h4>

App does not receive remote notification from _Webim_ service.

<h2 id ="session-builder">SessionBuilder class</h2>

Instance of this class is used to get [WebimSession](#webim-session) object. [SessionBuilder class](#session-builder) instance can be retreived with [newSessionBuilder()](#new-session-builder) [Webim class](#webim) method.

<h3 id ="set-account-name">Instance method set(accountName:)</h3>

Sets _Webim_ service account name.
`accountName` parameter – `String`-typed account name. Usually is represented by server URL (e.g. "https://demo.webim.ru"), but also can be just one word (e.g. "demo")
Returns `self` with account name set.
Method is mandatory to create [WebimSession](#webim-session) object.

<h3 id ="set-location">Instance method set(location:)</h3>

Sets [location](https://webim.ru/help/help-terms/) name for the session.
`location` parameter  – `String`-typed location name. Usually default available location names are "mobile" and "default". To create any other one you can contact service support.
Returns `self` with location name set.
Method is mandatory to create [WebimSession](#webim-session) object.

<h3 id ="set-app-version">Instance method set(appVersion:)</h3>

Sets app version number if it is necessary to differentiate its values inside _Webim_ service.
`appVersion` parameter – optional `String`-typed app version.
Returns `self` with app version setted. When passed `nil` it does nothing.
Method is not mandatory to create [WebimSession](#webim-session) object.

<h3 id ="set-visitor-fields-json-string-json-string">Instance method set(visitorFieldsJSONString jsonString:)</h3>

Sets visitor authorization data.
Without this method calling a visitor is anonymous, with randomly generated ID. This ID is saved inside app UserDefaults and can be lost (e.g. when app is uninstalled), thereby message history is lost too.
Authorized visitor data are saved by server and available with any device.
`jsonString` parameter – _JSON_-formatted `String`-typed [visitor fields](https://webim.ru/help/identification/).
Returns `self` with visitor authorization data set.
Method is not mandatory to create [WebimSession](#webim-session) object.

<h3 id ="set-visitor-fields-json-data-json-data">Instance method set(visitorFieldsJSONData jsonData:)</h3>

Absolutely similar to [method set(visitorFieldsJSONString jsonString:)](#set-visitor-fields-json-string-json-string).
`jsonData` parameter – _JSON_-formatted `Data`-typed [visitor fields](https://webim.ru/help/identification/).

<h3 id ="set-page-title">Instance method set(pageTitle:)</h3>

Sets chat title which is visible by an operator. Default value is "iOS Client"
`pageTitle` – `String`-typed chat title.
Returns `self` with chat title set.
Method is not mandatory to create [WebimSession](#webim-session) object.

<h3 id ="set-fatal-error-handler">Instance method set(fatalErrorHandler:)</h3>

Sets [FatalErrorHandler](#fatal-error-handler) object for session.
`fatalErrorHandler` parameter – any object of a class or struct that conforms to `FatalErrorHandler` protocol (or `nil`).
Returns `self` with `FatalErrorHandler` set. When `nil` passed it does nothing.
Method is not mandatory to create [WebimSession](#webim-session) object.

<h3 id ="set-remote-notification-system">Instance method set(remoteNotificationSystem:)</h3>

Sets remote notification system to use for receiving push notifications from _Webim_ service.
`remoteNotificationSystem` parameter – [RemoteNotificationSystem](#remote-notification-system) enum value. If parameter value is not [NONE](#none), [set(deviceToken:)](#set-device-token) method is mandatory to be called too. With [NONE](#none) value passed it does nothing.
Method is not mandatory to create [WebimSession](#webim-session) object.

<h3 id ="set-device-token">Instance method set(deviceToken:)</h3>

Sets device token for push notification receiving.
`deviceToken` parameter – `String`-typed device token in hexadecimal format and without any spaces and service symbols.
Code example to convert device token to the right format:
````
let deviceToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
````
Returns `self` with device token set.
For the proper remote notifications configuration this method call is not sufficient. You have to call `set(remoteNotificationSystem:)` method too.
Method is not mandatory to create [WebimSession](#webim-session) object.

<h3 id ="set-is-local-history-storaging-enabled">Instance method set(isLocalHistoryStoragingEnabled:)</h3>

By default session saves message history inside SQLite DB file. To deactivate this functionality you can use this method with false parameter isLocalHistoryStoragingEnabled value (with true value passed it does nothing).
Returns `self` with the functionality activation setting.
Method is not mandatory to create [WebimSession](#webim-session) object.

<h3 id ="set-is-visitor-data-clearing-enabled">Instance method set(isVisitorDataClearingEnabled:)</h3>

Sets necesarity to clear all visitor data before session is created.
With false `isVisitorDataClearingEnabled` parameter value passed it does nothing.
Method is not mandatory to create [WebimSession](#webim-session) object.

<h3 id ="build">Instance method build()</h3>

Final method that returns [WebimSession](#webim-session) object.
Can throw errors of [SessionBuilderError](#session-builder-error) type.
The only two mandatory method to call preliminarily are [set(accountName:)](#set-account-name) and [set(location:)](#set-location).

<h3 id ="session-builder-error">SessionBuilderError enum</h3>

Error types that can be throwed by [SessionBuilder](#session-builder) [method build()](#build).

<h4 id ="nil-account-name">NIL_ACCOUNT_NAME case</h4>

Error that is thrown when trying to create session object with `nil` account name.

<h4 id ="nil-location">NIL_LOCATION case</h4>

Error that is thrown when trying to create session object with `nil` location name.

<h4 id ="invalid-remote-notification-configuration">INVALID_REMOTE_NOTIFICATION_CONFIGURATION case</h4>

Error that is thrown when trying to create session object with invalid remote notifications configuration.

<h2 id ="webim-session">WebimSession protocol</h2>

Provides methods to manipulate with [WebimSession](#webim-session) object.

<h3 id ="resume">resume() method</h3>

Resumes session networking
Session is created as paused. To start using it firstly you should call this method.
Can throw errors of [AccessError](#access-error) type.

<h3 id ="pause">pause() method</h3>

Pauses session networking. If is already paused the method does nothing.
Can throw errors of [AccessError](#access-error) type.

<h3 id ="destroy">destroy() method</h3>

Deactivates session. After that any session methods are not available.
Can throw errors of [AccessError](#access-error) type.

<h3 id ="get-stream">getStream() method</h3>

Returns [MessageStream](#message-stream) object attached to this session. Each invocation of this method returns the same object.

<h3 id ="change-location">change(location:) method</h3>

Changes [location](https://webim.ru/help/help-terms/) without creating a new session.
`location` parameter – new location name of `String` type.

<h2 id ="message-stream">MessageStream protocol</h2>

Provides methods to interact with _Webim_ service.

<h3 id ="get-chat-state">getChatState() method</h3>

Returns current chat state of [ChatState](#chat-state) type.

<h3 id ="get-location-settings">getLocationSettings() method</h3>

Returns current [LocationSettings](#location-settings) object.

<h3 id ="get-current-operator">getCurrentOperator() method</h3>

Returns [Operator](#operator-protocol) object of the current chat or `nil` if one does not exist.

<h3 id ="get-last-rating-of-operator-with-id">getLastRatingOfOperatorWith(id:) method</h3>

Returns previous rating of the operator or `0` if it was not rated before.
`id` parameter – `String`-typed ID of operator.

<h3 id ="rate-operator-with-id-by-rating-rating">rateOperatorWith(id:,byRating rating:) method</h3>

Rates an operator.
To get an ID of the current operator call [getCurrentOperator()](#get-current-operator).
id parameter – String-typed ID of the operator to be rated.
rating parameter – a number in range (1...5) that represents an operator rating. If the number is out of range, rating will not be sent to a server.
Can throw errors of [AccessError](#access-error) type.

<h3 id ="start-chat">startChat() method</h3>

Changes [ChatState](#chat-state) to [QUEUE](#queue). Method call is not mandatory, send message or send file methods start chat automatically.
Can throw errors of [AccessError](#access-error) type.

<h3 id ="close-chat">closeChat() method</h3>

Changes [ChatState](#chat-state) to [CLOSED_BY_VISITOR](#closed-by-visitor).
Can throw errors of [AccessError](#access-error) type.

<h3 id ="set-visitor-typing-draft-message">setVisitorTyping(draftMessage:) method</h3>

This method must be called whenever there is a change of the input field of a message transferring current content of a message as a parameter. When `nil` value passed it means that visitor stopped to type a message or deleted it.
When there's multiple calls of this method occured, draft message is sending to service one time per second.
Can throw errors of [AccessError](#access-error) type.

<h3 id ="send-message-is-hint-question">send(message:,isHintQuestion:) method</h3>

Sends a text message.
When calling this method, if there is an active [MessageTracker](#message-tracker) object. [added(message newMessage:,after previousMessage:) method](#added-message-new-message-after-previous-message)) with a message [SENDING case](#sending) in the status is also called.
message parameter – `String`-typed message text.
isHintQuestion parameter shows to server if a visitor chose a hint (true value) or wrote his own text (`false`). Optional to use.
Returns randomly generated `String`-typed ID of the message.
Can throw errors of [AccessError](#access-error) type.

<h3 id ="send-file-filename-mime-type-completion-handler">send(file:,filename:,mimeType:,completionHandler:) method</h3>

Sends a file message.
When calling this method, if there is an active [MessageTracker](#message-tracker) object. [added(message newMessage:,after previousMessage:) method](#added-message-new-message-after-previous-message)) with a message [SENDING case](#sending) in the status is also called.
`file` parameter – file represented in `Data` type.
`filename` parameter – file name of `String` type.
`mimeType` parameter – MIME type of the file to send of `String` type.
`completionHandler` parameter – optional [SendFileCompletionHandler](#send-file-completion-handler) object.
Returns randomly generated `String`-typed ID of the message.
Can throw errors of [AccessError](#access-error) type.

<h3 id ="new-message-tracker-message-listener">new(messageTracker messageListener:) method</h3>

Returns [MessageTracker](#message-tracker) object wich (via [getNextMessages(byLimit limitOfMessages:,completion:)](#get-next-nessages-by-limit-limit-of-messages-completion)) allows to request the messages from above in the history. Each next call [getNextMessages(byLimit limitOfMessages:,completion:)](#get-next-nessages-by-limit-limit-of-messages-completion) returns earlier messages in relation to the already requested ones.
Changes of user-visible messages (e.g. ever requested from [MessageTracker](#message-tracker)) are transmitted to [MessageListener](#message-listener). That is why [MessageListener](#message-listener) object is needed when creating [MessageTracker](#message-tracker).
For each [MessageStream](#message-stream) at every single moment can exist the only one active [MessageTracker](#message-tracker). When creating a new one at the previous there will be automatically called [destroy()](#destroy-message-tracker).
Can throw errors of [AccessError](#access-error) type.

<h3 id ="set-chat-state-listener">set(chatStateListener:) method</h3>

Sets [ChatStateListener](#chat-state-listener) object.

<h3 id ="set-current-operator-change-listener">set(currentOperatorChangeListener:) method</h3>

Sets [CurrentOperatorChangeListener](#current-operator-change-listener) object.

<h3 id ="set-operator-typing-listener">set(operatorTypingListener:) method</h3>

Sets [OperatorTypingListener](#operator-typing-listener) object.

<h3 id ="set-location-settings-change-listener">set(locationSettingsChangeListener:) method</h3>

Sets [LocationSettingsChangeListener](#location-settings-shange-listener) object.

<h3 id ="set-session-online-status-change-listener">set(sessionOnlineStatusChangeListener:) method</h3>

Sets [SessionOnlineStatusChangeListener](#session-online-status-change-listener) object.

<h2 id ="send-file-completion-handler">SendFileCompletionHandler protocol</h2>

Protocol which methods are called after [send(file:,filename:,mimeType:,completionHandler:)](#send-file-filename-mime-type-completion-handler) method is finished. Must be adopted.

<h3 id ="on-success-message-id">onSuccess(messageID:) method</h3>

Executed when operation is done successfully.
`messageID` parameter – ID of the appropriate message of `String` type.

<h3 id ="on-failure-message-id-error">onFailure(messageID:,error:) method</h3>

Executed when operation is failed.
`messageID` parameter – ID of the appropriate message of `String` type.
`error` parameter – appropriate [SendFileError](#send-file-error) value.

<h2 id ="location-settings">LocationSettings protocol</h2>

Interface that provides methods for handling [LocationSettings](#location-settings) which are received from server.

<h3 id ="are-hints-enabled">areHintsEnabled() method</h3>

This method shows to an app if it should show hint questions to visitor. Returns `true` if an app should show hint questions to visitor, `false` otherwise.

<h2 id ="chat-state-listener">ChatStateListener protocol</h2>

Protocol that is to be adopted to track [ChatState](#chat-state) changes.

<h3 id ="changed-state-previous-state-to-new-state">changed(state previousState:,to newState:) method</h3>

Called during [ChatState](#chat-state)transition. Parameters are of [ChatState](#chat-state) type.

<h2 id ="current-operator-change-listener">CurrentOperatorChangeListener protocol</h2>

Protocol that is to be adopted to track if current [Operator](#operator-protocol) object is changed.

<h3 id ="changed-operator-previous-operator-to-new-operator">changed(operator previousOperator:,to newOperator:) method</h3>

Called when [Operator](#operator-protocol) object of the current chat changed. New one value can be `nil` (if an operator leaved the chat).

<h2 id ="operator-typing-listener">OperatorTypingListener protocol</h2>

Protocol that is to be adopted to track if the operator started or ended to type a message.

<h3 id ="on-operator-typing-state-changed-is-typing">onOperatorTypingStateChanged(isTyping:) method</h3>

Called when operator typing state changed.
Parameter `isTyping` is `true` if operator is typing, `false` otherwise.

<h2 id ="location-settings-shange-listener">LocationSettingsChangeListener protocol</h2>

Interface that provides methods for handling changes in [LocationSettings](#location-settings).

<h3 id ="changed-location-settings-previous-location-settings-to-new-location-settings">changed(locationSettings previousLocationSettings:,to newLocationSettings:) method</h3>

Method called by an app when new [LocationSettings](#location-settings) object is received with parameters that represent previous and new [LocationSettings](#location-settings) objects.

<h2 id ="session-online-status-change-listener">SessionOnlineStatusChangeListener protocol</h2>

Interface that provides methods for handling changes of session status.

<h3 id ="changed-session-online-status-previous-session-online-status-to-new-session-online-status">changed(sessionOnlineStatus previousSessionOnlineStatus:,to newSessionOnlineStatus:) method</h3>

Called when new session status is received with parameters that represent previous and new [SessionOnlineStatus](#session-online-status) values.

<h2 id ="chat-state">ChatState enum</h2>

A chat is seen in different ways by an operator depending on ChatState.
The initial state is [NONE](#none-chat-state).
Then if a visitor sends a message ([send(message:,isHintQuestion:)](#send-message-is-hint-question)), the chat changes it's state to [QUEUE](#queue). The chat can be turned into this state by calling [startChat() method](#start-chat).
After that, if an operator takes the chat to process, the state changes to [CHATTING](#chatting). The chat is being in this state until the visitor or the operator closes it.
When closing a chat by the visitor [closeChat() method](#close-chat) it turns into the state [CLOSED_BY_VISITOR](#closed-by-visitor), by the operator - [CLOSED_BY_OPERATOR](#closed-by-operator).
When both the visitor and the operator close the chat, it's state changes to the initial – [NONE](#none-chat-state). A chat can also automatically turn into the initial state during long-term absence of activity in it.
Furthermore, the first message can be sent not only by a visitor but also by an operator. In this case the state will change from the initial to [INVITATION](#invitation), and then, after the first message of the visitor, it changes to [CHATTING](#chatting).

<h3 id ="chatting">CHATTING case</h3>

Means that an operator has taken a chat for processing.
From this state a chat can be turned into:
* [CLOSED_BY_OPERATOR](#closed-by-operator), if an operator closes the chat;
* [CLOSED_BY_VISITOR](#closed-by-visitor), if a visitor closes the chat ([closeChat() method](#close-chat));
* [NONE](#none-chat-state), automatically during long-term absence of activity.

<h3 id ="closed-by-operator">CLOSED_BY_OPERATOR case</h3>

Means that an operator has closed the chat.
From this state a chat can be turned into:
* [NONE](#none-chat-state), if the chat is also closed by a visitor ([closeChat() method](#close-chat)), or automatically during long-term absence of activity;
* [QUEUE](#queue), if a visitor sends a new message ([send(message:,isHintQuestion:) method](#send-message-is-hint-question)).

<h3 id ="closed-by-visitor">CLOSED_BY_VISITOR case</h3>

Means that a visitor has closed the chat.
From this state a chat can be turned into:
* [NONE](#none-chat-state), if the chat is also closed by an operator or automatically during long-term absence of activity;
* [QUEUE](#queue), if a visitor sends a new message ([send(message:,isHintQuestion:) method](#send-message-is-hint-question)).

<h3 id ="invitation">INVITATION case</h3>

Means that a chat has been started by an operator and at this moment is waiting for a visitor's response.
From this state a chat can be turned into:
* [CHATTING](#chatting), if a visitor sends a message ([send(message:,isHintQuestion:) method](#send-message-is-hint-question));
* [NONE](#none-chat-state), if an operator or a visitor closes the chat ([closeChat() method](#close-chat)).

<h3 id ="none-chat-state">NONE case</h3>

Means the absence of a chat as such, e.g. a chat has not been started by a visitor nor by an operator.
From this state a chat can be turned into:
* [QUEUE](#queue), if the chat is started by a visitor (by the first message or by calling [startChat() method](#start-chat));
* [INVITATION](#invitation), if the chat is started by an operator.

<h3 id ="queue">QUEUE case</h3>

Means that a chat has been started by a visitor and at this moment is being in the queue for processing by an operator.
From this state a chat can be turned into:
* [CHATTING](#chatting), if an operator takes the chat for processing;
* [NONE](#none-chat-state), if a visitor closes the chat (by calling ([closeChat() method](#close-chat)) before it is taken for processing;
* [CLOSED_BY_OPERATOR](#closed-by-operator), if an operator closes the chat without taking it for processing.

<h3 id ="unknown">UNKNOWN case</h3>

The state is undefined.
This state is set as the initial when creating a new session, until the first response of the server containing the actual state is got. This state is also used as a fallback if _WebimClientLibrary_ can not identify the server state (e.g. if the server has been updated to a version that contains new states).

<h2 id ="send-file-error">SendFileError enum</h2>

Error types that could be passed in [onFailure(messageID:,error:) method](#on-failure-message-id-error).

<h3 id ="file-size-exceeded">FILE_SIZE_EXCEEDED case</h3>

The server may deny a request if the file size exceeds a limit.
The maximum size of a file is configured on the server.

<h3 id ="file-type-not-allowed">FILE_TYPE_NOT_ALLOWED case</h3>

The server may deny a request if the file type is not allowed.
The list of allowed file types is configured on the server.

<h2 id ="session-online-status">SessionOnlineStatus enum</h2>

Session state possible cases.

<h3 id ="busy-offline">BUSY_OFFLINE case</h3>

Means that visitor is not able to send messages at all.

<h3 id ="busy-online">BUSY_ONLINE case</h3>

Visitor is able send offline messages, but the server can reject it.

<h3 id ="offline">OFFLINE case</h3>

Visitor is able send offline messages.

<h3 id ="online">ONLINE case</h3>

Visitor is able to send both online and offline messages.

<h3 id ="unknown-session-online-status">UNKNOWN case</h3>

Session has not received first session status yet or session status is not supported by this version of the library.

<h2 id ="message-tracker">MessageTracker protocol</h2>

[MessageTracker](#message-tracker) object has two purposes:
- it allows to request the messages which are above in the history;
- it defines an interval within which message changes are transmitted to the listener (see [new(messageTracker messageListener:) method](#new-message-tracker-message-listener)).

<h3 id ="get-last-messages-by-limit-limit-of-messages-completion">getLastMessages(byLimit limitOfMessages:,completion:) method</h3>

Requests last messages from history. Returns not more than `limitOfMessages` of messages. If an empty list is passed inside completion, there no messages in history yet.
If there is any previous [MessageTracker](#message-tracker) request that is not completed, or limit of messages is less than 1, or current [MessageTracker](#message-tracker) has been destroyed, this method will do nothing.
Following history request can be fulfilled by [getLastMessages(byLimit limitOfMessages:,completion:)](#get-last-messages-by-limit-limit-of-messages-completion) method.
Completion is called with received array of [Message](#message) objects as the parameter.
Can throw errors of [AccessError](#access-error) type.

<h3 id ="get-next-nessages-by-limit-limit-of-messages-completion">getNextMessages(byLimit limitOfMessages:,completion:) method</h3>

Requests the messages above in history. Returns not more than `limitOfMessages` of messages. If an empty list is passed inside completion, the end of the message history is reached.
If there is any previous [MessageTracker](#message-tracker) request that is not completed, or limit of messages is less than 1, or current [MessageTracker](#message-tracker) has been destroyed, this method will do nothing.
Notice that this method can not be called again until the callback for the previous call will be invoked.
Completion is called with received array of [Message](#message) objects as the parameter.
Can throw errors of [AccessError](#access-error) type.

<h3 id ="get-all-messages-completion">getAllMessages(completion:) method</h3>

Requests all messages from history. If an empty list is passed inside completion, there no messages in history yet.
If there is any previous [MessageTracker](#message-tracker) request that is not completed, or current [MessageTracker](#message-tracker) has been destroyed, this method will do nothing.
This method is totally independent on [getLastMessages(byLimit limitOfMessages:,completion:)](#get-last-messages-by-limit-limit-of-messages-completion) and [getNextMessages(byLimit limitOfMessages:,completion:)](#get-next-nessages-by-limit-limit-of-messages-completion) methods calls.
Completion is called with received array of [Message](#message) objects as the parameter.
Can throw errors of [AccessError](#access-error) type.

<h3 id ="reset-to-message">resetTo(message:) method</h3>

[MessageTracker](#message-tracker) retains some range of messages. By using this method one can move the upper limit of this range to another message.
If there is any previous [MessageTracker](#message-tracker) request that is not completed, this method will do nothing.
Notice that this method can not be used unless the previous call [getNextMessages(byLimit limitOfMessages:,completion:)](#get-next-nessages-by-limit-limit-of-messages-completion) was finished (completion handler was invoked).
Parameter `message` – [Message](#message) object reset to.
Can throw errors of [AccessError](#access-error) type.

<h3 id ="destroy-message-tracker">destroy() method</h3>

Destroys the [MessageTracker](#message-tracker). It is impossible to use any [MessageTracker](#message-tracker) methods after it was destroyed.
Isn't mandatory to be called.

<h2 id ="message-listener">MessageListener protocol</h2>

Should be adopted. Provides methods to track changes inside message stream.

<h3 id ="added-message-new-message-after-previous-message">added(message newMessage:,after previousMessage:) method</h3>

Called when added a new message.
If `previousMessage == nil` then it should be added to the end of message history (the lowest message is added), in other cases the message should be inserted before the message (i.e. above in history) which was given as a parameter `previousMessage`.
Notice that this is a logical insertion of a message. I.e. calling this method does not necessarily mean receiving a new (unread) message. Moreover, at the first call [getNextMessages(byLimit limitOfMessages:,completion:)](#get-next-nessages-by-limit-limit-of-messages-completion) most often the last messages of a local history (i.e. which is stored on a user's device) are returned, and this method will be called for each message received from a server after a successful connection.
Parameters are of type [Message](#message). `previousMessage` represents a message after which it is needed to make a message insert. If `nil` then an insert is performed at the end of the list.

<h3 id ="removed-message">removed(message:) method</h3>

Called when removing a message.
`message` parameter is of type [Message](#message).

<h3 id ="removed-all-messages">removedAllMessages() method</h3>

Called when removed all the messages.

<h3 id ="changed-message-old-version-to-new-version">changed(message oldVersion:,to newVersion:) method</h3>

Called when changing a message.
[Message](#message) is an immutable type and field values can not be changed. That is why message changing occurs as replacing one object with another. Thereby you can find out, for example, which certain message fields have changed by comparing an old and a new object values.
Parameters are of type [Message](#message).

<h2 id ="message">Message protocol</h2>

Abstracts a single message in the message history.
A message is an immutable object. It means that changing some of the message fields creates a new object. Messages can be compared by using [isEqual(to message:)](#is-equal-to-message) method for searching messages with the same set of fields or by ID (`message1.getID() == message2.getID()`) for searching logically identical messages. ID is formed on the client side when sending a message ([send(message:,isHintQuestion:)](#send-message-is-hint-question) or [send(file:,filename:,mimeType:,completionHandler:)](#send-file-filename-mime-type-completion-handler)).

<h3 id ="get-attachment">getAttachment() method</h3>

Messages of the types [FILE_FROM_OPERATOR](#file-from-operator) and [FILE_FROM_VISITOR](#file-from-visitor) can contain attachments.
Returns [MessageAttachment](#message-attachment) object. Notice that this method may return nil even in the case of previously listed types of messages. E.g. if a file is being sent.

<h3 id ="get-data">getData() method</h3>

Messages of type [ACTION_REQUEST](#action-request) contain custom dictionary.
Returns dictionary which contains custom fields or `nil` if there's no such custom fields.

<h3 id ="get-id">getID() method</h3>

Every message can be uniquefied by its ID. Messages also can be lined up by its IDs. ID doesn’t change while changing the content of a message.
Returns unique ID of the message of type `String`.

<h3 id ="get-operator-id">getOperatorID() method</h3>

Returns ID of a message sender, if the sender is an operator, of type `String`.

<h3 id ="get-sender-avatar-full-url-string">getSenderAvatarFullURLString() method</h3>

Returns URL of a sender's avatar of type `String` or `nil` if one does not exist.

<h3 id ="get-sender-name">getSenderName() method</h3>

Returns name of a message sender of type `String`.

<h3 id ="get-send-status">getSendStatus() method</h3>

Returns [SENT](#sent) if a message had been sent to the server, was received by the server and was delivered to all the clients; [SENDING](#sending) if not.

<h3 id ="get-text">getText() method</h3>

Returns text of the message of type `String`.

<h3 id ="get-time">getTime() method</h3>

Returns Epoch time (in ms) the message was processed by the server of `Int64` type.

Example code:
````
let messageDate = Date(timeIntervalSince1970: TimeInterval(message.getTime() / 1000))
````

<h3 id ="get-type">getType() method</h3>

Returns type of a message of [MessageType](#message-type) type.

<h3 id ="is-equal-to-message">isEqual(to message:) method</h3>

Method which can be used to compare if two [Message](#message) objects have identical contents.
Returns `true` if two [Message](#message) objects are identical and `false` otherwise.

Example code:
````
if messageOne.isEqual(to: messageTwo) { /* … */ }
````
Where `messageOne` and `messageTwo` are any `Message` objects.

<h2 id ="message-attachment">MessageAttachment protocol</h2>

Contains information about an attachment file.

<h3 id ="get-content-type">getContentType() method</h3>

Returns MIME-type of an attachment file of optional `String` type.

<h3 id ="get-file-name">getFileName() method</h3>

Returns name of an attachment file of optional `String` type.

<h3 id ="get-image-info">getImageInfo() method</h3>

If a file is an image, returns [ImageInfo](#image-info) object; in other cases returns nil.

<h3 id ="get-size">getSize() method</h3>

Returns attachment file size in bytes of `Int64` type.

<h3 id ="get-url-string">getURLString() method</h3>

Returns URL `String` of the file or `nil`.
Notice that this URL is short-living and is tied to a session.

<h2 id ="image-info">ImageInfo protocol</h2>

Provides information about an image.

<h3 id ="get-thumb-url-string">getThumbURLString() method</h3>

Returns a URL String of an image thumbnail.
The maximum width and height is usually 300 px but it can be adjusted at server settings.
To get an actual preview size before file uploading is completed, use the following code:
````
let THUMB_SIZE = 300
var width = imageInfo.getWidth()
var height = imageInfo.getHeight()
if (height > width) {
    width = (THUMB_SIZE * width) / height
    height = THUMB_SIZE
} else {
    height = (THUMB_SIZE * height) / width
    width = THUMB_SIZE
}
````
Notice that this URL is short-living and is tied to a session.

<h3 id ="get-height">getHeight() method</h3>

Returns height of an image in pixels of `Int` type or `nil`.

<h3 id ="get-width">getWidth() method</h3>

Returns width of an image in pixels of `Int` type or `nil`.

<h2 id ="message-type">MessageType enum</h2>

Message type representation.

<h3 id ="action-request">ACTION_REQUEST case</h3>

A message from operator which requests some actions from a visitor.
E.g. choose an operator group by clicking on a button in this message.

<h3 id ="file-from-operator">FILE_FROM_OPERATOR case</h3>

A message sent by an operator which contains an attachment.

<h3 id ="file-from-visitor">FILE_FROM_VISITOR case</h3>

A message sent by a visitor which contains an attachment.

<h3 id ="info">INFO case</h3>

A system information message.
Messages of this type are automatically sent at specific events. E.g. when starting a chat, closing a chat or when an operator joins a chat.

<h3 id ="operator">OPERATOR case</h3>

A text message sent by an operator.

<h3 id ="operator-busy">OPERATOR_BUSY case</h3>

A system information message which indicates that an operator is busy and can't reply to a visitor at the moment.

<h3 id ="visitor">VISITOR case</h3>

A text message sent by a visitor.

<h2 id ="message-send-status">MessageSendStatus enum</h2>

Until a message is sent to the server, is received by the server and is spreaded among clients, message can be seen as "being send"; at the same time `Message.getSendStatus()` will return [SENDING](#sending). In other cases - [SENT](#sent).

<h3 id ="sending">SENDING case</h3>

A message is being sent.

<h3 id ="sent">SENT case</h3>

A message had been sent to the server, received by the server and was spreaded among clients.

<h2 id ="operator-protocol">Operator protocol</h2>

Abstracts a chat operator.

<h3 id ="get-id-operator">getID() method</h3>

Returns unique ID of the operator of `String` type or nil.

<h3 id ="get-name">getName() method</h3>

Returns display name of the operator of `String` type or nil.

<h3 id ="get-avatar-url-string">getAvatarURLString() method</h3>

Returns URL `String` of the operator’s avatar.

<h2 id ="webim-remote-notification">WebimRemoteNotification protocol</h2>

Abstracts a remote notifications from _Webim_ service.

<h3 id ="get-type-webim-remote-notification">getType() method</h3>

Returns type of this remote notification of [NotificationType](#notification-type) type.

<h3 id ="get-event">getEvent() method</h3>

Returns event of this remote notification of [NotificationEvent](#notification-event) type.

<h3 id ="get-parameters">getParameters() method</h3>

Returns parameters of this remote notification of array of type `String` type. Each [NotificationType](#notification-type) has specific list of parameters.

<h2 id ="notification-type">NotificationType enum</h2>

Represents payload type of remote notification.

<h3 id ="operator-accepted">OPERATOR_ACCEPTED case</h3>

This notification type indicated that an operator has connected to a dialogue.

Parameters:
* Operator's name.

<h3 id ="operator-file">OPERATOR_FILE case</h3>

This notification type indicated that an operator has sent a file.

Parameters:
* Operator's name;
* File name.

<h3 id ="operator-message">OPERATOR_MESSAGE case</h3>

This notification type indicated that an operator has sent a text message.

Parameters:
* Operator's name;
* Message text.

<h2 id ="notification-event">NotificationEvent enum</h2>

Represents meaned type of action when remote notification is received.

<h3 id ="add">ADD case</h3>

Means that a notification should be added by current remote notification.

<h3 id ="delete">DELETE case</h3>

Means that a notification should be deleted by current remote notification.

<h2 id ="fatal-error-handler">FatalErrorHandler protocol</h2>

Must be adopted to handle service errors that can occur.

<h3 id ="on-error">on(error:) method</h3>

This method is to be called when a fatal error occurs.
Notice that the session will be destroyed before this method is called.
Returns [WebimError](#webim-error) object.

<h2 id ="fatal-error-type">FatalErrorType enum</h2>

Webim service fatal error types.

<h3 id ="account-blocked">ACCOUNT_BLOCKED case</h3>

Indicates that the account in Webim service has been disabled (e.g. for non-payment). The error is unrelated to the user’s actions.
Recommended response is to show the user an error message with a recommendation to try using the chat later.

<h3 id ="provided-visitor-fields">PROVIDED_VISITOR_EXPIRED case</h3>

Indicates an expired authorization of a visitor.
The recommended response is to re-authorize it and to re-create session object.

<h3 id ="unknown-fatal-error-type">UNKNOWN case</h3>

Indicates the occurrence of an unknown error.
Recommended response is to send an automatic bug report and show to a user an error message with the recommendation to try using the chat later.

<h3 id ="visitor-banned">VISITOR_BANNED case</h3>

Indicates that a visitor was banned by an operator and can't send messages to a chat anymore.
Occurs when a user tries to open the chat or write a message after that.
Recommended response is to show the user an error message with the recommendation to try using the chat later or explain to the user that it was blocked for some reason.

<h3 id ="wrong-provided-visitor-hash">WRONG_PROVIDED_VISITOR_HASH case</h3>

Indicates a problem of your application authorization mechanism and is unrelated to the user’s actions.
Occurs when trying to authorize a visitor with a non-valid signature.
Recommended response is to send an automatic bug report and show the user an error message with the recommendation to try using the chat later.

<h2 id ="webim-error">WebimError protocol</h2>

Abstracts _Webim_ service possible fatal error.

<h3 id ="get-error-type">getErrorType() method</h3>

Returns parsed type of the error of [FatalErrorType](#fatal-error-type) type.

<h3 id ="get-error-string">getErrorString() method</h3>

Returns `String` representation of an error. Mostly useful if the error type is unknown.

<h2 id ="access-error">AccessError enum</h2>

Error types that can be throwed by [MessageStream](#message-stream) methods.

<h3 id ="invalid-thread">INVALID_THREAD case</h3>

Error that is thrown if the method was called not from the thread the [WebimSession](#webim-session) object was created in.

<h3 id ="invalid-session">INVALID_SESSION case</h3>

Error that is thrown if [WebimSession](#webim-session) object was destroyed.
