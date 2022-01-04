//
//  UserAgentRegistrationIntegratedViewController.swift
//  SampleApp
//
//  Created by Maelle Saiag on 05/11/2020.
//  Copyright © 2020 Apizee. All rights reserved.
//

import UIKit
import Eureka
import ApiRTCSDK

enum UserAgentRegisterInternState {
    case initial
    case register
    case unregister
}

class UserAgentRegistrationIntegratedViewController: FormViewController {
    
    var ua: UserAgent?
    
    var session: Session?
    
    var state: UserAgentRegisterInternState = .initial {
        didSet {
            DispatchQueue.main.async {
                self.handleState(self.state)
            }
        }
    }
    
    var userAgentSection: Section!
    var loginRow: TextRow!
    var createUARow: ButtonRow!
    var registerSection: Section!
    var passwordRow: PasswordRow!
    var registerRow: ButtonRow!
    var resultSection: Section!
    var resultRow: LabelRow!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(close))
        
        ApiRTC.setLogTypes(.info, .warning, .error, .debug, .cloud)
        ApiRTC.setMetaInfoLog(enabled: true)
            
        initUI()
    }
    
    func initUI() {
        form = Form()
        
        userAgentSection = Section()
        
        loginRow = TextRow() {
            $0.title = "Your login"
        }
        
        createUARow = ButtonRow() {
            $0.title = "Create User Agent"
            $0.tag = "CreateUserAgent"
        }
        .onCellSelection { (cell, row) in
            self.createUserAgent()
        }
        
        registerSection = Section()
        
        registerRow = ButtonRow() {
            $0.title = "Register"
        }
        .onCellSelection { cell, row in
            switch self.state {
            case .register:
                self.unregister()
            case .unregister:
                self.register()
            default:
                break
            }
        }
        
        passwordRow = PasswordRow() {
            $0.title = "Password"
        }
        
        resultSection = Section()
        
        resultRow = LabelRow() {
            $0.tag = "result"
        }
            
        form
            +++ userAgentSection
            <<< loginRow
            <<< createUARow
            +++ registerSection
            <<< passwordRow
            <<< registerRow
            +++ resultSection
            <<< resultRow
        
        state = .initial
    }
    
    @objc func close() {
        
        showActivityView()
        
        ua?.unregister { (error) in
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
    
    func handleState(_ state: UserAgentRegisterInternState) {
        switch state {
        case .register:
            registerRow.title = "unregister"
        case .unregister:
            registerRow.title = "register"
        default:
        break
        }
        
        switch state {
        case .initial:
            userAgentSection.show()
            registerSection.hide()
            resultSection.hide()
        case .register:
            userAgentSection.show()
            registerSection.show()
            resultSection.show()
        case .unregister:
            userAgentSection.show()
            registerSection.show()
            resultSection.hide()
        }
    }
    
    func createUserAgent() {
        guard let login = loginRow.value else {
            showError("Login is nil")
            return
        }
        ua = UserAgent(UserAgentOptions(uri: .apikey(login)))
        state = .unregister
        DispatchQueue.main.async {
            if let rowNum = self.form.rowBy(tag: "CreateUserAgent")?.indexPath?.row {
                self.userAgentSection.remove(at: rowNum)
            }
        }
    }
    
    func register() {
        showActivityView()
        
        guard let password = passwordRow.value else {
            showError("Password is nil")
            return
        }
        let registerInfo = RegisterInformation(password: password)
        ua?.register(registerInformation: registerInfo) { (error, session) in
            if let error = error {
                showError(error)
                return
            }
            guard let session = session else {
                showError("Session is nil")
                return
            }
            self.state = .register
            self.resultRow.title = "Your id is"
            self.resultRow.value = session.id
            
            DispatchQueue.main.async {
                self.hideActivityView()
            }
        }
    }
    
    func unregister() {
        showActivityView()
        
        ua?.unregister { (error) in
            if let error = error {
                showError(error)
                return
            }
            self.state = .unregister
            DispatchQueue.main.async {
                self.hideActivityView()
            }
        }
    }
}
