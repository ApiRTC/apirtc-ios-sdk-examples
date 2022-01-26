//
//  StartViewController.swift
//  SampleApp
//
//  Created by Aleksandr Khorobrykh on 29/01/2019.
//  Copyright © 2019 Apizee. All rights reserved.
//

import UIKit
import Eureka
import ApiRTCSDK

class StartViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        form = Form()
        
        form
            +++ Section()
            
            <<< ButtonRow() {
                $0.title = "User Agent registration"
                $0.presentationMode = .segueName(segueName: "UserAgentStartViewController", onDismiss: nil)
            }
            
            <<< ButtonRow() {
                $0.title = "Conversation"
                $0.presentationMode = .segueName(segueName: "ConversationStartViewController", onDismiss: nil)
            }
            
            <<< ButtonRow() {
                $0.title = "One-to-one communication"
                $0.presentationMode = .segueName(segueName: "CallViewController", onDismiss: nil)
            }
            
            <<< ButtonRow() {
                $0.title = "Stream management"
                $0.presentationMode = .segueName(segueName: "StreamsViewController", onDismiss: nil)
            }
        
            <<< TextRow() {
                $0.title = "SDK Version"
                $0.disabled = true
                $0.value = Bundle(for: ApiRTC.self).infoDictionary?["CFBundleShortVersionString"] as? String
            }
    }
}
