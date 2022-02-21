//
//  WhiteboardViewController.swift
//  SampleApp
//
//  Created by Aleksandr Khorobrykh on 10/04/2019.
//  Copyright © 2019 Apizee. All rights reserved.
//

import UIKit
import ApiRTCSDK
import SnapKit

class WhiteboardViewController: UIViewController {

    var whiteboard: Whiteboard!
    
    var containerView: UIView!

    init(_ whiteboard: Whiteboard) {
        super.init(nibName: nil, bundle: nil)
        self.whiteboard = whiteboard
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white

        containerView = UIView(frame: view.bounds)
        view.addSubview(containerView)

        let whiteboardView = WhiteboardView(frame: containerView.bounds)
        containerView.addSubview(whiteboardView)
        whiteboardView.setMode(.edit)

        whiteboard.onEvent(self) { (event) in
            switch event {
            case .updateCanvasSize(let size):
                DispatchQueue.main.async {
                    whiteboardView.frame = CGRect(origin: .zero, size: size)
                }
            default:
                break
            }
        }
        
        let closeButton = UIButton()
        closeButton.setTitle("Close", for: .normal)
        closeButton.setTitleColor(.black, for: .normal)
        view.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(50)
            make.left.equalTo(30)
            make.width.equalTo(50)
            make.height.equalTo(25)
        }
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
    }
    
    @objc func close(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
