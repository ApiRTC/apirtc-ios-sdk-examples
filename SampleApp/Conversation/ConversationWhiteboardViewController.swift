//
//  ConversationWhiteboardViewController.swift
//  SampleApp
//
//  Created by Aleksandr Khorobrykh on 26/01/2022.
//  Copyright © 2022 Apizee. All rights reserved.
//

import Eureka
import ApiRTCSDK

// Web sample: https://apizee.github.io/ApiRTC-examples/conferencing_whiteboard/index.html

class ConversationWhiteboardViewController: FormViewController {
            
    var ua: UserAgent!
    
    var session: Session?
    
    var conversation: Conversation?
        
    var localIdRow: LabelRow!
    
    var joinConversationSection: Section!
    var joinConversationTextRow: TextRow!
    var joinConversationButtonRow: ButtonRow!
    
    var conversationIdSection: Section!
    var conversationIdRow: LabelRow!
        
    var whiteboardSection: Section!
    
    var whiteboardClient: WhiteboardClient?
    
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
        
        whiteboardSection = Section("Whiteboard")
        
        let whiteboardButtonRow = ButtonRow() {
            $0.title = "Start whiteboard"
        }
        .onCellSelection { cell, row in
            self.startWhiteboard()
        }

        //
                        
        state = .initial
        
        form
            +++ Section()
            <<< localIdRow
            +++ joinConversationSection
            <<< joinConversationTextRow
            <<< joinConversationButtonRow
            +++ conversationIdSection
            <<< conversationIdRow
            +++ whiteboardSection
            <<< whiteboardButtonRow
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
            whiteboardSection.hide()
        case .joined:
            joinConversationSection.hide()
            conversationIdSection.show()
            whiteboardSection.show()
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
            case .newWhiteboardSession(let client):
                self.whiteboardClient = client
                self.startWhiteboard()
            default:
                break
            }
        })
    }
        
    //
    
    func startWhiteboard() {
        
        func openWhiteboard(_ client: WhiteboardClient) {
            DispatchQueue.main.async {
                let vc = WhiteboardViewController(client)
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            }
        }
        
        if let client = whiteboardClient {
            openWhiteboard(client)
        }
        else {
            conversation?.startWhiteboardSession(completion: { error, client in
                
                if let error = error {
                    showError(error)
                    return
                }
                
                guard let client = client else {
                    showError("Client nil")
                    return
                }
                
                self.whiteboardClient = client
                openWhiteboard(client)
            })
        }
    }
}
