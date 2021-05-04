//
//  Utils.swift
//  SampleApp
//
//  Created by Aleksandr Khorobrykh on 17/12/2018.
//  Copyright © 2018 Apizee. All rights reserved.
//

import UIKit
import Eureka
import SnapKit

class Utils {

}

extension String {
    
    func loc() -> String {
        return NSLocalizedString(self, comment: "")
    }
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
}

extension UIViewController {
    
    func showErrorAlert(_ error: Error) {
        showOkAlert(title: "Error".loc(), message: "\(error):\n\r \(error.localizedDescription)")
    }
    
    func showErrorAlert(_ error: String) {
        showOkAlert(title: "Error".loc(), message: error)
    }
    
    func showOkAlert(title: String? = nil, message: String? = nil, okButtonTitle: String = "OK".loc(), okActionHandler: (() -> Void)? = nil) {
        
        func handle() {
            guard isViewLoaded, view.window != nil else { // controller is visible
                return
            }
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: okButtonTitle, style: .default) { (action) in
                okActionHandler?()
            }
            alert.addAction(okAction)
            
            present(alert, animated: true)
        }
        
        DispatchQueue.main.async {
            handle()
        }
    }
}

extension Row {
    func enable() {
        disabled = false
        evaluateDisabled()
        reload()
    }
    
    func disable() {
        disabled = true
        evaluateDisabled()
        reload()
    }
}

extension Section {
    func show() {
        hidden = false
        evaluateHidden()
        reload()
    }
    
    func hide() {
        hidden = true
        evaluateHidden()
        reload()
    }
}

extension UIViewController {
    
    func showActivityView() {
        DispatchQueue.main.async {
            let activityView = ActivityView()
            self.view.addSubview(activityView)
            activityView.snp.makeConstraints { (make) in
                make.top.left.right.bottom.equalTo(0)
            }
        }
    }
    
    func hideActivityView() {
        DispatchQueue.main.async {
            for view in self.view.subviews {
                if view is ActivityView {
                    view.removeFromSuperview()
                }
            }
        }
    }
}

extension UIColor {
    static let systemBlue = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
}

extension UIImage {
    func fixOrientation() -> UIImage? {
        
        if imageOrientation == .up {
            return self
        }
        
        var transform = CGAffineTransform.identity
        
        switch imageOrientation {
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0.0)
            transform = transform.rotated(by: .pi / 2.0)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0.0, y: size.height)
            transform = transform.rotated(by: -.pi / 2.0)
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: .pi)
        default:
            break
        }
        
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: 0.0)
            transform = transform.scaledBy(x: -1.0, y: 1.0)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: size.height, y: 0.0)
            transform = transform.scaledBy(x: -1.0, y: 1.0)
        default:
            break
        }
        
        guard let cgImg = cgImage else { return nil }
        
        if let context = CGContext(data: nil,
                                   width: Int(size.width), height: Int(size.height),
                                   bitsPerComponent: cgImg.bitsPerComponent,
                                   bytesPerRow: 0, space: cgImg.colorSpace!,
                                   bitmapInfo: cgImg.bitmapInfo.rawValue) {
            
            context.concatenate(transform)
            
            if imageOrientation == .left || imageOrientation == .leftMirrored ||
                imageOrientation == .right || imageOrientation == .rightMirrored {
                context.draw(cgImg, in: CGRect(x: 0.0, y: 0.0, width: size.height, height: size.width))
            }
            else {
                context.draw(cgImg, in: CGRect(x: 0.0 , y: 0.0, width: size.width, height: size.height))
            }
            
            if let contextImage = context.makeImage() {
                return UIImage(cgImage: contextImage)
            }
        }
        
        return nil
    }
}

// MARK: Pop messages

func showError(_ message: String) {
    print("ERROR: " + message)
    DispatchQueue.main.async {
        MessageView.show(label: "ERROR", message: message, backgroundColor: .red)
    }
}

func showError(_ error: Error) {
    showError("\(error)")
}

func showMessage(_ message: String) {
    DispatchQueue.main.async {
        MessageView.show(label: "MESSAGE", message: message, backgroundColor: .darkGray)
    }
}

// MARK:

func infoDict() -> [String: Any?]? {
    if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
        return NSDictionary(contentsOfFile: path) as? [String : Any?]
    }
    return nil
}
