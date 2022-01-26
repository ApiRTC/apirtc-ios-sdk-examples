#  ApiRTC iOS Tutorials

Samples for [ApiRTC iOS SDK](https://github.com/apizee/ApiRTC-iOS-SDK).

## Web samples

These samples can be tested with our [web tutorials](https://dev.apirtc.com/tutorials).

## Requirements

iOS 14+

## Installation

```
pod update
```

## Usage

### Register UserAgent

**UserAgent** is the starting point of apiRTC and enables you to manage several important aspects such as :
- User registration
- Media devices management
- Offline features ...

You can register with external user managment or integrate user managment.

### User Agent registration with external users management

In this case, UserAgent is created using apiKey :
```
var ua = UserAgent(UserAgentOptions(uri: .apzkey("[put api key here]")))
```

In order to start communicating with other users, User Agent has to register to the Apizee platform. ApiKey is used to isolate your project so you will be able to communicate with users that are registered with the same apiKey.
RegisterInformation is optional, if id is not specify, a default id is generated. 
```
ua.register(RegisterInformation(id: [Your user id])) { (error, session) in
    if let error = error {
        showError(error)
        return
    }
    guard let session = session else {
        showError("Session is nil")
        return
    }
    self.session = session
}
```

### User Agent registration with Apizee users management

In this case, User Agent is created using an account that exist on apizee cloud.
```
var ua = UserAgent(UserAgentOptions(uri: .apizee("[put your login here]")))
```

In order to start communicating with other users, User Agent has to register to the Apizee platform. Password has to be set in order to allow authentication and user connection.
```
ua.register(registerInformation: RegisterInformation(password: "[put your password here]")) { (error, session) in
    if let error = error {
        showError(error)
        return
    }
    guard let session = session else {
        showError("Session is nil")
        return
    }
    self.session = session
}
```


## Conversation

### Create, join or leave conversation

Create the conversation
```
do {
    conversation = try session.getOrCreateConversation(name: conversationId)
}
catch {
    showError(error)
    return
}
```

Leave the conversation
```
conversation.leave {
    self.conversation = nil
}
```

Join the conversation
```
conversation?.join(completion: { (error, accessAllowed) in
    if let error = error {
        showError(error)
        return
    }
    switch accessAllowed {
    case true:
        showMessage("Access allowed")
    case false:
        showMessage("Access denied")
    }
})
```

Publish your stream to the conversation
See Stream management to create the stream.
```
conversation.publish(stream: stream) { (error, stream) in
    if let error = error {
        showError(error)
        return
    }
}
```

### Events
Add event listeners on conversation
```
conversation?.onEvent(self, { (event) in
    switch event {
    case .joined:
        showMessage("Joined")
    case .left:
        showMessage("Left")
    case .streamListChanged(let streamList):
        self.handleStreamList(streamList)
    case .streamAdded(let stream):
        self.handleNewStream(stream)
    case .streamRemoved(let stream):
        self.handleStreamRemoving(stream)
    case .waitingForModeratorAcceptance:
        self.handleWaitingAcceptation()
    case .newWhiteboardClient:
        self.whiteboardState = .online
    case .whiteboardClosed:
        self.whiteboardState = .offline
    default:
        break
    }
})
```

Listen for any participants entering or leaving the conversation.
You can use conversation.getContacts() to get every participant in conversation.
conversation.
```
conversation.onEvent(self, { (event) in
    switch event {
    case .contactJoined(let contact):
       showMessage("Contact that has joined: " + contact.id)
    case .contactLeft(let contact):
        showMessage("Contact that has left: " + contact.id)
    default:
        break
    }
})
```

### Media

Switch camera
Use call.replacePublishedStream(streamId:withStream:completion:) function update the published stream. See Stream management to create the new stream.
```
call.replacePublishedStream(streamId: stream.id, withStream: newStream) { (error, stream) in
    if let error = error {
        showError(error)
        return
    }
}
```

Media muting
Muting / unmuting your local stream can easily be done using muteAudio(), unmuteAudio(), muteVideo(), unmuteVideo() of Stream functions.
```
localStream.muteAudio()

localStream.unmuteAudio()

localStream.muteVideo()

localStream.unmuteVideo()
```

### Chat

> **_NOTE:_**  Note that chat sample show errors but is functional. SDK will be update to fix errors.

Send a message to the conversation
Once you have joined a conversation, you will be able to send a message to everyone in it:
```
conversation.sendMessage(message: message) { (error) in
    if let error = error {
        showError(error)
        return
    }
 }
```

Add listener on 'receiveGroupChatMessage'
```
conversation.onEvent(self, { (event) in
    switch event {
    case .receiveGroupChatMessage(let message):
       showMessage(message.contact.id + ": " + message.content)
    default:
        break
    }
})
```

### Whiteboard
Start a whiteboard on a conversation.
```
conversation.startWhiteboardSession { (error, client) in
    if let error = error {
        showError(error)
        return
    }
    // Getting whiteboardClient in order to be able to set UI parameters
    guard let whiteboardClient = ua.getWhiteboardClient() else {
        showError("No whiteboard client")
        return
    }
}
```

### Publish and subscribe
When you publish your stream, you can use the publishOptions parameters to select media type you want to publish. Set mediaRestriction to audioOnly or videoOnly depending of your needs.
```
conversation.publish(stream: stream, options: PublishOptions(mediaRestriction: .videoOnly), completion: { (error, stream) in
    if let error = error {
        showError(error)
        return
    }
})
```
When you subscribe to streams, you can use the subscribeOptions parameters to select media type you want to subscribe. Set mediaRestriction to audioOnly or videoOnly depending of your needs.
```
conversation.subscribeToStream(streamId: streamId, options: SubscribeOptions(mediaRestriction: .audioOnly))
```


## One-to-one

Here is a description of the different steps to create a peer to peer call using apiRTC iOS SDK.

### Call

Add listener on 'incomingCall' to receive audio/video calls.
```
session.onEvent(self, { (event) in
    switch event {
    case .incomingCall(let invitation):
        invitation.accept(completion: { (error, call) in
            if let error = error {
                showError(error)
                return
            }
            guard let call = call else {
                showError("Call is nil")
                return
            }
            self.activeCall = call
        })
        incomingInvitation = invitation
    default:
        break
    }
})
```

Etablish a call
```
session.getContact(id: contactId).call { (error, call) in
    if let error = error {
        showError(error)
        return
    }
    guard let call = call else {
        showError("Call is nil")
        return
    }
}
```

Add events listeners on Call to be informed of related events.
```
call.onEvent(self) { [weak self] (event) in
    guard let `self` = self else {
        return
    }
    switch event {
    case .accepted:
        self.handleCallAccept()
    case .declined:
        self.handleCallDecline()
    case .hangup:
        self.handleRemoteHangUp()
    case .localStreamAvailable(let localStream):
        self.handleNewLocalStream(localStream)
    case .streamAdded(let remoteStream):
        self.handleNewRemoteStream(remoteStream)
    case .error(let error):
        showError(error)
    default:
        break
    }
}
```

Add possibility to hangup the call
```
activeCall?.hangUp(completion: { [weak self] in
    self?.activeCall = nil
})
```

### Invitation
Add listeners on invitation to handle the case when user accept or decline invitation.
```
invitation.onEvent(self) { [weak self] (event) in
    guard let `self` = self else {
        return
    }
    switch event {
    case .statusChanged(let status):
        switch status {
        case .cancelled:
            self.handleInvitationCancellation()
        case .accepted:
            self.handleInvitationAccepted()
        case .declined:
            self.handleInvitationDeclined()
        default:
            break
        }
    default:
        break
    }
}
```

### Audio or video muted
With CallOptions you can choice the type of call and mute audio or video.
```
session.getContact(id: targetId).call(options: CallOptions(streamTypeForOutgoingCall: .audio, isAudioMuted: false, isVideoMuted: true)) { (error, call) in
    if let error = error {
        self.state = .def
        showError(error)
        return
    }
    guard let call = call else {
        self.state = .def
        showError("Call is nil")
        return
    }
}
```
For answers you can also choice with AnswerOptions.
```
invitation?.accept(streamTypeForOutgoingCall: .video, isAudioMuted: true, isVideoMuted: false), completion: { (error, call) in
    if let error = error {
        showError(error)
        return
    }
    guard let call = call else {
        showError("Call is nil")
        return
    }
})
```

### Chat

> **_NOTE:_**  Note that chat sample show errors but is functional. SDK will be update to fix errors.

Send a message to a contact
```
contact.sendMessage(message: message) { (error) in
    if let error = error {
        showError(error)
        return
    }
}
```

Listen for contact's messages
```
session.onEvent(self, { (event) in
    switch event {
    case .receiveContactMessage(let message):
        showMessage(message.contact.id + ": " + message.content)
    case .error(let error):
        showError(error)
    default:
        break
    }
})
```

## Streams management

Create streams
Streams can be created from a camera, audio or external camera
From a camera on the device :
```
var stream: ApiRTCStream!
do {
    stream = try ApiRTCStream.createCameraStream(position: .back)
}
catch {
    showError(error)
    return
}
```

From audio only
```
var stream = ApiRTCStream.createAudioStream()
```

From external camera
```
var stream = ApiRTCStream.createExternalCameraStream()
```
