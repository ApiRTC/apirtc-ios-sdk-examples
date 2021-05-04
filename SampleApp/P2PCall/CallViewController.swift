//
//  CallViewController.swift
//  SampleApp
//
//  Created by Aleksandr Khorobrykh on 25/09/2018.
//  Copyright © 2018 Apizee. All rights reserved.
//

/**
 This sample shows how to handle a simple P2P call
 */

import UIKit
import ApiRTCSDK
import Eureka

enum CallViewControllerState {
    case def
    case dialing
    case call
    case incomingCall
}

class CallViewController: FormViewController {
    
    var ua: UserAgent!
    
    var session: Session?
    
    var incomingInvitation: ReceivedCallInvitation?
    
    var activeCall: Call? {
        didSet {
            if let call = activeCall {
                handleCall(call)
            }
        }
    }
    
    var state: CallViewControllerState = .def {
        didSet {
            DispatchQueue.main.async {
                self.handleState(self.state)
            }
        }
    }
    
    var localIdRow: LabelRow!
    
    var opponentInfoSection: Section!
    var opponentIdRow: LabelRow!

    var dialSection: Section!
    var dialTextRow: TextRow!
    var dialButtonRow: ButtonRow!
    
    var incomingCallSection: Section!
    var incomingCallAcceptButtonRow: ButtonRow!
    var incomingCallDenyButtonRow: ButtonRow!
    
    var callSection: Section!
    var callHangUpButtonRow: ButtonRow!
    
