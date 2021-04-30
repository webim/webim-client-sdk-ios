#  _WebimClientLibrary_ Reference Book

<h2 id="table-of-contents">Table of contents</h2>

-   [Webim class](#webim)
    -   [Class method newSessionBuilder()](#new-session-builder)
    -   [Class method parse(remoteNotification:visitorId:)](#parse-remote-notification)
    -   [Class method isWebim(remoteNotification:)](#is-webim-remote-notification)
    -   [RemoteNotificationSystem enum](#remote-notification-system)
        -   [apns case](#apns)
        -   [none case](#none)
-   [SessionBuilder class](#session-builder)
    -   [Instance method set(accountName:)](#set-account-name)
    -   [Instance method set(location:)](#set-location)
    -   [Instance method set(prechat:)](#set-prechat)
    -   [Instance method set(appVersion:)](#set-app-version)
    -   [Instance method set(visitorFieldsJSONString:)](#set-visitor-fields-json-string-json-string)
    -   [Instance method set(visitorFieldsJSONData:)](#set-visitor-fields-json-data-json-data)
    -   [Instance method set(providedAuthorizationTokenStateListener:providedAuthorizationToken:)](#set-provided-authorization-token-state-listener-provided-authorization-token)
    -   [Instance method set(pageTitle:)](#set-page-title)
    -   [Instance method set(fatalErrorHandler:)](#set-fatal-error-handler)
    -   [Instance method set(notFatalErrorHandler:)](#set-not-fatal-error-handler)
    -   [Instance method set(remoteNotificationSystem:)](#set-remote-notification-system)
    -   [Instance method set(deviceToken:)](#set-device-token)
    -   [Instance method set(isLocalHistoryStoragingEnabled:)](#set-is-local-history-storaging-enabled)
    -   [Instance method set(isVisitorDataClearingEnabled:)](#set-is-visitor-data-clearing-enabled)
    -   [Instance method set(multivisitorSection:)](#set-multivisitor-section)
    -   [Instance method set(webimLogger:verbosityLevel:)](#set-webim-logger-verbosity-level)
    -   [Instance method build()](#build)
    -   [Instance method build(onSuccess:onError:)](#build-on-success-on-error)
    -   [WebimLoggerVerbosityLevel enum](#webim-logger-verbosity-level)
        -   [verbose case](#verbose)
        -   [debug case](#debug)
        -   [info](#info)
        -   [warning case](#warning)
        -   [error case](#error)
    -   [SessionBuilderError enum](#session-builder-error)
        -   [nilAccountName case](#nil-account-name)
        -   [nilLocation case](#nil-location)
        -   [invalidAuthentificatorParameters](#invalid-authentication-parameters)
        -   [invalidRemoteNotificationConfiguration case](#invalid-remote-notification-configuration)
-   [ProvidedAuthorizationTokenStateListener protocol](#provided-authorization-token-state-listener)
    -   [update(providedAuthorizationToken:) method](#update-provided-authorization-token)
-   [WebimSession protocol](#webim-session)
    -   [resume() method](#resume)
    -   [pause() method](#pause)
    -   [destroy() method](#destroy)
    -   [destroyWithClearVisitorData() method](#destroy-with-clear-visitor-data)
    -   [getStream() method](#get-stream)
    -   [change(location:) method](#change-location)
    -   [set(deviceToken:) method](#set-device-token)
-   [MessageStream protocol](#message-stream)
    -   [getVisitSessionState() method](#get-visit-session-state)
    -   [getChatState() method](#get-chat-state)
    -   [getUnreadByOperatorTimestamp() method](#get-unread-by-operator-timestamp)
    -   [getUnreadByVisitorMessageCount() method](#get-unread-by-visitor-message-count)
    -   [getUnreadByVisitorTimestamp() method](#get-unread-by-visitor-timestamp)
    -   [getDepartmentList() method](#get-department-list)
    -   [getLocationSettings() method](#get-location-settings)
    -   [getCurrentOperator() method](#get-current-operator)
    -   [getLastRatingOfOperatorWith(id:) method](#get-last-rating-of-operator-with-id)
    -   [rateOperatorWith(id:byRating:completionHandler:) method](#rate-operator-with-id-by-rating-rating)
    -   [rateOperatorWith(id:note:byRating:completionHandler:) method](#rate-operator-with-id-note-by-rating-rating)
    -   [respondSentryCall(id:) method](#respond-sentry-call)
    -   [startChat() method](#start-chat)
    -   [startChat(firstQuestion:) method](#start-chat-first-question)
    -   [startChat(customFields:) method](#start-chat-custom-fields)
    -   [startChat(departmentKey:) method](#start-chat-department-key)
    -   [startChat(departmentKey:firstQuestion:) method](#start-chat-department-key-first-question)
    -   [startChat(firstQuestion:customFields) method](#start-chat-first-question-custom-fields)
    -   [startChat(departmentKey:customFields) method](#start-chat-department-key-custom-fields)
    -   [startChat(departmentKey:firstQuestion:customFields) method](#start-chat-department-key-first-question-custom-fields)
    -   [closeChat() method](#close-chat)
    -   [send(message:) method](#send-message)
    -   [setVisitorTyping(draftMessage:) method](#set-visitor-typing-draft-message)
    -   [send(message:data:completionHandler:) method](#send-message-data)
    -   [send(message:isHintQuestion:) method](#send-message-is-hint-question)
    -   [send(file:filename:mimeType:completionHandler:) method](#send-file-filename-mime-type-completion-handler)
    -   [sendKeyboardRequest(button:message:completionHandler:) method](#send-keyboard-request)
    -   [sendKeyboardRequest(buttonID:messageCurrentChatID:completionHandler:) method](#send-keyboard-request-with-id)
    -   [udpateWidgetStatus(data:) method](#update-widget-status)
    -   [reply(message:repliedMessage:) method](#reply-message)
    -   [edit(message:text:completionHandler:) method](#edit-message)
    -   [delete(message:completionHandler:) method](#delete-message)
    -   [setChatRead() method](#set-chat-read)
    -   [sendDialogTo(emailAddress:completionHandler:) method](#send-dialog-to-email-address)
    -   [set(prechatFields:) method](#set-prechat-fields)
    -   [newMessageTracker(messageListener:) method](#new-message-tracker-message-listener)
    -   [set(visitSessionStateListener:)](#set-visit-session-state-listener)
    -   [set(chatStateListener:) method](#set-chat-state-listener)
    -   [set(currentOperatorChangeListener:) method](#set-current-operator-change-listener)
    -   [set(departmentListChangeListener:)](#set-department-list-change-listener)
    -   [set(operatorTypingListener:) method](#set-operator-typing-listener)
    -   [set(locationSettingsChangeListener:) method](#set-location-settings-change-listener)
    -   [set(onlineStatusChangeListener:) method](#set-online-status-change-listener)
    -   [set(unreadByOperatorTimestampChangeListener:) method](#set-unread-by-operator-timestamp-change-listener)
    -   [set(unreadByVisitorMessageCountChangeListener:) method](#set-unread-by-visitor-message-count-change-listener)
    -   [set(unreadByVisitorTimestampChangeListener:) method](#set-unread-by-visitor-timestamp-change-listener)
-   [DataMessageCompletionHandler protocol](#data-message-completion-handler)
    -   [onSuccess(messageID:) method](#on-success-message-id-data-message-completion-handler)
    -   [onFailure(messageID:,error:) method](#on-failure-message-id-error-data-message-completion-handler)
-   [EditMessageCompletionHandler protocol](#edit-message-completion-handler)
    -   [onSuccess(messageID:) method](#on-success-message-id-edit-message-completion-handler)
    -   [onFailure(messageID:,error:) method](#on-failure-message-id-error-edit-message-completion-handler)
-   [DeleteMessageCompletionHandler protocol](#delete-message-completion-handler)
    -   [onSuccess(messageID:) method](#on-success-message-id-delete-message-completion-handler)
    -   [onFailure(messageID:,error:) method](#on-failure-message-id-error-delete-message-completion-handler)
-   [SendFileCompletionHandler protocol](#send-file-completion-handler)
    -   [onSuccess(messageID:) method](#on-success-message-id)
    -   [onFailure(messageID:,error:) method](#on-failure-message-id-error)
-   [SendKeyboardRequestCompletionHandler protocol](#send-keyboard-request-completion-handler)
    -   [onSuccess(messageID:) method](#on-success-message-id-send-keyboard-request)
    -   [onFailure(messageID:,error:) method](#on-failure-message-id-error-send-keyboard-request)
-   [RateOperatorCompletionHandler protocol](#rate-operator-completion-handler)
    -   [onSuccess() method](#on-success)
    -   [onFailure(error:) method](#on-failure-error)
-   [SendDialogToEmailAddressCompletionHandler protocol](#send-dialog-to-email-address-completion-handler)
    -   [onSuccess() method](#on-success-send-dialog)
    -   [onFailure(error:) method](#on-failure-error-send-dialog)
-   [VisitSessionStateListener protocol](#visit-session-state-listener)
    -   [changed(state:to:)](#changed-state-previous-state-to-new-state-visit-session-state-listener)
-   [DepartmentListChangeListener protocol](#department-list-change-listener)
    -   [received(departmentList:) method](#received-department-list)
-   [LocationSettings protocol](#location-settings)
    -   [areHintsEnabled() method](#are-hints-enabled)
-   [ChatStateListener protocol](#chat-state-listener)
    -   [changed(state:to:) method](#changed-state-previous-state-to-new-state)
-   [CurrentOperatorChangeListener protocol](#current-operator-change-listener)
    -   [changed(operator:to:) method](#changed-operator-previous-operator-to-new-operator)
-   [OperatorTypingListener protocol](#operator-typing-listener)
    -   [onOperatorTypingStateChanged(isTyping:) method](#on-operator-typing-state-changed-is-typing)
-   [LocationSettingsChangeListener protocol](#location-settings-shange-listener)
    -   [changed(locationSettings:to:) method](#changed-location-settings-previous-location-settings-to-new-location-settings)
-   [OnlineStatusChangeListener protocol](#online-status-change-listener)
    -   [changed(onlineStatus:to:) method](#changed-session-online-status-previous-session-online-status-to-new-session-online-status)
-   [UnreadByOperatorTimestampChangeListener protocol](#unread-by-operator-timestamp-change-listener)
    -   [changedUnreadByOperatorTimestampTo(newValue:) method](#changed-unread-by-operator-timestamp-to-new-value)
-   [UnreadByVisitorMessageCountChangeListener protocol](#unread-by-visitor-message-count-change-listener)
    -    [changedUnreadByVisitorMessageCountTo(newValue:) method](#changed-unread-by-visitor-message-count-to-new-value)
-   [UnreadByVisitorTimestampChangeListener protocol](#unread-by-visitor-timestamp-change-listener)
    -    [changedUnreadByVisitorTimestampTo(newValue:) method](#changed-unread-by-visitor-timestamp-to-new-value)
-   [ChatState enum](#chat-state)
    -   [chatting case](#chatting)
    -   [chattingWithRobot](#chatting-with-robot)
    -   [closedByOperator case](#closed-by-operator)
    -   [closedByVisitor case](#closed-by-visitor)
    -   [invitation case](#invitation)
    -   [closed case](#closed)
    -   [queue case](#queue)
    -   [unknown case](#unknown)
-   [OnlineStatus enum](#session-online-status)
    -   [busyOffline case](#busy-offline)
    -   [busyOnline case](#busy-online)
    -   [offline case](#offline)
    -   [online case](#online)
    -   [unknown case](#unknown-session-online-status)
-   [VisitSessionState enum](#visit-session-state)
    -   [chat case](#chat-visit-session-state)
    -   [departmentSelection case](#department-selection)
    -   [idle case](#idle)
    -   [idleAfterChat case](#idle-after-chat)
    -   [offlineMessage case](#offline-message)
    -   [unknown case](#unknown-visit-session-state)
-   [DataMessageError enum](#data-message-error)
    -   [unknown case](#unknown-data-message-error)
    -   [quotedMessageCanNotBeReplied case](#quoted-message-cannot-be-replied)
    -   [quotedMessageFromAnotherVisitor case](#quoted-message-from-another-visitor)
    -   [quotedMessageMultipleIds case](#quoted-message-multiple-ids)
    -   [quotedMessageRequiredArgumentsMissing case](#quoted-message-required-arguments-missing)
    -   [quotedMessageWrongId case](#quoted-message-wrong-id)
-   [EditMessageError enum](#edit-message-error)
    -   [unknown case](#unknown-edit-message-error)
    -   [notAllowed case](#not-allowed-edit-message-error)
    -   [messageEmpty case](#message_empty-edit-message-error)
    -   [messageNotOwned case](#message-not-owned-edit-message-error)
    -   [maxLengthExceeded case](#max-length-exceeded-edit-message-error)
    -   [wrongMesageKind case](#wrong-message-kind-edit-message-error)
-   [DeleteMessageError enum](#delete-message-error)
    -   [unknown case](#unknown-delete-message-error)
    -   [notAllowed case](#not-allowed-delete-message-error)
    -   [messageNotOwned case](#message-not-owned-delete-message-error)
    -   [messageNotFound](#message-not-found-delete-message-error)
-   [SendFileError enum](#send-file-error)
    -   [fileSizeExceeded case](#file-size-exceeded)
    -   [fileTypeNotAllowed case](#file-type-not-allowed)
    -   [uploadedFileNotFound case](#uploaded-file-not-found)
    -   [unknown case](#file-sending-unknown)
-   [KeyboardResponseError enum](#keyboard-response-error)
    -   [noChat case](#keyboard-response-error-no-chat)
    -   [buttonIdNotSet case](#button-id-not-set)
    -   [requestMessageIdNotSet case](#request-message-id-not-set)
    -   [canNotCreateResponse case](#can-not-create-response)
    -   [unknown case](#keyboard-response-error-unknown)
-   [RateOperatorError enum](#rate-operator-error)
    -   [noChat case](#no-chat)
    -   [wrongOperatorId case](#wrong-operator-id)
-   [SendDialogToEmailAddressError enum](#send-dialog-to-email-address-error)
    -   [noChat case](#no-chat-send-dialog)
    -   [sentTooManyTimes case](#sent-too-many-times)
    -   [unknown case](#unknown-send-dialog-error)
-   [MessageTracker protocol](#message-tracker)
-   [getLastMessages(byLimit:completion:) method](#get-last-messages-by-limit-limit-of-messages-completion)
-   [getNextMessages(byLimit:completion:) method](#get-next-nessages-by-limit-limit-of-messages-completion)
    -   [getAllMessages(completion:) method](#get-all-messages-completion)
    -   [resetTo(message:) method](#reset-to-message)
    -   [destroy() method](#destroy-message-tracker)
-   [MessageListener protocol](#message-listener)
    -   [added(message:after:) method](#added-message-new-message-after-previous-message)
    -   [removed(message:) method](#removed-message)
    -   [removedAllMessages() method](#removed-all-messages)
    -   [changed(message:to:) method](#changed-message-old-version-to-new-version)
-   [Message protocol](#message)
    -   [getAttachment() method](#get-attachment)
    -   [getData() method](#get-data)
    -   [getID() method](#get-id)
    -   [getCurrentChatID() method](#get-current-chat-id)
    -   [getKeyboard() method](#get-keyboard)
    -   [getKeyboardRequest()](#get-keyboard-request)
    -   [getOperatorID() method](#get-operator-id)
    -   [getQuote() method](#get-quote)
    -   [getSenderAvatarFullURL() method](#get-sender-avatar-full-url)
    -   [getSenderName() method](#get-sender-name)
    -   [getSendStatus() method](#get-send-status)
    -   [getText() method](#get-text)
    -   [getTime() method](#get-time)
    -   [getType() method](#get-type)
    -   [isEqual(to:) method](#is-equal-to-message)
    -   [isReadByOperator() method](#is-read-by-operator)
    -   [canBeEdited() method](#can-be-edited)
    -   [canBeReplied() method](#can-be-replied)
-   [Quote protocol](#quote)
    -   [getAuthorID method](#get-quote-author-id)
    -   [getMessageAttachment() method](#get-quote-message-attachment)
    -   [getMessageTimestamp() method](#get-quote-message-timestamp)
    -   [getMessageID() method](#get-quote-message-id)
    -   [getMessageText() method](#get-quote-message-text)
    -   [getMessageType() method](#get-quote-message-type)
    -   [getSenderName() method](#get-quote-sender-name)
    -   [getState() method](#get-quote-state)
-   [QuotState enum](#quote-state)
    -   [pending case](#quote-pending)
    -   [filled case](#quote-filled)
    -   [notFound case](#qoute-not-found)
-   [MessageAttachment protocol](#message-attachment)
    -   [getContentType() method](#get-content-type)
    -   [getFileName() method](#get-file-name)
    -   [getImageInfo() method](#get-image-info)
    -   [getSize() method](#get-size)
    -   [getURL() method](#get-url-string)
-   [ImageInfo protocol](#image-info)
    -   [getThumbURL() method](#get-thumb-url-string)
    -   [getHeight() method](#get-height)
    -   [getWidth() method](#get-width)
-   [Keyboard protocol](#keyboard)
    -   [getButtons() method](#get-buttons)
    -   [getState() method](#get-state)
    -   [getResponse() method](#get-response)
-   [KeyboardResponse protocol](#keyboard-response)
    -   [getButtonID() method](#get-button-id)
    -   [getMessageID() method](#keyboard-response-get-message-id)
-   [KeyboardButton protocol](#keyboard-button)
    -   [getID() method](#button-get-id)
    -   [getText() method](#button-get-text)
-   [KeyboardRequest protocol](#keyboard-request)
    -   [getButton() method](#get-button)
    -   [getMessageID() method](#keyboard-request-get-message-id)
-   [MessageType enum](#message-type)
    -   [actionRequest case](#action-request)
    -   [contactInformationRequest case](#contacts-request)
    -   [keyboard case](#keyboard-type)
    -   [keyboardResponse case](#keyboard-response-type)
    -   [fileFromOperator case](#file-from-operator)
    -   [fileFromVisitor case](#file-from-visitor)
    -   [info case](#info)
    -   [operatorMessage case](#operator)
    -   [operatorBusy case](#operator-busy)
    -   [visitorMessage case](#visitor)
-   [MessageSendStatus enum](#message-send-status)
    -   [sending case](#sending)
    -   [sent case](#sent)
-   [KeyboardState enum](#keyboard-state)
    -   [pending case](#pending)
    -   [completed case](#completed)
    -   [canceled case](#cancelled)
-   [Department protocol](#department)
    -   [getKey() method](#get-key)
    -   [getName() method](#get-name-department)
    -   [getDepartmentOnlineStatus() method](#get-department-online-status)
    -   [getOrder() method](#get-order)
    -   [getLocalizedNames() method](#get-localized-names)
    -   [getLogo() method](#get-logo)
-   [DepartmentOnlineStatus enum](#department-online-status)
    -   [busyOffline case](#busy-offline-department-online-status)
    -   [busyOnline case](#busy-online-department-online-status)
    -   [offline case](#offline-department-online-status)
    -   [online case](#online-department-online-status)
    -   [unknown case](#unknown-department-online-status)
-   [Operator protocol](#operator-protocol)
    -   [getID() method](#get-id-operator)
    -   [getName() method](#get-name)
    -   [getAvatarURL() method](#get-avatar-url)
-   [WebimRemoteNotification protocol](#webim-remote-notification)
    -   [getType() method](#get-type-webim-remote-notification)
    -   [getEvent() method](#get-event)
    -   [getParameters() method](#get-parameters)
    -   [getLocation() method](#get-location)
    -   [getUnreadByVisitorMessagesCount method](#get-unread-by-visitor-messages-count)
-   [NotificationType enum](#notification-type)
    -   [contactInformationRequest](#contact-information-request)
    -   [operatorAccepted case](#operator-accepted)
    -   [operatorFile case](#operator-file)
    -   [operatorMessage case](#operator-message)
    -   [widget case](#widget)
-   [NotificationEvent enum](#notification-event)
    -   [add case](#add)
    -   [delete case](#delete)
-   [FatalErrorHandler protocol](#fatal-error-handler)
    -   [on(error:) method](#on-error)
-   [FatalErrorType enum](#fatal-error-type)
    -   [accountBlocked case](#account-blocked)
    -   [noChat case](#no-chat)
    -   [providedVisitorFieldsExpired case](#provided-visitor-fields-expired)
    -   [unknown case](#unknown-fatal-error-type)
    -   [visitorBanned case](#visitor-banned)
    -   [wrongProvidedVisitorHash case](#wrong-provided-visitor-hash)
-   [WebimError protocol](#webim-error)
    -   [getErrorType() method](#get-error-type)
    -   [getErrorString() method](#get-error-string)
-   [NotFatalErrorHandler protocol](#not-fatal-error-handler)
    -   [on(error:) method](#on-not-fatal-error)
-   [NotFatalErrorType enum](#not-fatal-error-type)
    -   [noNetworkConnection case](#no-network-connection)
    -   [serverIsNotAvailable case](#server-is-not-available)
-   [WebimNotFatalError protocol](#webim-not-fatal-error)
    -   [getErrorType() method](#get-not-fatal-error-type)
    -   [getErrorString() method](#get-not-fatal-error-string)
-   [AccessError enum](#access-error)
    -   [invalidThread case](#invalid-thread)
    -   [invalidSession case](#invalid-session)
-   [WebimLogger protocol](#webim-logger)
    -   [log(entry:) method](#log-entry)

<h2 id="webim">Webim class</h2>

Set of static methods which are used for session object creating and working with remote notifications that are sent by _Webim_ service.

<h3 id="new-session-builder">Class method newSessionBuilder()</h3>

Returns [SessionBuilder class](#session-builder) instance that is necessary to create `WebimSession` class instance.

<h3 id ="parse-remote-notification">Class method parse(remoteNotification:visitorId)</h3>

Converts _iOS_ remote notification object into [WebimRemoteNotification](#webim-remote-notification) object.
`remoteNotification` parameter takes `[AnyHashable: Any]` dictionary (which can be taken inside `application(_ application:,didReceiveRemoteNotification userInfo:)` `AppDelegate` class method from `userInfo` parameter).
Method can return `nil` if `remoteNotification` parameter value doesn't fit to _Webim_ service remote notification format or if it doesn't contain any useful payload or visitor ID from notification doesn't equals `visitorId `.
Preliminarily you can call [method isWebim(remoteNotification:)](#is-webim-remote-notification) on this value to know if this notification is send by _Webim_ service.

<h3 id ="is-webim-remote-notification">Class method isWebim(remoteNotification:)</h3>

Allows to know if particular remote notification object represents Webim service remote notification.
`remoteNotification` parameter takes `[AnyHashable: Any]` dictionary (which can be taken inside `application(_ application:,didReceiveRemoteNotification userInfo:)` `AppDelegate` class method from `userInfo` parameter).
Returns `true` or `false`.

<h3 id ="remote-notification-system">RemoteNotificationSystem enum</h3>

Enumerates push notifications systems that can be used with _WebimClientLibrary_. Enum values are used to be passed to [method set(remoteNotificationSystem:)](#set-remote-notification-system) [SessionBuilder class](#session-builder) instance method.

<h4 id ="apns">apns case</h4>

_Apple Push Notification System_.

<h4 id ="none">none case</h4>

App does not receive remote notification from _Webim_ service.

[Go to table of contents](#table-of-contents)

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

<h3 id ="set-prechat">Instance method set(prechat:)</h3>
Attention: this method can't be used as is. It requires that client server to support this mechanism!
Sets prechat fields for the session.
`prechat` parameter  – `String`-typed prechat fields in JSON format.
Returns `self` with location name set.
Method is mandatory to create [WebimSession](#webim-session) object.

<h3 id ="set-app-version">Instance method set(appVersion:)</h3>

Sets app version number if it is necessary to differentiate its values inside _Webim_ service.
`appVersion` parameter – optional `String`-typed app version.
Returns `self` with app version set. When passed `nil` it does nothing.
Method is not mandatory to create [WebimSession](#webim-session) object.

<h3 id ="set-visitor-fields-json-string-json-string">Instance method set(visitorFieldsJSONString:)</h3>

Sets visitor authorization data.
Without this method calling a visitor is anonymous, with randomly generated ID. This ID is saved inside app UserDefaults and can be lost (e.g. when app is uninstalled), thereby message history is lost too.
Authorized visitor data are saved by server and available with any device.
`jsonString` parameter – _JSON_-formatted `String`-typed [visitor fields](https://webim.ru/help/identification/).
Returns `self` with visitor authorization data set.
Method is not mandatory to create [WebimSession](#webim-session) object.
Can't be used simultanously with [set(providedAuthorizationTokenStateListener:,providedAuthorizationToken:) method](#set-provided-authorization-token-state-listener-provided-authorization-token).

<h3 id ="set-visitor-fields-json-data-json-data">Instance method set(visitorFieldsJSONData:)</h3>

Absolutely similar to [method set(visitorFieldsJSONString jsonString:)](#set-visitor-fields-json-string-json-string).
`jsonData` parameter – _JSON_-formatted `Data`-typed [visitor fields](https://webim.ru/help/identification/).

<h3 id ="set-provided-authorization-token-state-listener-provided-authorization-token">Instance method set(providedAuthorizationTokenStateListener:providedAuthorizationToken:)</h3>

When client provides custom visitor authorization mechanism, it can be realised by providing custom authorization token which is used instead of visitor fields.
Method sets [ProvidedAuthorizationTokenStateListener](#provided-authorization-token-state-listener) object and provided authorization token. Setting custom token is optional, if is not set, library generates its own.
Returns `self` with visitor authorization data set.
Method is not mandatory to create [WebimSession](#webim-session) object.
Can't be used simultaneously with [set(visitorFieldsJSONString:)](#set-visitor-fields-json-string-json-string) or [set(visitorFieldsJSONString:)](#set-visitor-fields-json-data-json-data).

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

<h3 id ="set-not-fatal-error-handler">Instance method set(notFatalErrorHandler:)</h3>

Sets [NotFatalErrorHandler](#not-fatal-error-handler) object for session.
`notFatalErrorHandler` parameter – any object of a class or struct that conforms to `NotFatalErrorHandler` protocol.
Returns `self` with `NotFatalErrorHandler` set.
Method is not mandatory to create [WebimSession](#webim-session) object.

<h3 id ="set-remote-notification-system">Instance method set(remoteNotificationSystem:)</h3>

Sets remote notification system to use for receiving push notifications from _Webim_ service.
`remoteNotificationSystem` parameter – [RemoteNotificationSystem](#remote-notification-system) enum value. If parameter value is not [none](#none), [set(deviceToken:)](#set-device-token) method is mandatory to be called too. With [none](#none) value passed it does nothing.
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
Returns `self` with the functionality activation setting.
Method is not mandatory to create [WebimSession](#webim-session) object.

<h3 id ="set-multivisitor-section">Instance method set(multivisitorSection:)</h3>

Attention: this method can't be used as is. It requires that client server to support this mechanism!
Sets necesarity to receive remote notifications by different visitors on one device. Without multivisitor section only last visitor can receive remote notifications.
`multivisitorSection` parameter – suffix for device ID. Each visitor has device ID. This parameter can split one device to some virtual devices.
Returns `self` with the functionality activation setting.
Method is not mandatory to create [WebimSession](#webim-session) object.

<h3 id ="set-webim-logger-verbosity-level">Instance method set(webimLogger:verbosityLevel:)</h3>

Method to pass [WebimLogger](#webim-logger) object.
Parameter `verbosityLevel` – [WebimLoggerVerbosityLevel](#webim-logger-verbosity-level) case (can be skipped).
Returns `self` with the functionality activation setting.
Method is not mandatory to create [WebimSession](#webim-session) object.

<h3 id ="build">Instance method build()</h3>

Final method that returns [WebimSession](#webim-session) object.
Can throw errors of [SessionBuilderError](#session-builder-error) type.
The only two mandatory method to call preliminarily are [set(accountName:)](#set-account-name) and [set(location:)](#set-location).

<h3 id ="build-on-success-on-error">Instance method build(onSuccess:onError)</h3>

Final method that returns [WebimSession](#webim-session) object by `onSuccess` completion.
Can throw errors of [SessionBuilderError](#session-builder-error) type by `onError` completion.
The only two mandatory method to call preliminarily are [set(accountName:)](#set-account-name) and [set(location:)](#set-location).

<h3 id ="webim-logger-verbosity-level">WebimLoggerVerbosityLevel enum</h3>

Verbosity level of [WebimLogger](#webim-logger).

<h4 id ="verbose">verbose case</h4>

All available information will be delivered to [WebimLogger](#webim-logger) instance with maximum verbosity level:
* session network setup parameters;
* network requests' URLs, HTTP method and parameters;
* network responses' HTTP codes, received data and errors;
* SQL queries and errors;
* full debug information and additional notes.

<h4 id ="debug">debug case</h4>

All information which is useful when debugging will be delivered to [WebimLogger](#webim-logger) instance with necessary verbosity level:
* session network setup parameters;
* network requests' URLs, HTTP method and parameters;
* network responses' HTTP codes, received data and errors;
* SQL queries and errors;
* moderate debug information.

<h4 id ="info">info case</h4>

Reference information and all warnings and errors will be delivered to [WebimLogger](#webim-logger) instance:
* network requests' URLS, HTTP method and parameters;
* HTTP codes and errors descriptions of failed requests.
* SQL errors.

<h4 id ="warning">warning case</h4>

Errors and warnings only will be delivered to [WebimLogger](#webim-logger) instance:
* network requests' URLs, HTTP method, parameters, HTTP code and error description.
* SQL errors.

<h4 id ="error">error case</h4>

Only errors will be delivered to [WebimLogger](#webim-logger) instance:
* network requests' URLs, HTTP method, parameters, HTTP code and error description.

<h3 id ="session-builder-error">SessionBuilderError enum</h3>

Error types that can be throwed by [SessionBuilder](#session-builder) [method build()](#build).

<h4 id ="nil-account-name">nilAccountName case</h4>

Error that is thrown when trying to create session object with `nil` account name.

<h4 id ="nil-location">nilLocation case</h4>

Error that is thrown when trying to create session object with `nil` location name.

<h4 id ="invalid-authentication-parameters">invalidAuthentificatorParameters case</h4>

Error that is thrown when trying to use standard and custom visitor fields authentication simultaneously.

<h4 id ="invalid-remote-notification-configuration">invalidRemoteNotificationConfiguration case</h4>

Error that is thrown when trying to create session object with invalid remote notifications configuration.

[Go to table of contents](#table-of-contents)

<h2 id ="provided-authorization-token-state-listener">ProvidedAuthorizationTokenStateListener protocol</h2>

When client provides custom visitor authorization mechanism, it can be realised by providing custom authorization token which is used instead of visitor fields.
When provided authorization token is generated (or passed to session by client app), `update(providedAuthorizationToken:)` method is called. This method call indicates that client app must send provided authorisation token to its server which is responsible to send it to Webim service.
This mechanism can't be used as is. It requires that client server to support this mechanism.

<h3 id ="update-provided-authorization-token">update(providedAuthorizationToken:) method</h3>

Method is called in two cases:
1. Provided authorization token is genrated (or set by client app) and must be sent to client server which is responsible to send it to Webim service.
2. Passed provided authorization token is not valid. Provided authorization token can be invalid if Webim service did not receive it from client server yet.
When this method is called, client server must send provided authorization token to Webim service.
`providedAuthorizationToken` parameter contains provided authentication token which is set and which must be sent to _Webim_ service by client server.

[Go to table of contents](#table-of-contents)

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

<h3 id ="destroy-with-clear-visitor-data">destroyWithClearVisitorData() method</h3>

Deactivates session, performing a cleanup. After that any session methods are not available.
Can throw errors of [AccessError](#access-error) type.


<h3 id ="get-stream">getStream() method</h3>

Returns [MessageStream](#message-stream) object attached to this session. Each invocation of this method returns the same object.

<h3 id ="change-location">change(location:) method</h3>

Changes [location](https://webim.ru/help/help-terms/) without creating a new session.
`location` parameter – new location name of `String` type.
Can throw errors of [AccessError](#access-error) type.

<h3 id="set-device-token">set(deviceToken:) method</h3>

Sets device token.

[Go to table of contents](#table-of-contents)

<h2 id ="message-stream">MessageStream protocol</h2>

Provides methods to interact with _Webim_ service.

<h3 id ="get-visit-session-state">getVisitSessionState() method</h3>

Returns current session state ([VisitSessionState type](#visit-session-state).

<h3 id ="get-chat-state">getChatState() method</h3>

Returns current chat state of [ChatState](#chat-state) type.

<h3 id ="get-unread-by-operator-timestamp">getUnreadByOperatorTimestamp() method</h3>

Returns timestamp (of type `Date`) after which all chat messages are unread by operator (at the moment of last server update recieved).

<h3 id ="get-unread-by-visitor-message-count">getUnreadByVisitorMessageCount() method</h3>

Returns unread by visitor message count.

<h3 id ="get-unread-by-visitor-timestamp">getUnreadByVisitorTimestamp() method</h3>

Returns timestamp (of type `Date`) after which all chat messages are unread by visitor (at the moment of last server update recieved) or `nil` if there's no unread by visitor messages.

<h3 id ="get-department-list">getDepartmentList() method</h3>

Returns array of departments ([Department](#department)) or `nil` if there're any or department list is not recieved yet.

<h3 id ="get-location-settings">getLocationSettings() method</h3>

Returns current [LocationSettings](#location-settings) object.

<h3 id ="get-current-operator">getCurrentOperator() method</h3>

Returns [Operator](#operator-protocol) object of the current chat or `nil` if one does not exist.

<h3 id ="get-last-rating-of-operator-with-id">getLastRatingOfOperatorWith(id:) method</h3>

Returns previous rating of the operator or `0` if it was not rated before.
`id` parameter – `String`-typed ID of operator.

<h3 id ="rate-operator-with-id-by-rating-rating">rateOperatorWith(id:byRating:completionHandler:) method</h3>

Rates an operator.
To get an ID of the current operator call [getCurrentOperator()](#get-current-operator).
`id` parameter – String-typed ID of the operator to be rated. Optional: if `nil` is passed, current chat operator will be rated.
`rating` parameter – a number in range (1...5) that represents an operator rating. If the number is out of range, rating will not be sent to a server.
`completionHandler` parameter – [RateOperatorCompletionHandler](#rate-operator-completion-handler) object.
Can throw errors of [AccessError](#access-error) type.

<h3 id ="rate-operator-with-id-note-by-rating-rating">rateOperatorWith(id:note:byRating:completionHandler:) method</h3>

Attention: this method can't be used as is. It requires that client server to support this mechanism!
Rates an operator.
To get an ID of the current operator call [getCurrentOperator()](#get-current-operator).
`id` parameter – String-typed ID of the operator to be rated. Optional: if `nil` is passed, current chat operator will be rated.
`note` parameter – String-typed comment for rating. Max length is 2000 characters. 
`rating` parameter – a number in range (1...5) that represents an operator rating. If the number is out of range, rating will not be sent to a server.
`completionHandler` parameter – [RateOperatorCompletionHandler](#rate-operator-completion-handler) object.
Can throw errors of [AccessError](#access-error) type.

<h3 id ="respond-sentry-call">respondSentryCall(id:) method</h3>

Attention: this method can't be used as is. It requires that client server to support this mechanism!
Respond sentry call.
`id` parameter – String-typed ID of redirect to sentry message.
Can throw errors of [AccessError](#access-error) type.

<h3 id ="start-chat">startChat() method</h3>

Changes [ChatState](#chat-state) to [queue](#queue).
Method call is not mandatory, send message or send file methods start chat automatically. If account settings provide automatic complimentary message it won't be sent before any "startChat" method or first sent message.
Can throw errors of [AccessError](#access-error) type.

<h3 id ="start-chat-first-question">startChat(firstQuestion:) method</h3>

Changes [ChatState](#chat-state) to [queue](#queue). Starts chat and sends first message simultaneously.
Method call is not mandatory, send message or send file methods start chat automatically. If account settings provide automatic complimentary message it won't be sent before any "startChat" method or first sent message.
Can throw errors of [AccessError](#access-error) type.

<h3 id ="start-chat-custom-fields">startChat(customFields:) method</h3>

Attention: this method can't be used as is. It requires that client server to support this mechanism!
Changes [ChatState](#chat-state) to [queue](#queue). Starts chat with custom fields.
Method call is not mandatory. Starts chat with custom fields.
`customFields` paramater – String-typed custom fields in JSON format.
Can throw errors of [AccessError](#access-error) type.

<h3 id ="start-chat-department-key">startChat(departmentKey:) method</h3>

Starts chat with particular department. Department is identified by `departmentKey` parameter (see [getKey()](#get-key) of [Department](#department) protocol)
Changes [ChatState](#chat-state) to [queue](#queue).
In most cases method call is not mandatory, send message or send file methods start chat automatically. But it is mandatory when [VisitSessionState](#visit-session-state) is in [departmentSelection state](#department-selection).
If account settings provide automatic complimentary message it won't be sent before any "startChat" method or first sent message.
Can throw errors of [AccessError](#access-error) type.

<h3 id ="start-chat-department-key-first-question">startChat(departmentKey:firstQuestion:) method</h3>

Starts chat with particular department  and sends first message simultaneously. Department is identified by `departmentKey` parameter (see [getKey()](#get-key) of [Department](#department) protocol)
Changes [ChatState](#chat-state) to [queue](#queue).
In most cases method call is not mandatory, send message or send file methods start chat automatically. But it is mandatory when [VisitSessionState](#visit-session-state) is in [departmentSelection state](#department-selection).
If account settings provide automatic complimentary message it won't be sent before any "startChat" method or first sent message.
Can throw errors of [AccessError](#access-error) type.

<h3 id ="start-chat-first-question-custom-fields">startChat(firstQuestion:customFields:) method</h3>

Attention: this method can't be used as is. It requires that client server to support this mechanism!
Starts chat with custom fields and sends first message simultaneously.
Changes [ChatState](#chat-state) to [queue](#queue).
If account settings provide automatic complimentary message it won't be sent before any "startChat" method or first sent message.
Can throw errors of [AccessError](#access-error) type.

<h3 id ="start-chat-department-key-custom-fields">startChat(departmentKey:customFields:) method</h3>

Attention: this method can't be used as is. It requires that client server to support this mechanism!
Starts chat with particular department and custom fields. Department is identified by `departmentKey` parameter (see [getKey()](#get-key) of [Department](#department) protocol)
Changes [ChatState](#chat-state) to [queue](#queue).
In most cases method call is not mandatory, send message or send file methods start chat automatically. But it is mandatory when [VisitSessionState](#visit-session-state) is in [departmentSelection state](#department-selection).
If account settings provide automatic complimentary message it won't be sent before any "startChat" method or first sent message.
Can throw errors of [AccessError](#access-error) type.

<h3 id ="start-chat-department-key-first-question-custom-fields">startChat(departmentKey:firstQuestion:customFields:) method</h3>

Attention: this method can't be used as is. It requires that client server to support this mechanism!
Starts chat with particular department and customFields  and sends first message simultaneously. Department is identified by `departmentKey` parameter (see [getKey()](#get-key) of [Department](#department) protocol)
Changes [ChatState](#chat-state) to [queue](#queue).
In most cases method call is not mandatory, send message or send file methods start chat automatically. But it is mandatory when [VisitSessionState](#visit-session-state) is in [departmentSelection state](#department-selection).
If account settings provide automatic complimentary message it won't be sent before any "startChat" method or first sent message.
Can throw errors of [AccessError](#access-error) type.

<h3 id ="close-chat">closeChat() method</h3>

Changes [ChatState](#chat-state) to [closedByVisitor](#closed-by-visitor).
Can throw errors of [AccessError](#access-error) type.

<h3 id ="set-visitor-typing-draft-message">setVisitorTyping(draftMessage:) method</h3>

This method must be called whenever there is a change of the input field of a message transferring current content of a message as a parameter. When `nil` value passed it means that visitor stopped to type a message or deleted it.
When there's multiple calls of this method occured, draft message is sending to service one time per second.
Can throw errors of [AccessError](#access-error) type.

<h3 id ="send-message-data">send(message:data:completionHandler:) method</h3>

Attention: this method can't be used as is. It requires that client server to support this mechanism!
Sends a text message.
When calling this method, if there is an active [MessageTracker](#message-tracker) object. [added(message newMessage:,after previousMessage:) method](#added-message-new-message-after-previous-message)) with a message [sending case](#sending) in the status is also called.
`message` parameter – `String`-typed message text.
`data` parameter is optional, custom message parameters dictionary. Note that this functionality does not work as is – server version must support it.
`completionHandler` parameter – optional [DataMessageCompletionHandler](#data-message-completion-handler) object.
Returns randomly generated `String`-typed ID of the message.
Can throw errors of [AccessError](#access-error) type.

<h3 id ="send-message-is-hint-question">send(message:isHintQuestion:) method</h3>

Attention: this method can't be used as is. It requires that client server to support this mechanism!
Sends a text message.
When calling this method, if there is an active [MessageTracker](#message-tracker) object. [added(message newMessage:,after previousMessage:) method](#added-message-new-message-after-previous-message)) with a message [sending case](#sending) in the status is also called.
`message` parameter – `String`-typed message text.
`isHintQuestion` parameter shows to server if a visitor chose a hint (true value) or wrote his own text (`false`). Optional to use.
Returns randomly generated `String`-typed ID of the message.
Can throw errors of [AccessError](#access-error) type.

<h3 id ="send-file-filename-mime-type-completion-handler">send(file:filename:mimeType:completionHandler:) method</h3>

Sends a file message.
When calling this method, if there is an active [MessageTracker](#message-tracker) object. [added(message newMessage:,after previousMessage:) method](#added-message-new-message-after-previous-message)) with a message [sending case](#sending) in the status is also called.
`file` parameter – file represented in `Data` type.
`filename` parameter – file name of `String` type.
`mimeType` parameter – MIME type of the file to send of `String` type.
`completionHandler` parameter – optional [SendFileCompletionHandler](#send-file-completion-handler) object.
Returns randomly generated `String`-typed ID of the message.
Can throw errors of [AccessError](#access-error) type.

<h3 id ="send-keyboard-request">sendKeyboardRequest(button:message:completionHandler:) method</h3>

Sends a keyboard request.
`button` parameter – selected button of [`KeyboardButton`](#keyboard-button) type.
`message` parameter – keyboard message of [`Message`](#message) type.
`completionHandler` parameter – optional [SendKeyboardRequestCompletionHandler](#send-keyboard-request-completion-handler) object.
Can throw errors of [AccessError](#access-error) type.

<h3 id ="send-keyboard-request-with-id">sendKeyboardRequest(buttonID:messageCurrentChatID:completionHandler:) method</h3>

Sends a keyboard request.
`buttonID` parameter – id of selected button of `String` type.
`messageCurrentChatID` parameter – current chat if of keyboard message of `String` type.
`completionHandler` parameter – optional [SendKeyboardRequestCompletionHandler](#send-keyboard-request-completion-handler) object.
Can throw errors of [AccessError](#access-error) type.

<h3 id ="update-widget-status">updateWidgetStatus(data:) method</h3>

Attention: this method can't be used as is. It requires that client server to support this mechanism!
Update widget status. The change is displayed by the operator.
`data` parameter – JSON string with new widget status.
Can throw errors of [AccessError](#access-error) type.

<h3 id="reply-message">reply(message:repliedMessage:) method</h3>

Reply a message.
When calling this method, if there is an active [MessageTracker](#message-tracker) object. [added(message newMessage:,after previousMessage:) method](#added-message-new-message-after-previous-message)) with a message [sending case](#sending) in the status is also called.
`message` parameter – text of the message of `String` type.
`replied message` – replied message of [`Message`](#message) type.
Returns randomly generated `String`-typed ID of the message or `nil` if message can't be replied.
Can throw errors of [AccessError](#access-error) type.

<h3 id ="edit-message">edit(message:text:completionHandler:) method</h3>

Edits a text message.
Before calling this method recommended to find out the possibility of editing the message using [canBeEdited() method](#can-be-edited).
When calling this method, if there is an active [MessageTracker](#message-tracker) object. [changed(message:,to:) method](changed-message-old-version-to-new-version) with a message [sending case](#sending) in the status is also called.
`message` parameter – message in `Message` type.
`text` parameter – new message text of `String` type.
`completionHandler` parameter – optional [EditMessageCompletionHandler](#edit-message-completion-handler) object.
Returns true if message can be edited.
Can throw errors of [AccessError](#access-error) type.

<h3 id ="delete-message">delete(message:completionHandler:) method</h3>

Deletes a text message.
Before calling this method recommended to find out the possibility of editing the message using [canBeEdited() method](#can-be-edited).
When calling this method, if there is an active [MessageTracker](#message-tracker) object. [removed(message:) method](#removed-message) with a message [sent case](#sent) in the status is also called.
`message` parameter – message in `Message` type.
`completionHandler` parameter – optional [DeleteMessageCompletionHandler](#delete-message-completion-handler) object.
Returns true if message can be deleted.
Can throw errors of [AccessError](#access-error) type.

<h3 id ="set-chat-read">setChatRead() method</h3>

Set chat has been read by visitor.
Can throw errors of [AccessError](#access-error) type.

<h3 id ="send-dialog-to-email-address">sendDialogTo(emailAddress: String, completionHandler: SendDialogToEmailAddressCompletionHandler?) throws method</h3>

Sends current dialog to email address.

`emailAddress` parameter – email address in `String` type.

`completionHandler` parameter – optional [SendDialogToEmailAddressCompletionHandler](#send-dialog-to-email-address-completion-handler) object.

Can throw errors of [AccessError](#access-error) type.

<h3 id ="set-prechat-fields">set(prechatFields:) method</h3>

Attention: this method can't be used as is. It requires that client server to support this mechanism!
Sends prechat fields to server.
Can throw errors of [AccessError](#access-error) type.

<h3 id ="new-message-tracker-message-listener">newMessageTracker(messageListener:) method</h3>

Returns [MessageTracker](#message-tracker) object wich (via [getNextMessages(byLimit limitOfMessages:,completion:)](#get-next-nessages-by-limit-limit-of-messages-completion)) allows to request the messages from above in the history. Each next call [getNextMessages(byLimit limitOfMessages:,completion:)](#get-next-nessages-by-limit-limit-of-messages-completion) returns earlier messages in relation to the already requested ones.
Changes of user-visible messages (e.g. ever requested from [MessageTracker](#message-tracker)) are transmitted to [MessageListener](#message-listener). That is why [MessageListener](#message-listener) object is needed when creating [MessageTracker](#message-tracker).
For each [MessageStream](#message-stream) at every single moment can exist the only one active [MessageTracker](#message-tracker). When creating a new one at the previous there will be automatically called [destroy()](#destroy-message-tracker).
Can throw errors of [AccessError](#access-error) type.

<h3 id ="set-visit-session-state-listener">set(visitSessionStateListener:) method</h3>

Sets [VisitSessionStateListener](#visit-session-state-listener) object to track changes of [VisitSessionState](#visit-session-state).

<h3 id ="set-chat-state-listener">set(chatStateListener:) method</h3>

Sets [ChatStateListener](#chat-state-listener) object.

<h3 id ="set-current-operator-change-listener">set(currentOperatorChangeListener:) method</h3>

Sets [CurrentOperatorChangeListener](#current-operator-change-listener) object.

<h3 id ="set-department-list-change-listener">set(departmentListChangeListener:) method</h3>

Sets [DepartmentListChangeListener](#department-list-change-listener) object to track changes of department list.

<h3 id ="set-operator-typing-listener">set(operatorTypingListener:) method</h3>

Sets [OperatorTypingListener](#operator-typing-listener) object.

<h3 id ="set-location-settings-change-listener">set(locationSettingsChangeListener:) method</h3>

Sets [LocationSettingsChangeListener](#location-settings-shange-listener) object.

<h3 id ="set-session-online-status-change-listener">set(onlineStatusChangeListener:) method</h3>

Sets [OnlineStatusChangeListener](#session-online-status-change-listener) object.

<h3 id ="set-unread-by-operator-timestamp-change-listener">set(unreadByOperatorTimestampChangeListener:) method</h3>

Sets [UnreadByOperatorTimestampChangeListener](#unread-by-operator-timestamp-change-listener) object.

<h3 id ="set-unread-by-visitor-message-count-change-listener">set(unreadByVisitorMessageCountChangeListener:) method</h3>

Sets [UnreadByVisitorMessageCountChangeListener](#unread-by-visitor-message-count-change-listener) object.

<h3 id ="set-unread-by-visitor-timestamp-change-listener">set(unreadByVisitorTimestampChangeListener:) method</h3>

Sets [UnreadByVisitorTimestampChangeListener](#unread-by-visitor-timestamp-change-listener) object.

[Go to table of contents](#table-of-contents)

<h2 id ="data-message-completion-handler">DataMessageCompletionHandler protocol</h2>

Attention: this mechanism can't be used as is. It requires that client server to support this mechanism!
Protocol which methods are called after [send(message:data:completionHandler:)](#send-message-data) method is finished. Must be adopted.

<h3 id ="on-success-message-id-data-message-completion-handler">onSuccess(messageID:) method</h3>

Executed when operation is done successfully.
`messageID` parameter – ID of the appropriate message of `String` type.

<h3 id ="on-failure-message-id-error-data-message-completion-handler">onFailure(messageID:error:) method</h3>

Executed when operation is failed.
`messageID` parameter – ID of the appropriate message of `String` type.
`error` parameter – appropriate [DataMessageError](#data-message-error) value.

[Go to table of contents](#table-of-contents)

<h2 id ="edit-message-completion-handler">EditMessageCompletionHandler protocol</h2>

Protocol which methods are called after [edit(message:text:completionHandler:)](#edit-message) method is finished. Must be adopted.

<h3 id ="on-success-message-id-edit-message-completion-handler">onSuccess(messageID:) method</h3>

Executed when operation is done successfully.
`messageID` parameter – ID of the appropriate message of `String` type.

<h3 id ="on-failure-message-id-error-edit-message-completion-handler">onFailure(messageID:error:) method</h3>

Executed when operation is failed.
`messageID` parameter – ID of the appropriate message of `String` type.
`error` parameter – appropriate [EditMessageError](#edit-message-error) value.

[Go to table of contents](#table-of-contents)

<h2 id ="delete-message-completion-handler">DeleteMessageCompletionHandler protocol</h2>

Protocol which methods are called after [delete(message:completionHandler:)](#delete-message) method is finished. Must be adopted.

<h3 id ="on-success-message-id-delete-message-completion-handler">onSuccess(messageID:) method</h3>

Executed when operation is done successfully.
`messageID` parameter – ID of the appropriate message of `String` type.

<h3 id ="on-failure-message-id-error-delete-message-completion-handler">onFailure(messageID:error:) method</h3>

Executed when operation is failed.
`messageID` parameter – ID of the appropriate message of `String` type.
`error` parameter – appropriate [DeleteMessageError](#delete-message-error) value.

[Go to table of contents](#table-of-contents)

<h2 id ="send-file-completion-handler">SendFileCompletionHandler protocol</h2>

Protocol which methods are called after [send(file:filename:mimeType:completionHandler:)](#send-file-filename-mime-type-completion-handler) method is finished. Must be adopted.

<h3 id ="on-success-message-id">onSuccess(messageID:) method</h3>

Executed when operation is done successfully.
`messageID` parameter – ID of the appropriate message of `String` type.

<h3 id ="on-failure-message-id-error">onFailure(messageID:error:) method</h3>

Executed when operation is failed.
`messageID` parameter – ID of the appropriate message of `String` type.
`error` parameter – appropriate [SendFileError](#send-file-error) value.

[Go to table of contents](#table-of-contents)

<h2 id ="send-keyboard-request-completion-handler">SendKeyboardRequestCompletionHandler protocol</h2>

Protocol which methods are called after [sendKeyboardRequest(button:message:completionHandler:)](#send-keyboard-request) or  [sendKeyboardRequest(buttonID:messageCurrentChatID:completionHandler:)](#send-keyboard-request-with-id) method is finished. Must be adopted.

<h3 id ="on-success-message-id-send-keyboard-request">onSuccess(messageID:) method</h3>

Executed when operation is done successfully.
`messageID` parameter – ID of the appropriate message of `String` type.

<h3 id ="on-failure-message-id-error-send-keyboard-request">onFailure(messageID:error:) method</h3>

Executed when operation is failed.
`messageID` parameter – ID of the appropriate message of `String` type.
`error` parameter – appropriate [KeyboardResponseError](#keyboard-response-error) value.

[Go to table of contents](#table-of-contents)

<h2 id ="rate-operator-completion-handler">RateOperatorCompletionHandler protocol</h2>

Protocol which methods are called after [rateOperatorWith(id:byRating:completionHandler:)](#rate-operator-with-id-by-rating-rating) or [rateOperatorWith(id:note:byRating:completionHandler:)](#rate-operator-with-id-note-by-rating-rating) method is finished. Must be adopted.

<h3 id ="on-success">onSuccess() method</h3>

Executed when operation is done successfully.

<h3 id ="on-failure-error">onFailure(error:) method</h3>

Executed when operation is failed.
`error` parameter – appropriate [RateOperatorError](#rate-operator-error) value.

[Go to table of contents](#table-of-contents)

<h2 id ="send-dialog-to-email-address-completion-handler">SendDialogToEmailAddressCompletionHandler protocol</h2>

Protocol which methods are called after [sendDialogTo(emailAddress:completionHandler:)](#send-dialog-to-email-address). Must be adopted.

<h3 id ="on-success-send-dialog">onSuccess() method</h3>

Executed when operation is done successfully.

<h3 id ="on-failure-error-send-dialog">onFailure(error:) method</h3>

Executed when operation is failed.
`error` parameter – appropriate [SendDialogToEmailAddressError](#send-dialog-to-email-address-error) value.

[Go to table of contents](#table-of-contents)

<h2 id ="visit-session-state-listener">VisitSessionStateListener protocol</h2>

Provides methods to track changes of [VisitSessionState](#visit-session-state) status.

<h3 id ="#changed-state-previous-state-to-new-state-visit-session-state-listener">changed(state:to:) method</h3>

Called when [VisitSessionState](#visit-session-state) status is changed. Parameters contain its previous and new values.

[Go to table of contents](#table-of-contents)

<h2 id ="department-list-change-listener">DepartmentListChangeListener protocol</h2>

Provides methods to track changes in departments list.

<h3 id ="received-department-list">received(departmentList:) method</h3>

Called when department list is received. Current department list passed inside `departmentList` parameter and presents array of [Department](#department) objects.

[Go to table of contents](#table-of-contents)

<h2 id ="location-settings">LocationSettings protocol</h2>

Interface that provides methods for handling [LocationSettings](#location-settings) which are received from server.

<h3 id ="are-hints-enabled">areHintsEnabled() method</h3>

This method shows to an app if it should show hint questions to visitor. Returns `true` if an app should show hint questions to visitor, `false` otherwise.

[Go to table of contents](#table-of-contents)

<h2 id ="chat-state-listener">ChatStateListener protocol</h2>

Protocol that is to be adopted to track [ChatState](#chat-state) changes.

<h3 id ="changed-state-previous-state-to-new-state">changed(state:to:) method</h3>

Called during [ChatState](#chat-state)transition. Parameters are of [ChatState](#chat-state) type.

[Go to table of contents](#table-of-contents)

<h2 id ="current-operator-change-listener">CurrentOperatorChangeListener protocol</h2>

Protocol that is to be adopted to track if current [Operator](#operator-protocol) object is changed.

<h3 id ="changed-operator-previous-operator-to-new-operator">changed(operator:to:) method</h3>

Called when [Operator](#operator-protocol) object of the current chat changed. Values can be `nil` (if an operator leaved the chat or there was no operator before).

[Go to table of contents](#table-of-contents)

<h2 id ="operator-typing-listener">OperatorTypingListener protocol</h2>

Protocol that is to be adopted to track if the operator started or ended to type a message.

<h3 id ="on-operator-typing-state-changed-is-typing">onOperatorTypingStateChanged(isTyping:) method</h3>

Called when operator typing state changed.
Parameter `isTyping` is `true` if operator is typing, `false` otherwise.

[Go to table of contents](#table-of-contents)

<h2 id ="location-settings-shange-listener">LocationSettingsChangeListener protocol</h2>

Interface that provides methods for handling changes in [LocationSettings](#location-settings).

<h3 id ="changed-location-settings-previous-location-settings-to-new-location-settings">changed(locationSettings:to:) method</h3>

Method called by an app when new [LocationSettings](#location-settings) object is received with parameters that represent previous and new [LocationSettings](#location-settings) objects.

[Go to table of contents](#table-of-contents)

<h2 id ="session-online-status-change-listener">OnlineStatusChangeListener protocol</h2>

Interface that provides methods for handling changes of session status.

<h3 id ="changed-session-online-status-previous-session-online-status-to-new-session-online-status">changed(onlineStatus:to:) method</h3>

Called when new session status is received with parameters that represent previous and new [OnlineStatus](#session-online-status) values.

[Go to table of contents](#table-of-contents)

<h2 id ="unread-by-operator-timestamp-change-listener">UnreadByOperatorTimestampChangeListener protocol</h2>

Interface that provides methods for handling changes of parameter that is to be returned by [getUnreadByOperatorTimestamp() method](#get-unread-by-operator-timestamp).
Can be set by [set(unreadByOperatorTimestampChangeListener:) method](#set-unread-by-operator-timestamp-change-listener).

<h3 id ="changed-unread-by-operator-timestamp-to-new-value">changedUnreadByOperatorTimestampTo(newValue:) method</h3>

Method to be called when parameter that is to be returned by [getUnreadByOperatorTimestamp() method](#get-unread-by-operator-timestamp) method is changed.

[Go to table of contents](#table-of-contents)

<h2 id ="unread-by-visitor-message-count-change-listener">UnreadByVisitorMessageCountChangeListener protocol</h2>

Interface that provides methods for handling changes of parameter that is to be returned by [getUnreadByVisitorMessageCount() method](#get-unread-by-visitor-message-count).
Can be set by [set(unreadByVisitorMessageCountChangeListener:) method](#set-unread-by-visitor-message-count-change-listener).

<h3 id ="changed-unread-by-visitor-message-count-to-new-value">changedUnreadByVisitorMessageCountTo(newValue:) method</h3>

Method to be called when parameter that is to be returned by [getUnreadByVisitorMessageCount() method](#get-unread-by-visitor-message-count) method is changed.

[Go to table of contents](#table-of-contents)

<h2 id ="unread-by-visitor-timestamp-change-listener">UnreadByVisitorTimestampChangeListener protocol</h2>

Interface that provides methods for handling changes of parameter that is to be returned by [getUnreadByVisitorTimestamp() method](#get-unread-by-visitor-timestamp).
Can be set by [set(unreadByVisitorTimestampChangeListener:) method](#set-unread-by-visitor-timestamp-change-listener).

<h3 id ="changed-unread-by-visitor-timestamp-to-new-value">changedUnreadByVisitorTimestampTo(newValue:) method</h3>

Method to be called when parameter that is to be returned by [getUnreadByVisitorTimestamp() method](#get-unread-by-visitor-timestamp) method is changed.

[Go to table of contents](#table-of-contents)

<h2 id ="chat-state">ChatState enum</h2>

A chat is seen in different ways by an operator depending on ChatState.
The initial state is [closed](#closed).
Then if a visitor sends a message ([send(message:isHintQuestion:)](#send-message-is-hint-question)), the chat changes it's state to [queue](#queue). The chat can be turned into this state by calling [startChat() method](#start-chat).
After that, if an operator takes the chat to process, the state changes to [chatting](#chatting). The chat is being in this state until the visitor or the operator closes it.
When closing a chat by the visitor [closeChat() method](#close-chat) it turns into the state [closedByVisitor](#closed-by-visitor), by the operator - [closedByOperator](#closed-by-operator).
When both the visitor and the operator close the chat, it's state changes to the initial – [closed](#closed). A chat can also automatically turn into the initial state during long-term absence of activity in it.
Furthermore, the first message can be sent not only by a visitor but also by an operator. In this case the state will change from the initial to [invitation](#invitation), and then, after the first message of the visitor, it changes to [chatting](#chatting).

<h3 id ="chatting">chatting case</h3>

Means that an operator has taken a chat for processing.
From this state a chat can be turned into:
* [chatting](#chatting), if an operator intercepted the chat;
* [closedByVisitor](#closed-by-visitor), if a visitor closes the chat ([closeChat() method](#close-chat));
* [closed](#closed), automatically during long-term absence of activity.

<h3 id ="chatting-with-robot">chattingWithRobot case</h3>

Means that chat is picked up by a bot.
From this state a chat can be turned into:
* [closedByOperator](#closed-by-operator), if an operator closes the chat;
* [closedByVisitor](#closed-by-visitor), if a visitor closes the chat ([closeChat() method](#close-chat));
* [closed](#closed), automatically during long-term absence of activity.

<h3 id ="closed-by-operator">closedByOperator case</h3>

Means that an operator has closed the chat.
From this state a chat can be turned into:
* [closed](#closed), if the chat is also closed by a visitor ([closeChat() method](#close-chat)), or automatically during long-term absence of activity;
* [queue](#queue), if a visitor sends a new message ([send(message:isHintQuestion:) method](#send-message-is-hint-question)).

<h3 id ="closed-by-visitor">closedByVisitor case</h3>

Means that a visitor has closed the chat.
From this state a chat can be turned into:
* [closed](#closed), if the chat is also closed by an operator or automatically during long-term absence of activity;
* [queue](#queue), if a visitor sends a new message ([send(message:isHintQuestion:) method](#send-message-is-hint-question)).

<h3 id ="invitation">invitation case</h3>

Means that a chat has been started by an operator and at this moment is waiting for a visitor's response.
From this state a chat can be turned into:
* [chatting](#chatting), if a visitor sends a message ([send(message:isHintQuestion:) method](#send-message-is-hint-question));
* [closed](#closed), if an operator or a visitor closes the chat ([closeChat() method](#close-chat)).

<h3 id ="closed">closed case</h3>

Means the absence of a chat as such, e.g. a chat has not been started by a visitor nor by an operator.
From this state a chat can be turned into:
* [queue](#queue), if the chat is started by a visitor (by the first message or by calling [startChat() method](#start-chat));
* [invitation](#invitation), if the chat is started by an operator.

<h3 id ="queue">queue case</h3>

Means that a chat has been started by a visitor and at this moment is being in the queue for processing by an operator.
From this state a chat can be turned into:
* [chatting](#chatting), if an operator takes the chat for processing;
* [closed](#closed), if a visitor closes the chat (by calling ([closeChat() method](#close-chat)) before it is taken for processing;
* [closedByOperator](#closed-by-operator), if an operator closes the chat without taking it for processing.

<h3 id ="unknown">unknown case</h3>

The state is undefined.
This state is set as the initial when creating a new session, until the first response of the server containing the actual state is got. This state is also used as a fallback if _WebimClientLibrary_ can not identify the server state (e.g. if the server has been updated to a version that contains new states).

[Go to table of contents](#table-of-contents)

<h2 id ="session-online-status">OnlineStatus enum</h2>

Online state possible cases.

<h3 id ="busy-offline">busyOffline case</h3>

Offline state with chats' count limit exceeded.
Means that visitor is not able to send messages at all.

<h3 id ="busy-online">busyOnline case</h3>

Online state with chats' count limit exceeded.
Visitor is able send offline messages, but the server can reject it.

<h3 id ="offline">offline case</h3>

Visitor is able send offline messages.

<h3 id ="online">online case</h3>

Visitor is able to send both online and offline messages.

<h3 id ="unknown-session-online-status">unknown case</h3>

Session has not received first session status yet or session status is not supported by this version of the library.

[Go to table of contents](#table-of-contents)

<h2 id ="visit-session-state">VisitSessionState enum</h2>

Session possible states.

<h3 id ="chat-visit-session-state">chat case</h3>

Chat in progress.

<h3 id ="department-selection">departmentSelection case</h3>

Chat must be started with department selected (there was a try to start chat without department selected).

<h3 id ="idle">idle case</h3>

Session is active but no chat is occuring (chat was not started yet).

<h3 id ="idle-after-chat">idleAfterChat case</h3>

Session is active but no chat is occuring (chat was closed recently).

<h3 id ="offline-message">offlineMessage case</h3>

Offline state.

<h3 id ="unknown-visit-session-state">unknown case</h3>

First status is not recieved yet or status is not supported by this version of the library.

[Go to table of contents](#table-of-contents)

<h2 id ="data-message-error">DataMessageError enum</h2>

Attention: this method can't be used as is. It requires that client server to support this mechanism!
Error types that could be passed in [onFailure(messageID:error:) method](#on-failure-message-id-error-data-message-completion-handler).

<h3 id ="unknown-data-message-error">unknown case</h3>

Received error is not supported by current WebimClientLibrary version.

<h3>Quoted message errors.</h3>

<h4 id ="quoted-message-cannot-be-replied">quotedMessageCanNotBeReplied case</h4>

To be raised when quoted message ID belongs to a message without `canBeReplied` flag set to `true` (this flag is to be set on the server-side).

<h4 id ="quoted-message-from-another-visitor">quotedMessageFromAnotherVisitor case</h4>

To be raised when quoted message ID belongs to another visitor chat.

<h4 id ="quoted-message-multiple-ids">quotedMessageMultipleIds case</h4>

To be raised when quoted message ID belongs to multiple messages (server data base error).

<h4 id ="quoted-message-required-arguments-missing">quotedMessageRequiredArgumentsMissing case</h4>

To be raised when one or more required arguments of quoting mechanism are missing.

<h4 id ="quoted-message-wrong-id">quotedMessageWrongId case</h4>

To be raised when wrong quoted message ID is sent.

[Go to table of contents](#table-of-contents)

<h2 id ="data-message-error">EditMessageError enum</h2>

Error types that could be passed in [onFailure(messageID:error:) method](#on-failure-message-id-error-edit-message-completion-handler).

<h3 id ="unknown-edit-message-error">unknown case</h3>

Received error is not supported by current WebimClientLibrary version.

<h3 id="not-allowed-edit-message-error">notAllowed case</h3>

Editing messages by visitor is turned off on the server.

<h3 id=message-empty-edit-message-error">messageEmpty case</h3>

Editing message is empty.

<h3 id=message-not-owned-edit-message-error">messageNotOwned case</h3>

Visitor can edit only his messages. The specified id belongs to someone else's message.

<h3 id=max-length-exceeded-edit-message-error">maxLengthExceeded case</h3>

The server may deny a request if the message size exceeds a limit. The maximum size of a message is configured on the server.

<h3 id=wrong-message-kind-edit-message-error">wrongMesageKind case</h3>

Visitor can edit only text messages.

[Go to table of contents](#table-of-contents)

<h2 id ="delete-message-error">DeleteMessageError enum</h2>

Error types that could be passed in [onFailure(messageID:error:) method](#on-failure-message-id-error-delete-message-completion-handler).

<h3 id ="unknown-delete-message-error">unknown case</h3>

Received error is not supported by current WebimClientLibrary version.

<h3 id="not-allowed-delete-message-error">notAllowed case</h3>

Editing messages by visitor is turned off on the server.

<h3 id=message-not-owned-delete-message-error">messageNotOwned case</h3>

Visitor can edit only his messages. The specified id belongs to someone else's message.

<h3 id=max-length-exceeded-edit-message-error">messageNotFound case</h3>

Message with the specified id is not found in history.

[Go to table of contents](#table-of-contents)

<h2 id ="send-file-error">SendFileError enum</h2>

Error types that could be passed in [onFailure(messageID:error:) method](#on-failure-message-id-error).

<h3 id ="file-size-exceeded">fileSizeExceeded case</h3>

The server may deny a request if the file size exceeds a limit.
The maximum size of a file is configured on the server.

<h3 id ="file-type-not-allowed">fileTypeNotAllowed case</h3>

The server may deny a request if the file type is not allowed.
The list of allowed file types is configured on the server.

<h3 id ="uploaded-file-not-found">uploadedFileNotFound case</h3>

Sending files in body is not supported. Use multipart form only.

<h3 id ="file-sending-unknown">unknown case</h3>

Received error is not supported by current WebimClientLibrary version.

[Go to table of contents](#table-of-contents)

<h2 id ="keyboard-response-error">KeyboardResponseError enum</h2>

Error types that could be passed in [onFailure(messageID:error:) method](#on-failure-message-id-error-send-keyboard-request).

<h3 id ="keyboard-response-error-no-chat">noChat case</h3>

Arised when trying to send keyboard request if no chat is exists.

<h3 id ="button-id-not-set">buttonIdNotSet case</h3>

Wrong button ID in request.

<h3 id ="request-message-id-not-set">requestMessageIdNotSet case</h3>

Wrong message ID in request.

<h3 id=can-not-create-response>canNotCreateResponse case</h3>

Response can not be created for this request.

<h3 id ="keyboard-response-error-unknown">unknown case</h3>

Received error is not supported by current WebimClientLibrary version.

[Go to table of contents](#table-of-contents)

<h2 id ="rate-operator-error">RateOperatorError enum</h2>

Error types that could be passed in [onFailure(error:) method](#on-failure-error).

<h3 id ="no-chat">noChat case</h3>

Arised when trying to send operator rating request if no chat is exists.

<h3 id ="wrong-operator-id">wrongOperatorId case</h3>

Arised when trying to send operator rating request if passed operator ID doesn't belong to existing chat operator  (or, in the same place, chat doesn't have an operator at all).

[Go to table of contents](#table-of-contents)

<h2 id ="send-dialog-to-email-address-error">SendDialogToEmailAddressError enum</h2>

Error types that could be passed in [onFailure(error:) method](#on-failure-error-send-dialog).

<h3 id ="no-chat-send-dialog">noChat case</h3>

Arised when trying to send dialog to email address request if no chat is exists.

<h3 id ="sent-too-many-times">sentTooManyTimes case</h3>

Arised when trying to send dialog more than three times.

<h3 id ="unknown-send-dialog-error">unknown case</h3>

Unknow error.

[Go to table of contents](#table-of-contents)

<h2 id ="message-tracker">MessageTracker protocol</h2>

[MessageTracker](#message-tracker) object has two purposes:
- it allows to request the messages which are above in the history;
- it defines an interval within which message changes are transmitted to the listener (see [newMessageTracker(messageListener:) method](#new-message-tracker-message-listener)).

<h3 id ="get-last-messages-by-limit-limit-of-messages-completion">getLastMessages(byLimit:completion:) method</h3>

Requests last messages from history. Returns not more than `limitOfMessages` of messages. If an empty list is passed inside completion, there no messages in history yet.
If there is any previous [MessageTracker](#message-tracker) request that is not completed, or limit of messages is less than 1, or current [MessageTracker](#message-tracker) has been destroyed, this method will do nothing.
Following history request can be fulfilled by [getLastMessages(byLimit:completion:)](#get-last-messages-by-limit-limit-of-messages-completion) method.
Completion is called with received array of [Message](#message) objects as the parameter. It is guaranteed that completion will be called with empty or not result if call didn't throw an error. If current `MessageTracker` is destroyed completion will be called on empty result.
Can throw errors of [AccessError](#access-error) type.

<h3 id ="get-next-nessages-by-limit-limit-of-messages-completion">getNextMessages(byLimit:completion:) method</h3>

Requests the messages above in history. Returns not more than `limitOfMessages` of messages. If an empty list is passed inside completion, the end of the message history is reached.
If there is any previous [MessageTracker](#message-tracker) request that is not completed, or limit of messages is less than 1, or current [MessageTracker](#message-tracker) has been destroyed, this method will do nothing.
Notice that this method can not be called again until the callback for the previous call will be invoked.
Completion is called with received array of [Message](#message) objects as the parameter. It is guaranteed that completion will be called with empty or not result if call didn't throw an error. If current `MessageTracker` is destroyed completion will be called on empty result.
Can throw errors of [AccessError](#access-error) type.

<h3 id ="get-all-messages-completion">getAllMessages(completion:) method</h3>

Requests all messages from history. If an empty list is passed inside completion, there no messages in history yet.
If there is any previous [MessageTracker](#message-tracker) request that is not completed, or current [MessageTracker](#message-tracker) has been destroyed, this method will do nothing.
This method is totally independent on [getLastMessages(byLimit:completion:)](#get-last-messages-by-limit-limit-of-messages-completion) and [getNextMessages(byLimit:completion:)](#get-next-nessages-by-limit-limit-of-messages-completion) methods calls.
Completion is called with received array of [Message](#message) objects as the parameter. It is guaranteed that completion will be called with empty or not result if call didn't throw an error. If current `MessageTracker` is destroyed completion will be called on empty result.
Can throw errors of [AccessError](#access-error) type.

<h3 id ="reset-to-message">resetTo(message:) method</h3>

[MessageTracker](#message-tracker) retains some range of messages. By using this method one can move the upper limit of this range to another message.
If there is any previous [MessageTracker](#message-tracker) request that is not completed, this method will do nothing.
Notice that this method can not be used unless the previous call [getNextMessages(byLimit:completion:)](#get-next-nessages-by-limit-limit-of-messages-completion) was finished (completion handler was invoked).
Parameter `message` – [Message](#message) object reset to.
Can throw errors of [AccessError](#access-error) type.

<h3 id ="destroy-message-tracker">destroy() method</h3>

Destroys the [MessageTracker](#message-tracker). It is impossible to use any [MessageTracker](#message-tracker) methods after it was destroyed.
Isn't mandatory to be called.

[Go to table of contents](#table-of-contents)

<h2 id ="message-listener">MessageListener protocol</h2>

Should be adopted. Provides methods to track changes inside message stream.

<h3 id ="added-message-new-message-after-previous-message">added(message:after:) method</h3>

Called when added a new message.
If `previousMessage == nil` then it should be added to the end of message history (the lowest message is added), in other cases the message should be inserted before the message (i.e. above in history) which was given as a parameter `previousMessage`.
Notice that this is a logical insertion of a message. I.e. calling this method does not necessarily mean receiving a new (unread) message. Moreover, at the first call [getNextMessages(byLimit:completion:)](#get-next-nessages-by-limit-limit-of-messages-completion) most often the last messages of a local history (i.e. which is stored on a user's device) are returned, and this method will be called for each message received from a server after a successful connection.
Parameters are of type [Message](#message). `previousMessage` represents a message after which it is needed to make a message insert. If `nil` then an insert is performed at the end of the list.

<h3 id ="removed-message">removed(message:) method</h3>

Called when removing a message.
`message` parameter is of type [Message](#message).

<h3 id ="removed-all-messages">removedAllMessages() method</h3>

Called when removed all the messages.

<h3 id ="changed-message-old-version-to-new-version">changed(message:to:) method</h3>

Called when changing a message.
[Message](#message) is an immutable type and field values can not be changed. That is why message changing occurs as replacing one object with another. Thereby you can find out, for example, which certain message fields have changed by comparing an old and a new object values.
Parameters are of type [Message](#message).

[Go to table of contents](#table-of-contents)

<h2 id ="message">Message protocol</h2>

Abstracts a single message in the message history.
A message is an immutable object. It means that changing some of the message fields creates a new object. Messages can be compared by using [isEqual(to:)](#is-equal-to-message) method for searching messages with the same set of fields or by ID (`message1.getID() == message2.getID()`) for searching logically identical messages. ID is formed on the client side when sending a message ([send(message:isHintQuestion:)](#send-message-is-hint-question) or [send(file:filename:mimeType:completionHandler:)](#send-file-filename-mime-type-completion-handler)).

<h3 id ="get-attachment">getAttachment() method</h3>

Messages of the types [fileFromOperator](#file-from-operator) and [fileFromVisitor](#file-from-visitor) can contain attachments.
Returns [MessageAttachment](#message-attachment) object. Notice that this method may return nil even in the case of previously listed types of messages. E.g. if a file is being sent.

<h3 id ="get-data">getData() method</h3>

Messages of type [actionRequest](#action-request) contain custom dictionary.
Returns dictionary which contains custom fields or `nil` if there's no such custom fields.

<h3 id ="get-id">getID() method</h3>

Every message can be uniquefied by its ID. Messages also can be lined up by its IDs. ID doesn’t change while changing the content of a message.
Returns unique ID of the message of type `String`.

<h3 id="get-current-chat-id">getCurrentChatID() method</h3>

Returns unique current chat id of the message of type `String` or `nil`.

<h3 id="get-keyboard">getKeyboard() method</h3>

Messages of type [Keyboard](#keyboard-type) contain keyboard from script robot.
Returns [Keyboard](#keyboard) which contains keyboard from script robot or `nil` if message isn't of type [Keyboard](#keyboard-type).

<h3 id="get-keyboard-request">getKeyboardRequest() method</h3>

Messages of type [keyboardResponse](#keyboard-response-type) contain request with message of type [Keyboard](#keyboard-type).
Returns [KeyboardRequest](#keyboard-request) which contains keyboard request or `nil` if message isn't of type [keyboardResponse](#keyboard-response-type).

<h3 id ="get-operator-id">getOperatorID() method</h3>

Returns ID of a message sender, if the sender is an operator, of type `String`.

<h3 id="get-quote">getQuote() method</h3>

Returns quote message of type [`Quote`](#quote) or `nil`.

<h3 id ="get-sender-avatar-full-url">getSenderAvatarFullURL() method</h3>

Returns `URL` of a sender's avatar or `nil` if one does not exist.

<h3 id ="get-sender-name">getSenderName() method</h3>

Returns name of a message sender of type `String`.

<h3 id ="get-send-status">getSendStatus() method</h3>

Returns [sent](#sent) if a message had been sent to the server, was received by the server and was delivered to all the clients; [sending](#sending) if not.

<h3 id ="get-text">getText() method</h3>

Returns text of the message of type `String`.

<h3 id ="get-time">getTime() method</h3>

Returns `Date` the message was processed by the server.

<h3 id ="get-type">getType() method</h3>

Returns type of a message of [MessageType](#message-type) type.

<h3 id ="is-equal-to-message">isEqual(to:) method</h3>

Method which can be used to compare if two [Message](#message) objects have identical contents.
Returns `true` if two [Message](#message) objects are identical and `false` otherwise.

Example code:
````
if messageOne.isEqual(to: messageTwo) { /* … */ }
````
Where `messageOne` and `messageTwo` are any `Message` objects.

<h3 id ="is-read-by-operator">isReadByOperator() method</h3>

Returns true if visitor message read by operator or this message is not by visitor and false otherwise.

[Go to table of contents](#table-of-contents)

<h3 id ="can-be-edited">canBeEdited() method</h3>

Returns true if message can be edited and false otherwise.

<h3 id="can-be-replied">canBeReplied() method</h3>

Returns true if message can be replied and false otherwise.

[Go to table of contents](#table-of-contents)

<h2 id="qoute">Quote protocol</h2>

Contains information about quote.

<h3 id ="get-quote-author-id">getAuthorID() method</h3>

Returns unique ID of message author of `String` type or `nil`.

<h3 id ="get-quote-message-attachment">getMessageAttachment() method</h3>

Returns message attachment of [`MessageAttachment`](#message-attachment) type or `nil`.

<h3 id ="get-quote-message-timestamp">getMessageTimestamp() method</h3>

Returns quote message timestamp of `Date` type or `nil`.

<h3 id ="get-quote-message-id">getMessageID() method</h3>

Returns quote message unique ID of `String` type or `nil`.

<h3 id ="get-quote-message-text">getMessageText() method</h3>

Returns quote message text of `String` type or `nil`.

<h3 id ="get-quote-message-type">getMessageType() method</h3>

Returns quote message type of [`MessageType`](#message-type) type or `nil`.

<h3 id ="get-quote-sender-name">getSenderName() method</h3>

Returns quote message sender name of `String` type or `nil`.

<h3 id ="get-quote-state>getState() method</h3>

Returns quote type of [`QuoteState`](#quote-State) type.

[Go to table of contents](#table-of-contents)

<h2 id ="quote-state">QuoteState enum</h2>

Quote state representation.

<h3 id ="quote-pending">pending case</h3>

Quote is loading.

<h3 id ="quote-filled">filled case</h3>

Quote loaded.

<h3 id ="quote-not-found">notFound case</h3>

Quote message is not found on server.

[Go to table of contents](#table-of-contents)

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

Returns `URL` of the file or `nil`.
Notice that this URL is short-living and is tied to a session.

[Go to table of contents](#table-of-contents)

<h2 id ="image-info">ImageInfo protocol</h2>

Provides information about an image.

<h3 id ="get-thumb-url-string">getThumbURL() method</h3>

Returns a URL of an image thumbnail.
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

[Go to table of contents](#table-of-contents)

<h2 id ="keyboard">Keyboard protocol</h2>

Provides information about a keyboard.

<h3 id ="get-buttons">getButtons() method</h3>

Returns an array of array of [buttons](#keyboard-button).

<h3 id ="get-state">getState() method</h3>

Returns keyboard state of type [KeyboardState](#keyboard-state)

<h3 id ="get-response">getResponse() method</h3>

Returns keyboard response of type [KeyboardResponse)(#keyboard-response) or `nil` if keyboard hasn't it.

[Go to table of contents](#table-of-contents)

<h2 id ="keyboard-response">KeyboardResponse protocol</h2>

Provides information about a keyboard response.

<h3 id ="get-button-id">getButtonID() method</h3>

Returns a selected button ID of `String` type. 

<h3 id ="keyboard-response-get-message-id">getMessageID() method</h3>

Returns resposne message ID of `String` type. 

[Go to table of contents](#table-of-contents)

<h2 id ="keyboard-button">KeyboardButton protocol</h2>

Provides information about a keyboard button.

<h3 id ="button-get-id">geID() method</h3>

Returns a button ID of `String` type. 

<h3 id ="button-get-text">getText() method</h3>

Returns a button text of `String` type. 

[Go to table of contents](#table-of-contents)

<h2 id ="keyboard-request">KeyboardRequest protocol</h2>

Provides information about a keyboard request.

<h3 id ="get-button">geButton() method</h3>

Returns a button from request of [KeyboardButton](#keyboard-button) type. 

<h3 id ="keyboard-request-get-message-id">getMessageID() method</h3>

Returns a request message ID of `String` type. 

[Go to table of contents](#table-of-contents)

<h2 id ="message-type">MessageType enum</h2>

Message type representation.

<h3 id ="action-request">actionRequest case</h3>

A message from operator which requests some actions from a visitor.
E.g. choose an operator group by clicking on a button in this message.

<h3 id ="contacts-request">contactInformationRequest case</h3>

Message type that is received after operator clicked contacts request button.
There's no this functionality automatic support yet. All payload is transfered inside standard text field.

<h3 id ="keyboard-type">keyboard case</h3>

A message sent by a script bot which contains buttons.

<h3 id ="keyboard-response-type">keyboardResponse case</h3>

Response to request with selected button.

<h3 id ="file-from-operator">fileFromOperator case</h3>

A message sent by an operator which contains an attachment.

<h3 id ="file-from-visitor">fileFromVisitor case</h3>

A message sent by a visitor which contains an attachment.

<h3 id ="info">info case</h3>

A system information message.
Messages of this type are automatically sent at specific events. E.g. when starting a chat, closing a chat or when an operator joins a chat.

<h3 id ="operator">operatorMessage case</h3>

A text message sent by an operator.

<h3 id ="operator-busy">operatorBusy case</h3>

A system information message which indicates that an operator is busy and can't reply to a visitor at the moment.

<h3 id ="visitor">visitorMessage case</h3>

A text message sent by a visitor.

[Go to table of contents](#table-of-contents)

<h2 id ="message-send-status">MessageSendStatus enum</h2>

Until a message is sent to the server, is received by the server and is spreaded among clients, message can be seen as "being send"; at the same time `Message.getSendStatus()` will return [sending](#sending). In other cases - [sent](#sent).

<h3 id ="sending">sending case</h3>

A message is being sent.

<h3 id ="sent">sent case</h3>

A message had been sent to the server, received by the server and was spreaded among clients.

[Go to table of contents](#table-of-contents)

<h2 id ="keyboard-state">KeyboardState enum</h2>

<h3 id ="pending">pending case</h3>

A keyboard has unselected buttons.

<h3 id ="completed">completed case</h3>

A keyboard has one selected button.

<h3 id ="completed">canceled case</h3>

A keyboard has unselected buttons but visitor can't selected someone.

[Go to table of contents](#table-of-contents)

<h2 id ="department">Department protocol</h2>

Single department entity. Provides methods to get department information.
Department objects can be received through [DepartmentListChangeListener protocol](#department-list-change-listener) methods and [getDepartmentList() method](#get-department-list) of [MessageStream protocol](#message-stream).

<h3 id ="get-key">getKey() method</h3>

Department key is used to start chat with some department. Presented by `String` object.
Used for [startChat(departmentKey:) method](#start-chat-department-key) of [MessageStream protocol](#message-stream) call.

<h3 id ="get-name-department">getName() method</h3>

Returns department public name. Presented by `String` object.

<h3 id ="get-department-online-status">getDepartmentOnlineStatus() method</h3>

Returns department online status. Presented by [DepartmentOnlineStatus](#department-online-status) object.

<h3 id ="get-order">getOrder() method</h3>

Returns order number.
Presented by `Int` value. Higher numbers match higher priority.

<h3 id ="get-localized-names">getLocalizedNames() method</h3>

Returns dictionary of department localized names (if exists).
Presented by `[String: String]` dictonary. Key is custom locale descriptor, value is matching name.

<h3 id ="get-logo">getLogo() method</h3>

Returns department logo _URL_ (if exists).
Presented by `URL` object.

[Go to table of contents](#table-of-contents)

<h2 id ="department-online-status">DepartmentOnlineStatus enum</h2>

Possible department online statuses.
Can be retreived by [getDepartmentOnlineStatus() method](#get-department-online-status) of [Department protocol](#department).

<h3 id ="busy-offline-department-online-status">busyOffline case</h3>

Offline state with chats' count limit exceeded.

<h3 id ="busy-online-department-online-status">busyOnline case</h3>

Online state with chats' count limit exceeded.

<h3 id ="offline-department-online-status">offline case</h3>

Visitor is able to send offline messages.

<h3 id ="online-department-online-status">online case</h3>

Visitor is able to send both online and offline messages.

<h3 id ="unknown-department-online-status">unknown case</h3>

Any status that is not supported by this version of the library.

[Go to table of contents](#table-of-contents)

<h2 id ="operator-protocol">Operator protocol</h2>

Presents chat operator object.

<h3 id ="get-id-operator">getID() method</h3>

Returns unique ID of the operator of `String` type.

<h3 id ="get-name">getName() method</h3>

Returns display name of the operator of `String` type.

<h3 id ="get-avatar-url">getAvatarURL() method</h3>

Returns `URL` of the operator’s avatar or `nil` if does not exist.

[Go to table of contents](#table-of-contents)

<h2 id ="webim-remote-notification">WebimRemoteNotification protocol</h2>

Abstracts a remote notifications from _Webim_ service.

<h3 id ="get-type-webim-remote-notification">getType() method</h3>

Returns type of this remote notification of [NotificationType](#notification-type) type.

<h3 id ="get-event">getEvent() method</h3>

Returns event of this remote notification of [NotificationEvent](#notification-event) type.

<h3 id ="get-parameters">getParameters() method</h3>

Returns parameters of this remote notification of array of `String` type.

<h3 id ="get-location">getLocation() method</h3>

Attention: this method can't be used as is. It requires that client server to support this mechanism!
Returns location of this remote notification of array of type `String` type.

<h3 id ="get-unread-by-visitor-messages-count">getUnreadByVisitorMessagesCount() method</h3>

Attention: this method can't be used as is. It requires that client server to support this mechanism!
Returns unread by visitor messages count of this remote notification of array of `Int` type.

[Go to table of contents](#table-of-contents)

<h2 id ="notification-type">NotificationType enum</h2>

Represents payload type of remote notification.

<h3 id ="contact-information-request">contactInformationRequest case</h3>

This notification type indicated that contact information request is sent to a visitor.

Parameters: empty.

<h3 id ="operator-accepted">operatorAccepted case</h3>

This notification type indicated that an operator has connected to a dialogue.

Parameters:
* Operator's name.

<h3 id ="operator-file">operatorFile case</h3>

This notification type indicated that an operator has sent a file.

Parameters:
* Operator's name;
* File name.

<h3 id ="operator-message">operatorMessage case</h3>

This notification type indicated that an operator has sent a text message.

Parameters:
* Operator's name;
* Message text.

<h3 id ="widget">widget case</h3>

This notification type indicated that an operator has sent a widget message.
This type can be received only if server supports this functionality.

Parameters: empty.

[Go to table of contents](#table-of-contents)

<h2 id ="notification-event">NotificationEvent enum</h2>

Represents meaned type of action when remote notification is received.

<h3 id ="add">add case</h3>

Means that a notification should be added by current remote notification.

<h3 id ="delete">delete case</h3>

Means that a notification should be deleted by current remote notification.

[Go to table of contents](#table-of-contents)

<h2 id ="fatal-error-handler">FatalErrorHandler protocol</h2>

Must be adopted to handle service errors that can occur.

<h3 id ="on-error">on(error:) method</h3>

This method is to be called when Webim service error is received.
Notice that method called NOT FROM THE MAIN THREAD!

`error` parameter is of [`WebimError` type](#webim-error).

[Go to table of contents](#table-of-contents)

<h2 id ="fatal-error-type">FatalErrorType enum</h2>

Webim service error types.
Mind that most of this errors causes session to destroy.

<h3 id ="account-blocked">accountBlocked case</h3>

Indicates that the account in Webim service has been disabled (e.g. for non-payment). The error is unrelated to the user’s actions.
Recommended response is to show the user an error message with a recommendation to try using the chat later.

Notice that the session will be destroyed if this error occured.

<h3 id ="no-chat">noChat case</h3>

Indicates that there was a try to perform action that requires existing chat, but there's no chat.
E.g. see [rateOperatorWith(id:byRating rating:) method](#rate-operator-with-id-by-rating-rating) or [rateOperatorWith(id:note:byRating rating:) method](#rate-operator-with-id-note-by-rating-rating)  of [MessageStream protocol](#message-stream).

<h3 id ="provided-visitor-fields-expired">providedVisitorFieldsExpired case</h3>

Indicates an expired authorization of a visitor.
The recommended response is to re-authorize it and to re-create session object.

Notice that the session will be destroyed if this error occured.

<h3 id ="unknown-fatal-error-type">unknown case</h3>

Indicates the occurrence of an unknown error.
Recommended response is to send an automatic bug report and show to a user an error message with the recommendation to try using the chat later.

Notice that the session will be destroyed if this error occured.

<h3 id ="visitor-banned">visitorBanned case</h3>

Indicates that a visitor was banned by an operator and can't send messages to a chat anymore.
Occurs when a user tries to open the chat or write a message after that.
Recommended response is to show the user an error message with the recommendation to try using the chat later or explain to the user that it was blocked for some reason.

Notice that the session will be destroyed if this error occured.

<h3 id ="wrong-provided-visitor-hash">wrongProvidedVisitorHash case</h3>

Indicates a problem of your application authorization mechanism and is unrelated to the user’s actions.
Occurs when trying to authorize a visitor with a non-valid signature.
Recommended response is to send an automatic bug report and show the user an error message with the recommendation to try using the chat later.

Notice that the session will be destroyed if this error occured.

[Go to table of contents](#table-of-contents)

<h2 id ="webim-error">WebimError protocol</h2>

Abstracts _Webim_ service possible fatal error.

<h3 id ="get-error-type">getErrorType() method</h3>

Returns parsed type of the error of [FatalErrorType](#fatal-error-type) type.

<h3 id ="get-error-string">getErrorString() method</h3>

Returns `String` representation of an error. Mostly useful if the error type is unknown.

[Go to table of contents](#table-of-contents)

<h2 id ="not-fatal-error-handler">NotFatalErrorHandler protocol</h2>

Must be adopted to handle service not fatal errors that can occur.

<h3 id ="on-not-fatal-error">on(error:) method</h3>

This method is to be called when Webim service error is received.
Notice that method called NOT FROM THE MAIN THREAD!

`error` parameter is of [`WebimNotFatalError` type](#webim-not-fatal-error).

[Go to table of contents](#table-of-contents)

<h2 id ="not-fatal-error-type">NotFatalErrorType enum</h2>

Webim service not fatal error types.

<h3 id ="no-network-connection">noNetworkConnection case</h3>

This error indicates no network connection.

<h3 id ="server-is-not-available">serverIsNotAvailable case</h3>

This error occurs when server is not available.

[Go to table of contents](#table-of-contents)

<h2 id ="webim-not-fatal-error">WebimNotFatalError protocol</h2>

Abstracts _Webim_ service possible not fatal error.

<h3 id ="get-not-fatal-error-type">getErrorType() method</h3>

Returns parsed type of the error of [NotFatalErrorType](#not-fatal-error-type) type.

<h3 id ="get-not-fatal-error-string">getErrorString() method</h3>

Returns `String` representation of an error.

[Go to table of contents](#table-of-contents)

<h2 id ="access-error">AccessError enum</h2>

Error types that can be throwed by [MessageStream](#message-stream) methods.

<h3 id ="invalid-thread">invalidThread case</h3>

Error that is thrown if the method was called not from the thread the [WebimSession](#webim-session) object was created in.

<h3 id ="invalid-session">invalidSession case</h3>

Error that is thrown if [WebimSession](#webim-session) object was destroyed.

[Go to table of contents](#table-of-contents)

<h2 id="webim-logger">WebimLogger protocol</h2>

Protocol that provides methods for implementing custom _WebimClientLibrary_ network requests logging.
It can be useful for debugging production releases if debug logs are not available.

<h3 id="log-entry">log(entry:) method</h3>

Method which is called after new _WebimClientLibrary_ network request log entry came out.
New log entry passed inside `entry` parameter.
