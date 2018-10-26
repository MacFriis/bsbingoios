//
//  BingoView.swift
//  BS Bingo
//
//  Created by Per Friis on 22/10/2018.
//  Copyright © 2018 Per Friis. All rights reserved.
//

import UIKit

class BingoView: UIView {

//    override init(frame: CGRect) {
//        super.init(frame: frame)
//
//        setupView()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        setupView()
//    }
    
    @IBOutlet weak var timeLabel:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupView()
    }
    

    @IBAction func newGame(sender:Any) {
        removeFromSuperview()
    }
    
    func setupView(){
        layer.borderColor = UIColor.gray.cgColor
        layer.borderWidth = 0.5
        
        layer.cornerRadius = 8.0
        
        clipsToBounds = true
    }
}