    var streamsSection: Section!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        if #available(iOS 13.0, *) {
             overrideUserInterfaceStyle = .light
         }
        
        showActivityView()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(close))
            
        ApiRTC.setCloudServerAvailabilityChecker(enabled: true)
        ApiRTC.setLogTypes([.info, .warning, .error, .debug, .cloud])
        ApiRTC.setMetaInfoLog(enabled: true)
                                
        ua = UserAgent(UserAgentOptions(uri: .apzkey(Config.apiKey)))
        
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

            session.onEvent(self, { (event) in
                switch event {
                case .incomingCall(let invitation):
                    self.handleIncomingInvitation(invitation)
                default:
                    break
                }
            })

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
        
        opponentInfoSection = Section("Opponent info")
        opponentIdRow = LabelRow() {
            $0.title = "Opponent ID"
        }
        
        dialSection = Section("Dial")
        dialTextRow = TextRow() {
            $0.title = "ID"
            $0.cell.textField.keyboardType = .numberPad
        }
        dialButtonRow = ButtonRow() {
                $0.title = "Call"
            }
            .onCellSelection { cell, row in
                switch self.state {
                case .def:
                    self.call()
                case .dialing:
                    self.hangUp()
                default:
                    break
                }
            }
        
        incomingCallSection = Section("Incoming call")
        incomingCallAcceptButtonRow = ButtonRow() {
                $0.title = "Accept"
            }
            .onCellSelection { cell, row in
                self.acceptInvitation()
            }
        incomingCallDenyButtonRow = ButtonRow() {
                $0.title = "Deny"
                $0.cell.tintColor = .red
            }
            .onCellSelection { cell, row in
                self.denyInvitation()
            }
        
        callSection = Section("Ongoing call")
        
        callHangUpButtonRow = ButtonRow() {
                $0.title = "HangUp"
                $0.cell.tintColor = .red
            }
            .onCellSelection { cell, row in
                self.hangUp()
            }
        
        streamsSection = Section()
        
        form
            +++ Section()
            <<< localIdRow
            +++ opponentInfoSection
            <<< opponentIdRow
            +++ dialSection
            <<< dialTextRow
            <<< dialButtonRow
            +++ incomingCallSection
            <<< incomingCallAcceptButtonRow
            <<< incomingCallDenyButtonRow
            +++ callSection
            <<< callHangUpButtonRow
            +++ streamsSection
        
        state = .def
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
    
    func handleState(_ state: CallViewControllerState) {
        switch state {
        case .def:
            opponentInfoSection.hide()
            dialSection.show()
            incomingCallSection.hide()
            callSection.hide()
            streamsSection.hide()
            streamsSection.removeAll()
        case .dialing:
            opponentInfoSection.hide()
            dialSection.show()
            incomingCallSection.hide()
            callSection.hide()
            streamsSection.hide()
        case .incomingCall:
            opponentInfoSection.show()
            dialSection.hide()
            incomingCallSection.show()
            callSection.hide()
            streamsSection.hide()
        case .call:
            opponentInfoSection.show()
            dialSection.hide()
            incomingCallSection.hide()
            callSection.show()
            streamsSection.show()
        }
        
        switch state {
        case .dialing:
            dialButtonRow.title = "HangUp"
            dialButtonRow.cell.tintColor = .red
        default:
            dialButtonRow.title = "Call"
            dialButtonRow.cell.tintColor = .systemBlue
            break
        }
    }
    
    func call() {

        guard let session = session else {
            showError("Session is nil")
            return
        }
        guard let targetId = dialTextRow.value else {
            showError("Target id is nil")
            return
        }
        
        state = .dialing
        
        session.getContact(id: targetId).call { (error, call) in
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
            
            self.activeCall = call
        }
    }
    
    func handleIncomingInvitation(_ invitation: ReceivedCallInvitation) {
        
        func handle() {
            opponentIdRow.value = invitation.getSender().id
            opponentIdRow.reload()
            
            invitation.onEvent(self) { [weak self] (event) in
                guard let `self` = self else {
                    return
                }
                switch event {
                case .statusChanged(let status):
                    switch status {
                    case .cancelled:
                        self.handleInvitationCancellation()
                    default:
                        break
                    }
                default:
                    break
                }
            }
            
            incomingInvitation = invitation
            
            state = .incomingCall
        }
        DispatchQueue.main.async {
            handle()
        }
    }
    
    func acceptInvitation() {
        incomingInvitation?.accept(completion: { (error, call) in
            if let error = error {
                showError(error)
                return
            }
            guard let call = call else {
                showError("Call is nil")
                return
            }
            self.activeCall = call
            self.state = .call
        })
    }
    
    func denyInvitation() {
        incomingInvitation?.decline(completion: { (error) in
            if let error = error {
                showError(error)
                return
            }
            self.state = .def
        })
    }
    
    func handleInvitationCancellation() {
        incomingInvitation = nil
        state = .def
    }
    
    func handleCall(_ call: Call) {
        
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
    }
    
    func handleNewLocalStream(_ stream: ApiRTCStream) {
        DispatchQueue.main.async {
            let newLocalStreamRow = LocalStreamRow()
            self.streamsSection.append(newLocalStreamRow)
            newLocalStreamRow.cell.addStream(stream)
        }
    }
    
    func handleNewRemoteStream(_ stream: ApiRTCStream) {
        DispatchQueue.main.async {
            let remoteStreamRow = RemoteStreamRow()
            self.streamsSection.append(remoteStreamRow)
            remoteStreamRow.cell.addStream(stream)
        }
    }
    
    func hangUp() {
        
        state = .def
        
        activeCall?.hangUp(completion: { [weak self] in
            self?.activeCall = nil
        })
    }
    
    func handleCallAccept() {
        state = .call
    }
    
    func handleCallDecline() {
        state = .def
        showMessage("Call declined")
    }
    
    func handleRemoteHangUp() {
        
        state = .def
        
        showMessage("Call hang up")
        
        DispatchQueue.main.async {
            self.activeCall = nil
        }
    }
    
    // MARK:

    func test() {

    }
    
    // MARK:
    
    func shareLog() {
        do {
            guard let url = try ApiRTC.getLogFileURL() else {
                showError("URL is nil")
                return
            }
            let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            present(activityVC, animated: true, completion: nil)
        }
        catch {
            showError(error)
            return
        }
    }
}
