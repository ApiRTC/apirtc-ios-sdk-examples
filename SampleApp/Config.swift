//
//  Config.swift
//  SampleApp
//
//  Created by Aleksandr Khorobrykh on 01/02/2019.
//  Copyright © 2019 Apizee. All rights reserved.
//

import UIKit
import ApiRTCSDK

struct Config {
    
    static var apiKey: String {
        //showError("Enter your apiKey in the config")
        return "myDemoApiKey"
    }
    
    static var cloudUrl: String? {
        return infoDict()?["CLOUD_SERVER_URL"] as? String
    }

    struct UI {
        static var screenSize: CGSize {
            return UIScreen.main.bounds.size
        }
    }
}
