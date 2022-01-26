//
//  ConversationMediaDeviceSelectionViewController.swift
//  SampleApp
//
//  Created by Maelle Saiag on 01/12/2020.
//  Copyright © 2020 Apizee. All rights reserved.
//

import Eureka
import ApiRTCSDK
import AVFoundation

class ConversationMediaDeviceSelectionViewController: ConversationViewController {
    
    var switchConversationSection: Section!
    var switchConversationButtonRow: ButtonRow!
    
    override func createForm() {
        
        switchConversationSection = Section()
        switchConversationButtonRow = ButtonRow() {
                $0.title = "Switch camera"
            }
            .onCellSelection { cell, row in
                self.switchCamera()
            }
                
        form
            +++ Section()
            <<< localIdRow
            +++ joinConversationSection
            <<< joinConversationTextRow
            <<< joinConversationButtonRow
            +++ conversationIdSection
            <<< conversationIdRow
            +++ switchConversationSection
            <<< switchConversationButtonRow
            
            +++ streamsSection
    }
    
    override func handleState(_ state: ConversationViewControllerState) {
        super.handleState(state)
        switch state {
        case .initial:
            switchConversationSection.hide()
        case .joined:
            switchConversationSection.show()
        }
    }
    
    func switchCamera() {
        guard let streams = conversation?.getPublishedStreams() else {
            showError("No published streams")
            return
        }
        guard let stream = streams.first(where: { $0.device != nil }) else {
            showError("No published streams using camera device")
            return
        }
        guard let device = stream.device else {
            showError("No deivce")
            return
        }
        let newPosition: AVCaptureDevice.Position = device.position == .back ? .front : .back
        
        var newStream: ApiRTCStream!

        do {
            newStream = try ApiRTCStream.createCameraStream(position: newPosition)
        }
        catch {
            showError(error)
            return
        }
        
        guard let call = conversation?.getConversationCall(stream.id) else {
            showError("No conversation call")
            return
        }
        
        call.replacePublishedStream(streamId: stream.id, withStream: newStream) { (error, stream) in
            if let error = error {
                showError(error)
                return
            }
        }
    }
}
