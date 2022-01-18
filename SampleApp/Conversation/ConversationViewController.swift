//
//  ConversationViewController.swift
//  SampleApp
//
//  Created by Maelle Saiag on 06/11/2020.
//  Copyright © 2020 Apizee. All rights reserved.
//

import UIKit
import Eureka
import ApiRTCSDK

enum ConversationViewControllerState {
    case initial
    case joined
}

class ConversationViewController: FormViewController {
    
    var ua: UserAgent!
    
    var session: Session?
    
    var conversation: Conversation?
        
    var localIdRow: LabelRow!
    
    var joinConversationSection: Section!
    var joinConversationTextRow: TextRow!
    var joinConversationButtonRow: ButtonRow!
    
    var conversationIdSection: Section!
    var conversationIdRow: LabelRow!
        
    var streamsSection: Section!
    
    var state: ConversationViewControllerState = .initial {
        didSet {
            DispatchQueue.main.async {
                self.handleState(self.state)
            }
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(close))

        ApiRTC.setLogTypes(.info, .warning, .error, .debug, .cloud, .socket)
        
        ua = UserAgent(UserAgentOptions(uri: .apikey(Config.apiKey)))
        
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
    
    func initUI() {
        
        form = Form()
        
        localIdRow = LabelRow() {
            $0.title = "Your ID"
            $0.value = self.session?.id
        }
        
        joinConversationSection = Section()
        joinConversationTextRow = TextRow() {
            $0.title = "Conference ID"
        }
        joinConversationButtonRow = ButtonRow() {
            $0.title = "Join"
        }
        .onCellSelection { cell, row in
            self.join()
        }
        
        conversationIdSection = Section()
        conversationIdRow = LabelRow() {
            $0.title = "Conversation ID"
        }
        
        streamsSection = Section()
                
        state = .initial
        
        createForm()
    }
    
    func createForm() {
        form
            +++ Section()
            <<< localIdRow
            +++ joinConversationSection
            <<< joinConversationTextRow
            <<< joinConversationButtonRow
            +++ conversationIdSection
            <<< conversationIdRow

            +++ streamsSection
    }
    
    @objc func close() {
        
        showActivityView()
        
        ua.unregister { (error) in
            if let error = error {
                showError(error)
                return
            }
            DispatchQueue.main.async {
                self.hideActivityView()
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func handleState(_ state: ConversationViewControllerState) {
        switch state {
        case .initial:
            joinConversationSection.show()
            conversationIdSection.hide()
            streamsSection.hide()
        case .joined:
            joinConversationSection.hide()
            conversationIdSection.show()
            streamsSection.show()
        }
    }
        
    func join() {
        
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
            self.publish()
        })
    }
    
    func attachEventsToCurrentConversation() {
        
        conversation?.onEvent(self, { (event) in
            switch event {
            case .joined:
                showMessage("Joined")
                self.state = .joined
            case .left:
                showMessage("Left")
                self.state = .initial
            case .streamListChanged(let type, let info):
                self.handleStreamListUpdate(type, info)
            case .streamAdded(let stream):
                self.handleNewStream(stream)
            case .streamRemoved(let stream):
                self.handleStreamRemoving(stream.id)
            default:
                break
            }
        })
    }
    
    func publish() {
        
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
    
    func handleStreamListUpdate(_ type: StreamInfoType, _ info: StreamInfo) {
     
        switch type {
        case .added:
            if info.isRemote {
                self.subscribeToStreamWithId(info.streamId)
            }
        case .removed:
            handleStreamRemoving(info.streamId)
        default:
            break
        }
    }
    
    func subscribeToStreamWithId(_ streamId: String) {
        
        guard let conversation = conversation else {
            showError("Can't subscribe, conversation is nil")
            return
        }

        conversation.subscribeToStream(streamId: streamId)
    }
    
    func handleNewStream(_ stream: ApiRTCStream) {
        
        func handle() {
            switch stream.direction {
            case .outgoing:
                let newLocalStreamRow = LocalStreamRow()
                newLocalStreamRow.tag = stream.id
                streamsSection.append(newLocalStreamRow)
                newLocalStreamRow.cell.addStream(stream)
            case .incoming:
                let remoteStreamRow = RemoteStreamRow()
                remoteStreamRow.tag = stream.id
                streamsSection.append(remoteStreamRow)
                remoteStreamRow.cell.addStream(stream)
            default:
                break
            }
        }

        DispatchQueue.main.async {
            handle()
        }
    }
    
    func handleStreamRemoving(_ streamId: String) {
        
        func handle() {
            if let rowNum = form.rowBy(tag: streamId)?.indexPath?.row {
                streamsSection.remove(at: rowNum)
            }
        }

        DispatchQueue.main.async {
            handle()
        }
    }
    
}
