//
//  ConversationAdvancedPublishSubscribeViewController.swift
//  SampleApp
//
//  Created by Maelle Saiag on 03/12/2020.
//  Copyright © 2020 Apizee. All rights reserved.
//

import Eureka
import ApiRTCSDK

class ConversationAdvancedPublishSubscribeViewController: ConversationViewController {
    
    var publishSection: Section!
    
    var streamListSection: Section!
    
    override func createForm() {
        
        streamListSection = Section()

        form
            +++ Section()
            <<< localIdRow
            +++ joinConversationSection
            <<< joinConversationTextRow
            <<< joinConversationButtonRow
            +++ conversationIdSection
            <<< conversationIdRow
            +++ publishSection
            
            +++ streamListSection

            +++ streamsSection
    }
    
    override func join() {

        guard let conversationId = joinConversationTextRow.value else {
            showError("Conversation id is nil")
            return
        }

        guard let session = session else {
            showError("Session is nil")
            return
        }

        do {
            conversation = try session.getOrCreateConversation(name: conversationId)
        }
        catch {
            showError(error)
            return
        }

        attachEventsToCurrentConversation()

        conversation?.join(completion: { (error, accessAllowed) in

            if let error = error {
                showError(error)
                return
            }

            switch accessAllowed {
            case true:
                showMessage("Access allowed")
            case false:
                self.state = .initial
                showMessage("Access denied")
            }
            self.conversationIdRow.value = conversationId
            self.state = .joined
            
            self.addPublishRow()
        })
    }
    
    func addPublishRow() {
        
        func handle() {
            if let rowNum = form.rowBy(tag: "unpublish")?.indexPath?.row {
                publishSection.remove(at: rowNum)
            }
            
            let publishButtonRow = ButtonRow() {
                $0.title = "Publish"
                $0.tag = "publish"
            }
            .onCellSelection { cell, row in
                self.publish()
            }
            publishSection.append(publishButtonRow)
        
            let publishAudioButtonRow = ButtonRow() {
                $0.title = "Publish audio only"
                $0.tag = "publishAudio"
            }
            .onCellSelection { cell, row in
                self.publish(mediaRestriction: .audioOnly)
            }
            publishSection.append(publishAudioButtonRow)
        
            let publishVideoButtonRow = ButtonRow() {
                $0.title = "Publish video only"
                $0.tag = "publishVideo"
            }
            .onCellSelection { cell, row in
                self.publish(mediaRestriction: .videoOnly)
            }
            publishSection.append(publishVideoButtonRow)
        }
        
        DispatchQueue.main.async {
            handle()
        }
    }

    func publish(mediaRestriction: StreamMediaRestriction) {

        guard let conversation = conversation else {
            showError("Can't publish, conversation is nil")
            return
        }

        var stream: ApiRTCStream!

        do {
            stream = try ApiRTCStream.createCameraStream(position: .front)
        }
        catch {
            showError(error)
            return
        }

        conversation.publish(stream: stream) { (error, stream) in
            if let error = error {
                showError(error)
                return
            }
        }
    }

