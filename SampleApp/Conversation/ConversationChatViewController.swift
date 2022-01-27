//
//  ConversationChatViewController.swift
//  SampleApp
//
//  Created by Maelle Saiag on 03/12/2020.
//  Copyright © 2020 Apizee. All rights reserved.
//

import Eureka
import ApiRTCSDK

// Web chat and push sample: https://apizee.github.io/ApiRTC-examples/conferencing_chat_file_transfer/index.html

class ConversationChatViewController: FormViewController {
            
    var ua: UserAgent!
    
    var session: Session?
    
    var conversation: Conversation?
        
    var localIdRow: LabelRow!
    
    var joinConversationSection: Section!
    var joinConversationTextRow: TextRow!
    var joinConversationButtonRow: ButtonRow!
    
    var conversationIdSection: Section!
    var conversationIdRow: LabelRow!
        
    var messageChatSection: Section!
    var messageChatTextRow: TextRow!
    
    var pushDataSection: Section!
    
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
        
        //
        
        messageChatSection = Section("Message")
        messageChatTextRow = TextRow() {
            $0.title = "Message"
        }
        
        let messageSendButtonRow = ButtonRow() {
            $0.title = "Send"
        }
        .onCellSelection { cell, row in
            self.send()
            self.messageChatTextRow.resetRowValue()
            self.messageChatTextRow.updateCell()
        }
        
        //
        
        pushDataSection = Section("Push data")

        let pushDataButtonRow = ButtonRow() {
            $0.title = "Push"
        }
        .onCellSelection { cell, row in
            self.push()
        }
                        
        state = .initial
        
        form
            +++ Section()
            <<< localIdRow
            +++ joinConversationSection
            <<< joinConversationTextRow
            <<< joinConversationButtonRow
            +++ conversationIdSection
            <<< conversationIdRow
            +++ messageChatSection
            <<< messageChatTextRow
            <<< messageSendButtonRow
            +++ pushDataSection
            <<< pushDataButtonRow
    }
        
    @objc func close() {
        
        showActivityView()
        
        func unregister() {
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
        
        if let conversation = conversation {
            conversation.leave {
                unregister()
            }
        }
        else {
            unregister()
        }
    }
    
    func handleState(_ state: ConversationViewControllerState) {
        switch state {
        case .initial:
            joinConversationSection.show()
            conversationIdSection.hide()
            messageChatSection.hide()
            pushDataSection.hide()
        case .joined:
            joinConversationSection.hide()
            conversationIdSection.show()
            messageChatSection.show()
            pushDataSection.show()
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
            case .receiveChatMessage(let message):
                showMessage(message.text)
            default:
                break
            }
        })
    }
        
    //
    
    func send() {
        
        guard let message = messageChatTextRow.value else {
            showError("Message is nil")
            return
        }
        
        conversation?.sendMessage(message: message) { error, message in
            if let error = error {
                showError(error)
                return
            }
        }
    }
    
    func push() {
        
        let image = UIImage(named: "earth")
        
        guard let data = image?.jpegData(compressionQuality: 1) else {
            showError("Data nil")
            return
        }
        
        let descriptor = try! PushBufferDataDescriptor(data: data, filename: "earth.png", type: "png")
        conversation?.pushData(descriptor: descriptor, completion: { [weak self] error, info in
            guard let `self` = self else { return }
            
            if let error = error {
                showError(error)
                return
            }
            
            guard let url = info?.url else {
                showError("Url nil")
                return
            }
            
            self.conversation?.sendMessage(message: "New image uploaded: " + url, completion: { error, message in
                if let error = error {
                    showError(error)
                    return
                }
            })
        })
    }
}
