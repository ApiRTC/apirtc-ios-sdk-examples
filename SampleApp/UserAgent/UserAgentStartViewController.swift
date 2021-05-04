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
        
        if #available(iOS 13.0, *) {
             overrideUserInterfaceStyle = .light
         }
        
        form = Form()
        
        form
            +++ Section()
        
            <<< ButtonRow() {
                $0.title = "External user management"
                $0.presentationMode = .segueName(segueName: "UserAgentRegistrationExternalViewController", onDismiss: nil)
            }
        
            <<< ButtonRow() {
                $0.title = "Integrated user management"
                $0.presentationMode = .segueName(segueName: "UserAgentRegistrationIntegratedViewController", onDismiss: nil)
            }
    }
}
