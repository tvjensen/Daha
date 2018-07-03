//
//  dahaButton1.swift
//  Daha
//
//  Created by Thomas Jensen on 6/28/18.
//  Copyright © 2018 Thomas Jensen. All rights reserved.
//

import UIKit

class dahaButton1: UIButton {
    
    required init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)
        
        backgroundColor = UIColor.flatWatermelonDark
        layer.cornerRadius = 5.0
        self.setTitleColor(.white, for: .normal)
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
