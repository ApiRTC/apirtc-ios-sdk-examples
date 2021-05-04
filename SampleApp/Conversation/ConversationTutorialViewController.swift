////
////  ConversationViewController.swift
////  SampleApp
////
////  Created by Maelle Saiag on 06/11/2020.
////  Copyright © 2020 Apizee. All rights reserved.
////
//
//import UIKit
//import Eureka
//import ApiRTCSDK
//
//enum ConversationViewControllerState {
//    case initial
//    case joined
//}
//
//class ConversationViewController: FormViewController {
//    
//    var ua: UserAgent!
//    
//    var session: Session?
//    
//    var conversation: Conversation?
//        
//    var localIdRow: LabelRow!
//    
//    var joinConversationSection: Section!
//    var joinConversationTextRow: TextRow!
//    var joinConversationButtonRow: ButtonRow!
//        
//    var leaveConversationSection: Section!
//    var leaveConversationButtonRow: ButtonRow!
//                
//    var streamsSection: Section!
//    
//    var streamListSection: Section!
//    var streamList: [String] = []
//    
//    var state: ConversationViewControllerState = .initial {
//        didSet {
//            DispatchQueue.main.async {
//                self.handleState(self.state)
//            }
//        }
//    }
//        
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        if #available(iOS 13.0, *) {
//            overrideUserInterfaceStyle = .light
//        }
//        
//        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(close))
//
//        ApiRTC.setCloudServerAvailabilityChecker(enabled: true)
//        ApiRTC.setLogTypes([.info, .warning, .error, .debug, .socket, .cloud])
//        ApiRTC.setMetaInfoLog(enabled: true)
//        ApiRTC.setPresenceLogSuppressed(true)
//        
//        ua = UserAgent(UserAgentOptions(uri: .apzkey(Config.apiKey)))
//        
//        showActivityView()
//        
//        ua.register(registerInformation: RegisterInformation(password: "Apizee22")) { [weak self] (error, session) in
//            guard let `self` = self else {
//                return
//            }
//            
//            if let error = error {
//                self.hideActivityView()
//                showError(error)
//                return
//            }
//            
//            guard let session = session else {
//                self.hideActivityView()
//                showError("Session is nil")
//                return
//            }
//                        
//            self.session = session
//            
//            DispatchQueue.main.async {
//                self.hideActivityView()
//                self.initUI()
//            }
//        }
//    }
//    
//    func initUI() {
//        
//        form = Form()
//        
//        localIdRow = LabelRow() {
//            $0.title = "Your ID"
//            $0.value = self.session?.id
//        }
//        
//        joinConversationSection = Section("Join")
//        joinConversationTextRow = TextRow() {
//            $0.title = "Conference ID"
//        }
//        joinConversationButtonRow = ButtonRow() {
//                $0.title = "Join"
//            }
//            .onCellSelection { cell, row in
//                self.join()
//            }
//                
//        leaveConversationSection = Section()
//        leaveConversationButtonRow = ButtonRow() {
//                $0.title = "Leave"
//            }
//            .onCellSelection { cell, row in
//                self.leave()
//            }
//        
////        streamListSection = Section()
//        
//        streamsSection = Section()
//                
//        form
//            +++ Section()
//            <<< localIdRow
//            +++ joinConversationSection
//            <<< joinConversationTextRow
//            <<< joinConversationButtonRow
//            +++ leaveConversationSection
//            <<< leaveConversationButtonRow
//            
////            +++ streamListSection
//
//            +++ streamsSection
//                
//        state = .initial
//    }
//    
//    @objc func close() {
//        
//        showActivityView()
//        
//        ua.unregister { (error) in
//            if let error = error {
//                showError(error)
//                return
//            }
//            DispatchQueue.main.async {
//                self.hideActivityView()
//                self.navigationController?.popViewController(animated: true)
//            }
//        }
//    }
//    
//    func handleState(_ state: ConversationViewControllerState) {
//        switch state {
//        case .initial:
//            joinConversationSection.show()
//            leaveConversationSection.hide()
//            streamsSection.hide()
//        case .joined:
//            joinConversationSection.hide()
//            leaveConversationSection.show()
//            streamsSection.show()
//        }
//    }
//        
//    func join() {
//        
//        guard let conversationId = joinConversationTextRow.value else {
//            showError("Conversation id is nil")
//            return
//        }
//        
//        guard let session = session else {
//            showError("Session is nil")
//            return
//        }
//        
//        do {
//            conversation = try session.getOrCreateConversation(name: conversationId)
//        }
//        catch {
//            showError(error)
//            return
//        }
//
//        attachEventsToCurrentConversation()
//   
//        conversation?.join(completion: { (error, accessAllowed) in
//            
//            if let error = error {
//                showError(error)
//                return
//            }
//            
//            switch accessAllowed {
//            case true:
//                showMessage("Access allowed")
//            case false:
//                self.state = .initial
//                showMessage("Access denied")
//            }
//            self.publish()
//        })
//    }
//    
//    func attachEventsToCurrentConversation() {
//        
//        conversation?.onEvent(self, { (event) in
//            switch event {
//            case .joined:
//                showMessage("Joined")
//                self.state = .joined
//            case .left:
//                showMessage("Left")
//                self.state = .initial
//            case .streamListChanged(let type, let info):
//                self.handleStreamListUpdate(type, info)
//            case .streamAdded(let stream):
//                self.handleNewStream(stream)
//            case .streamRemoved(let stream):
//                self.handleStreamRemoving(stream.id)
//            default:
//                break
//            }
//        })
//    }
//    
//    func leave() {
//        
//        guard let conversation = conversation else {
//            showError("Can't leave, conversation is nil")
//            return
//        }
//        
//        conversation.leave {
//            self.conversation = nil
//            self.state = .initial
//        }
//    }
//    
//    func publish() {
//        
//        guard let conversation = conversation else {
//            showError("Can't publish, conversation is nil")
//            return
//        }
//
//        var stream: ApiRTCStream!
//
//        do {
//            stream = try ApiRTCStream.createCameraStream(position: .back)
//        }
//        catch {
//            showError(error)
//            return
//        }
//
//        conversation.publish(stream: stream) { (error, stream) in
//            if let error = error {
//                showError(error)
//                return
//            }
//        }
//    }
//    
//    func handleStreamListUpdate(_ type: StreamInfoType, _ info: StreamInfo) {
//     
//        switch type {
//        case .added:
//            if !self.streamList.contains(info.streamId) && info.isRemote {
//                self.subscribeToStreamWithId(info.streamId)
//            }
//        case .removed:
//            handleStreamRemoving(info.streamId)
//        default:
//            break
//        }
//    }
//    
//    func subscribeToStreamWithId(_ streamId: String) {
//        
//        guard let conversation = conversation else {
//            showError("Can't subscribe, conversation is nil")
//            return
//        }
//
//        conversation.subscribeToStream(streamId: streamId)
//        streamList.append(streamId)
//    }
//    
//    func handleNewStream(_ stream: ApiRTCStream) {
//        
//        func handle() {
//            switch stream.direction {
//            case .published:
//                let newLocalStreamRow = LocalStreamRow()
//                newLocalStreamRow.tag = stream.id
//                streamsSection.append(newLocalStreamRow)
//                newLocalStreamRow.cell.addStream(stream)
//            case .subscribed:
//                let remoteStreamRow = RemoteStreamRow()
//                remoteStreamRow.tag = stream.id
//                streamsSection.append(remoteStreamRow)
//                remoteStreamRow.cell.addStream(stream)
//            }
//        }
//
//        DispatchQueue.main.async {
//            handle()
//        }
//    }
//    
//    func handleStreamRemoving(_ streamId: String) {
//        
//        func handle() {
//            if let rowNum = form.rowBy(tag: streamId)?.indexPath?.row {
//                streamsSection.remove(at: rowNum)
//            }
//        }
//
//        DispatchQueue.main.async {
//            handle()
//        }
//    }
//    
//}
