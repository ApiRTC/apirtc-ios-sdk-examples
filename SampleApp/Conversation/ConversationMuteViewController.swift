//
//  ConversationMuteViewController.swift
//  SampleApp
//
//  Created by Maelle Saiag on 03/12/2020.
//  Copyright © 2020 Apizee. All rights reserved.
//

import Eureka
import ApiRTCSDK

class ConversationMuteViewController: ConversationViewController {
    
    var localStream: ApiRTCStream!
    
    var muteConversationSection: Section!
    var muteAudioLocalStreamButtonRow: ButtonRow!
    var muteVideoLocalStreamButtonRow: ButtonRow!
                
    override func createForm() {
        
        muteConversationSection = Section()
        muteAudioLocalStreamButtonRow = ButtonRow() {
            $0.title = "Mute audio"
        }
        .onCellSelection { cell, row in
            self.muteUnmuteAudio()
        }
        muteVideoLocalStreamButtonRow = ButtonRow() {
            $0.title = "Mute video"
        }
        .onCellSelection { cell, row in
            self.muteUnmuteVideo()
        }
                
        form
            +++ Section()
            <<< localIdRow
            +++ joinConversationSection
            <<< joinConversationTextRow
            <<< joinConversationButtonRow
            +++ conversationIdSection
            <<< conversationIdRow
            +++ muteConversationSection
            <<< muteAudioLocalStreamButtonRow
            <<< muteVideoLocalStreamButtonRow
            
            +++ streamsSection
    }
        
    override func handleState(_ state: ConversationViewControllerState) {
        super.handleState(state)
        switch state {
        case .initial:
            muteConversationSection.hide()
        case .joined:
            muteConversationSection.show()
        }
    }
        
    func muteUnmuteAudio() {
        if localStream.isAudioMuted() {
            localStream.unmuteAudio()
            muteAudioLocalStreamButtonRow.title = "Mute audio"
        }
        else {
            localStream.muteAudio()
            muteAudioLocalStreamButtonRow.title = "Unmute audio"
        }
        muteAudioLocalStreamButtonRow.updateCell()
    }
    
    func muteUnmuteVideo() {
        if localStream.isVideoMuted() {
            localStream.unmuteVideo()
            muteVideoLocalStreamButtonRow.title = "Mute video"
        }
        else {
            localStream.muteVideo()
            muteVideoLocalStreamButtonRow.title = "Unmute video"
        }
        muteVideoLocalStreamButtonRow.updateCell()
    }
    
    override func handleNewStream(_ stream: ApiRTCStream) {
        super.handleNewStream(stream)
        if stream.direction == .published {
            localStream = stream
        }
    }
    
}