    override func handleStreamListUpdate(_ type: StreamInfoType, _ info: StreamInfo) {

        func handle () {
            switch type {
            case .added:
                if info.isRemote {
                    let buttonRow = ButtonRow() {
                        $0.title = "Subscribe to stream " + info.streamId
                        $0.tag = "streamlist" + info.streamId
                    }
                    .onCellSelection { cell, row in
                        self.subscribeToStreamWithId(info.streamId)
                    }
                    streamListSection.append(buttonRow)
                    
//                    if info.isVideo && info.hasVideo {
//
//                    }
            
                    //????
//                    if info.hasAuido {
//                        let audioButtonRow = ButtonRow() {
//                            $0.title = "Subscribe to audio stream " + info.streamId
//                            $0.tag = "streamlistaudio" + info.streamId
//                        }
//                        .onCellSelection { cell, row in
//                            self.subscribeToStreamWithId(info.streamId, mediaRestriction: .audioOnly)
//                        }
//                        streamListSection.append(audioButtonRow)
//                    }
//
//                    if info.hasVideo {
//                        let videoButtonRow = ButtonRow() {
//                            $0.title = "Subscribe to video stream " + info.streamId
//                            $0.tag = "streamlistvideo" + info.streamId
//                        }
//                        .onCellSelection { cell, row in
//                            self.subscribeToStreamWithId(info.streamId, mediaRestriction: .videoOnly)
//                        }
//                        streamListSection.append(videoButtonRow)
//                    }
                }
            case .removed:
                if let rowNum = form.rowBy(tag: "streamlist" + info.streamId)?.indexPath?.row {
                    streamListSection.remove(at: rowNum)
                }
                if let rowNum = form.rowBy(tag: "streamlistaudio" + info.streamId)?.indexPath?.row {
                    streamListSection.remove(at: rowNum)
                }
                if let rowNum = form.rowBy(tag: "streamlistvideo" +     info.streamId)?.indexPath?.row {
                    streamListSection.remove(at: rowNum)
                }
                if let rowNum = form.rowBy(tag: "unbscribe" + info.streamId)?.indexPath?.row {
                    streamListSection.remove(at: rowNum)
                }
            default:
                break
            }
        }
        
        DispatchQueue.main.async {
            handle()
        }
    }

    func subscribeToStreamWithId(_ streamId: String, mediaRestriction: StreamMediaRestriction) {

        guard let conversation = conversation else {
            showError("Can't subscribe, conversation is nil")
            return
        }
        
        conversation.subscribeToStream(streamId: streamId)
    }

    override func handleNewStream(_ stream: ApiRTCStream) {

        func handle() {
            super.handleNewStream(stream)
            
            switch stream.direction {
            case .outgoing:
                if let rowNum = form.rowBy(tag: "publish")?.indexPath?.row {
                    publishSection.remove(at: rowNum)
                }
                if let rowNum = form.rowBy(tag: "publishAudio")?.indexPath?.row {
                    publishSection.remove(at: rowNum)
                }
                if let rowNum = form.rowBy(tag: "publishVideo")?.indexPath?.row {
                    publishSection.remove(at: rowNum)
                }
                let unpublishButtonRow = ButtonRow() {
                    $0.title = "Unpublish"
                    $0.tag = "unpublish"
                }
                .onCellSelection { cell, row in
                    self.unpublishStreamWithId(stream.id)
                }
                publishSection.append(unpublishButtonRow)
            case .incoming:
                if let rowNum = form.rowBy(tag: "streamlist" + stream.id)?.indexPath?.row {
                    streamListSection.remove(at: rowNum)
                }
                if let rowNum = form.rowBy(tag: "streamlistaudio" + stream.id)?.indexPath?.row {
                    streamListSection.remove(at: rowNum)
                }
                if let rowNum = form.rowBy(tag: "streamlistvideo" +     stream.id)?.indexPath?.row {
                    streamListSection.remove(at: rowNum)
                }
                let unsubscribeButtonRow = ButtonRow() {
                        $0.title = "Unsubscribe to stream" + stream.id
                        $0.tag = "unsubscribe" + stream.id
                    }
                    .onCellSelection { cell, row in
                        self.unsubscribeFromStreamWithId(stream.id)
                    }
                streamListSection.append(unsubscribeButtonRow)
            default:
                break
            }
        }

        DispatchQueue.main.async {
            handle()
        }
    }
    
    func unpublishStreamWithId(_ streamId: String) {
        
        guard let conversation = conversation else {
            showError("Can't unpublish, conversation is nil")
            return
        }
        
        conversation.unpublishStreamWithId(streamId, completion: {
            self.addPublishRow()
        })
    }
    
    func unsubscribeFromStreamWithId(_ streamId: String) {
        
        guard let conversation = conversation else {
            showError("Can't unsubscribe, conversation is nil")
            return
        }
        
        conversation.unsubscribeFromStreamWithId(streamId)
        
        if let rowNum = form.rowBy(tag: "unsubscribe" + streamId)?.indexPath?.row {
            streamListSection.remove(at: rowNum)
        }
    }
}

