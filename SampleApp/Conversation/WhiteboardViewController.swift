//
//  WhiteboardViewController.swift
//  SampleApp
//
//  Created by Aleksandr Khorobrykh on 10/04/2019.
//  Copyright © 2019 Apizee. All rights reserved.
//

import UIKit
import ApiRTCSDK

class WhiteboardViewController: UIViewController {

    var containerView: UIView!
    
    var whiteboardView: WhiteboardView?
    
    var whiteboardClient: WhiteboardClient?
    
    deinit {
        whiteboardClient?.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
             overrideUserInterfaceStyle = .light
        }

        guard let session = Session.getActiveSession() else {
            showError("No active session")
            return
        }
        let ua = session.getUserAgent()

        guard let whiteboardClient = ua.getWhiteboardClient() else {
            showError("No whiteboard client")
            return
        }

        containerView = UIView(frame: view.bounds)
        containerView.backgroundColor = .yellow
        view.addSubview(containerView)

        let whiteboardView = WhiteboardView(frame: containerView.bounds)
        containerView.addSubview(whiteboardView)
        whiteboardClient.setView(whiteboardView)
        whiteboardView.setMode(.edit)

        self.whiteboardClient = whiteboardClient
        self.whiteboardView = whiteboardView
        
        whiteboardClient.onEvent(self) { (event) in
            switch event {
            case .newCanvasSize(let size):
                DispatchQueue.main.async {
                    whiteboardView.frame = CGRect(origin: .zero, size: size)
                }
            case .newBackgroundImage(let image):
                DispatchQueue.main.async {
                    whiteboardView.frame = CGRect(origin: .zero, size: image.size)
                    whiteboardView.setBackgroundImage(image, contentMode: .topLeft)
                }
            default:
                break
            }
        }
    }
}
