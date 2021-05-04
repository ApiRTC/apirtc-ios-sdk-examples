//
//  ActivityRow.swift
//  SampleApp
//
//  Created by Aleksandr Khorobrykh on 22/05/2019.
//  Copyright © 2019 Apizee. All rights reserved.
//

import Eureka
import UIKit

public final class ActivityRow: Row<ActivityCell>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<ActivityCell>()
    }
}

public class ActivityCell: Cell<Bool>, CellType {
    
    private var label: UILabel!
    private var activityIndicator: UIActivityIndicatorView!
    
    public override func setup() {
        super.setup()
        
        isUserInteractionEnabled = false
        
        height = {
            return 50
        }
        
        activityIndicator = UIActivityIndicatorView(style: .gray)
        self.contentView.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { (make) in
            make.width.height.equalTo(50)
            make.left.top.equalTo(0)
        }
        activityIndicator.startAnimating()
        
        label = UILabel()
        label.text = row.tag
        self.contentView.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.top.right.bottom.equalTo(0)
            make.left.equalTo(activityIndicator.snp.right)
        }
    }
    
    public override func update() {
        super.update()
    }
}
