//
//  ActivityView.swift
//  SampleApp
//
//  Created by Aleksandr Khorobrykh on 01/02/2019.
//  Copyright © 2019 Apizee. All rights reserved.
//

import UIKit

class ActivityView: UIView {
    
    init() {
        super.init(frame: .zero)
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initUI() {
        
        self.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        self.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { (make) in
            make.width.height.equalTo(50)
            make.center.equalTo(snp.center)
        }
        activityIndicator.startAnimating()
    }
}
