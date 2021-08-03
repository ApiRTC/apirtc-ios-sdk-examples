//
//  UserAgentRegistrationExternalViewController.swift
//  SampleApp
//
//  Created by Maelle Saiag on 05/11/2020.
//  Copyright © 2020 Apizee. All rights reserved.
//

import UIKit
import Eureka
import ApiRTCSDK

enum UserAgentRegisterState {
    case register
    case unregister
}

class UserAgentRegistrationExternalViewController: FormViewController {
    
    var ua: UserAgent!
    
    var session: Session?
    
    var state: UserAgentRegisterState = .unregister {
        didSet {
            DispatchQueue.main.async {
                self.handleState(self.state)
            }
        }
    }
    
    var registerSection: Section!
    var userIdRow: TextRow!
    var registerRow: ButtonRow!
    var resultSection: Section!
    var resultRow: LabelRow!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(close))
        
        ApiRTC.setLogTypes([.info, .warning, .error, .debug, .cloud])
        ApiRTC.setMetaInfoLog(enabled: true)
                
        ua = UserAgent(UserAgentOptions(uri: .apzkey(Config.apiKey)))
            
        initUI()
    }
    
    func initUI() {
        form = Form()
        
        registerSection = Section()
        
        userIdRow = TextRow() {
            $0.title = "User Id"
        }
        
        registerRow = ButtonRow() {
            $0.title = "Register"
        }
        .onCellSelection { cell, row in
            switch self.state {
            case .register:
                self.unregister()
            case .unregister:
                self.register()
            }
        }
        
        resultSection = Section()
        
        resultRow = LabelRow()
            
        form
            +++ registerSection
            <<< userIdRow
            <<< registerRow
            +++ resultSection
            <<< resultRow
        
        state = .unregister
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
    
    func handleState(_ state: UserAgentRegisterState) {
        switch state {
        case .register:
            registerRow.title = "unregister"
        case .unregister:
            registerRow.title = "register"
        }
        
        switch state {
        case .register:
            registerSection.show()
            resultSection.show()
        case .unregister:
            registerSection.show()
            resultSection.hide()
        }
    }
    
    func register() {
        
        showActivityView()

        ua.register() { (error, session) in
            if let error = error {
                showError(error)
                return
            }
            guard let session = session else {
                showError("Session is nil")
                return
            }
            self.state = .register
            self.resultRow.title = "Your id is: "
            self.resultRow.value = session.id
            
            DispatchQueue.main.async {
                self.hideActivityView()
            }
        }
    }
    
    func unregister() {
        ua.unregister { (error) in
            if let error = error {
                showError(error)
                return
            }
            self.state = .unregister
        }
    }
}
