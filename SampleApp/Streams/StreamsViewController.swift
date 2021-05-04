//
//  StreamsViewController.swift
//  SampleApp
//
//  Created by Maelle Saiag on 06/12/2020.
//  Copyright © 2020 Apizee. All rights reserved.
//

import UIKit
import Eureka
import ApiRTCSDK

enum streamTypeButton {
    case front
    case back
    case audio
}

class StreamsViewController: ConversationViewController {
    
    var buttonSection: Section!
    var frontCameraStreamButtonRow: ButtonRow!
    var backCameraStreamButtonRow: ButtonRow!
    var audioStreamButtonRow: ButtonRow!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(close))

        ApiRTC.setCloudServerAvailabilityChecker(enabled: true)
        ApiRTC.setLogTypes([.info, .warning, .error, .debug, .cloud])
        ApiRTC.setMetaInfoLog(enabled: true)
        ApiRTC.setPresenceLogSuppressed(true)
        
        ua = UserAgent(UserAgentOptions(uri: .apzkey(Config.apiKey)))
        
        showActivityView()
        
        ua.register() { [weak self] (error, session) in
            guard let `self` = self else {
                return
            }
            
            if let error = error {
                self.hideActivityView()
                showError(error)
                return
            }
            
            guard let session = session else {
                self.hideActivityView()
                showError("Session is nil")
                return
            }
                        
            self.session = session
            
            DispatchQueue.main.async {
                self.hideActivityView()
                self.initUI()
            }
        }
    }
    
    override func createForm() {
        
        buttonSection = Section()
        
        frontCameraStreamButtonRow = ButtonRow() {
            $0.title = "Front camera stream"
        }
        .onCellSelection { cell, row in
            self.createStream(type: .front)
        }
        
        backCameraStreamButtonRow = ButtonRow() {
            $0.title = "Back camera stream"
        }
        .onCellSelection { cell, row in
            self.createStream(type: .back)
        }
        
        audioStreamButtonRow = ButtonRow() {
            $0.title = "Audio stream"
        }
        .onCellSelection { cell, row in
            self.createStream(type: .audio)
        }
        
        form
            +++ Section()
            <<< localIdRow
            +++ joinConversationSection
            <<< joinConversationTextRow
            <<< joinConversationButtonRow
            +++ conversationIdSection
            <<< conversationIdRow
            +++ buttonSection
            <<< frontCameraStreamButtonRow
            <<< backCameraStreamButtonRow
            <<< audioStreamButtonRow
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
        })
    }
    
    override func handleState(_ state: ConversationViewControllerState) {
        switch state {
        case .initial:
            joinConversationSection.show()
            conversationIdSection.hide()
            buttonSection.hide()
            streamsSection.hide()
        case .joined:
            joinConversationSection.hide()
            conversationIdSection.show()
            buttonSection.show()
            streamsSection.show()
        }
    }
        
    func createStream(type: streamTypeButton) {

        guard let conversation = conversation else {
            showError("Can't publish, conversation is nil")
            return
        }
        
        var stream: ApiRTCStream!

        switch type {
        case .front:
            do {
                stream = try ApiRTCStream.createCameraStream(position: .front)
            }
            catch {
                showError(error)
                return
            }
        case .back:
            do {
                stream = try ApiRTCStream.createCameraStream(position: .back)
            }
            catch {
                showError(error)
                return
            }
        case .audio:
            stream = ApiRTCStream.createAudioStream()
        }
        
        conversation.publish(stream: stream) { (error, stream) in
            if let error = error {
                showError(error)
                return
            }
        }
    }
}
