//
//  MessageView.swift
//  ApizeeConference
//
//  Created by Aleksandr Khorobrykh on 04/06/2018.
//  Copyright © 2018 Apizee. All rights reserved.
//

import UIKit
import SwiftMessages

class MessageView: BaseView {
    
    private typealias T = MessageView
    
    private var label: String!
    private var message: String!
    private var _backgroundColor: UIColor!
    private static var labelHeight: CGFloat = 20
    private static var messageTopBottomOffset: CGFloat = 15
    private static var messageFont = UIFont.systemFont(ofSize: 13)
    private static var messageSideOffset: CGFloat = 15
    private static var maxHeight = UIScreen.main.bounds.size.height / 2
    
    private var _id: String = "undefined"
    
    init(label: String, message: String, backgroundColor: UIColor) {
        super.init(frame: .zero)
        self.label = label
        self.message = message
        self._backgroundColor = backgroundColor
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initUI() {
        
        var messageHeight = message.height(withConstrainedWidth: UIScreen.main.bounds.size.width - 2 * T.messageSideOffset, font: T.messageFont)
        if messageHeight > T.maxHeight {
            messageHeight = T.maxHeight
        }
        
        let wrapper = UIView()
        wrapper.backgroundColor = _backgroundColor.withAlphaComponent(0.8)
        self.addSubview(wrapper)
        wrapper.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(0)
            make.height.equalTo(messageHeight + T.labelHeight + 2 * T.messageTopBottomOffset)
        }
        
        let labelView = UILabel()
        labelView.isUserInteractionEnabled = true
        labelView.text = label
        labelView.backgroundColor = .clear
        labelView.textColor = .white
        labelView.font = UIFont.boldSystemFont(ofSize: 14)
        wrapper.addSubview(labelView)
        labelView.snp.makeConstraints { (make) in
            make.top.equalTo(T.messageTopBottomOffset)
            make.left.equalTo(T.messageSideOffset)
            make.right.equalTo(-T.messageSideOffset)
            make.height.equalTo(T.labelHeight)
        }
        
        let messageLabel = UILabel()
        messageLabel.isUserInteractionEnabled = true
        messageLabel.text = message
        messageLabel.backgroundColor = .clear
        messageLabel.textColor = .white
        messageLabel.font = T.messageFont
        messageLabel.numberOfLines = 0
        wrapper.addSubview(messageLabel)
        messageLabel.snp.makeConstraints { (make) in
            make.top.equalTo(labelView.snp.bottom)
            make.left.equalTo(T.messageSideOffset)
            make.right.equalTo(-T.messageSideOffset)
            make.height.equalTo(messageHeight)
        }
        
        self.installContentView(wrapper)
        
        self.tapHandler = { _ in
            SwiftMessages.hide()
        }
    }
    
    open class func show(label: String, message: String, id: String? = nil, backgroundColor: UIColor, onMessageHideCompletion: (() -> Void)? = nil) {
        
        var config = SwiftMessages.Config()
        config.presentationStyle = .top
        config.ignoreDuplicates = false
        config.presentationContext = .window(windowLevel: UIWindow.Level.statusBar)
        config.duration = .seconds(seconds: 2)
        config.interactiveHide = true
        config.eventListeners.append() { event in
            if case .didHide = event {
                onMessageHideCompletion?()
            }
        }
        
        let view = MessageView(label: label, message: message, backgroundColor: backgroundColor)
        if let id = id {
            view._id = id
        }
        
        SwiftMessages.show(config: config, view: view)
    }
    
    open class func hide(id: String) {
        SwiftMessages.hide(id: id)
    }
}

extension MessageView: Identifiable {
    var id: String {
        return _id
    }
}
