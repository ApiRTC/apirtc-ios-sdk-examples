//
//  UserAgentStartViewController.swift
//  SampleApp
//
//  Created by Maelle Saiag on 05/11/2020.
//  Copyright © 2020 Apizee. All rights reserved.
//

import UIKit
import Eureka

class UserAgentStartViewController: FormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form = Form()
        
        form
            +++ Section()
        
            <<< ButtonRow() {
                $0.title = "Register as a guest"
                $0.presentationMode = .segueName(segueName: "UserAgentGuestRegistrationViewController", onDismiss: nil)
            }
        
            <<< ButtonRow() {
                $0.title = "Register using account"
                $0.presentationMode = .segueName(segueName: "UserAgentUsingAccountRegistrationViewController", onDismiss: nil)
            }
    }
}
