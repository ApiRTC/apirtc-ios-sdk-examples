//
//  ConversationJoinLeaveViewController.swift
//  SampleApp
//
//  Created by Maelle Saiag on 03/12/2020.
//  Copyright © 2020 Apizee. All rights reserved.
//

import Eureka
import ApiRTCSDK

class ConversationJoinLeaveViewController: ConversationViewController {
        
    var leaveConversationSection: Section!
    var leaveConversationButtonRow: ButtonRow!
                
    override func createForm() {
        
        leaveConversationSection = Section()
        leaveConversationButtonRow = ButtonRow() {
            $0.title = "Leave"
        }
        .onCellSelection { cell, row in
            self.leave()
        }
                
        form
            +++ Section()
            <<< localIdRow
            +++ joinConversationSection
            <<< joinConversationTextRow
            <<< joinConversationButtonRow
            +++ conversationIdSection
            <<< conversationIdRow
            +++ leaveConversationSection
            <<< leaveConversationButtonRow
            +++ streamsSection
    }
    
    override func handleState(_ state: ConversationViewControllerState) {
        super.handleState(state)
        switch state {
        case .initial:
            leaveConversationSection.hide()
        case .joined:
            leaveConversationSection.show()
        }
    }

    func leave() {
        
        guard let conversation = conversation else {
            showError("Can't leave, conversation is nil")
            return
        }
        
        conversation.leave {
            self.conversation = nil
            self.state = .initial
        }
    }
}
