//
//  GameFieldView.swift
//  BS Bingo
//
//  Created by Per Friis on 19/10/2018.
//  Copyright © 2018 Per Friis. All rights reserved.
//

import UIKit

extension Notification.Name {
    static let didTapWord = Notification.Name("didTapWord")
}

class GameFieldView: UIView {
    @IBOutlet weak var wordLabel:UILabel!
    @IBOutlet weak var tappedView:UIVisualEffectView!
    @IBOutlet weak var blidFieldView:UIView!

    var rotate = true {
        didSet {
              wordLabel.transform = CGAffineTransform(rotationAngle:rotate ?  CGFloat.pi * 0.5 : 0)
        }
    }
    
    var touchGesture = UITapGestureRecognizer()
   
    enum GameFieldStatus {
        case ready
        case tapped
        case blind
    }
    
    var state:GameFieldStatus = .ready {
        didSet{
            updateVisible()
        }
    }
    

    
    func reset(){
        guard state != .blind else {return}
        state = .ready
        
    }
   

    fileprivate func updateVisible(){
        wordLabel.isHidden = state == .blind
        tappedView.isHidden = state != .tapped || state == .blind
        blidFieldView.isHidden = state != .blind
    }
    
    func ajustTextSize() {
        
        let width = wordLabel.bounds.width
        let max = wordLabel.bounds.height
        
        guard let textString = wordLabel.text as NSString? else {
                return
        }
        
        let font = UIFont.preferredFont(forTextStyle: .largeTitle)
       
  
        let startSize = font.pointSize
        var fontSize = startSize
        var height:CGFloat = 2000
        repeat {
            fontSize *= 0.95
             height = textString.boundingRect(with: CGSize(width: width, height: 2000),
                                                options: .usesLineFragmentOrigin,
                                                attributes: [NSAttributedString.Key.font: UIFont(name: font.fontName, size: fontSize)!],
                                                context: nil).height
            
            if fontSize * 2 < startSize {
                break
            }
            
        } while height > max
        
        wordLabel.font = UIFont(name: font.fontName, size: fontSize)
        
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
       setupView()
    }
    
    
    func setupView(){
        updateVisible()
        guard gestureRecognizers == nil else {return}
        
        touchGesture.addTarget(self, action: #selector(tapTheField(tapGesture:)))
        addGestureRecognizer(touchGesture)
        tappedView.clipsToBounds = true
        
        blidFieldView.layer.cornerRadius = 8
        blidFieldView.clipsToBounds = true
        blidFieldView.backgroundColor = UIColor(named: "main")
        
        layer.cornerRadius = 10
        layer.borderColor = UIColor(named: "main")?.cgColor
        layer.borderWidth = 2
    
        wordLabel.transform = CGAffineTransform(rotationAngle:rotate ?  CGFloat.pi * 0.5 : 0)
    
    }
    
    @objc func tapTheField(tapGesture : UIGestureRecognizer) {
        guard state == .ready else {
            return
        }
        
        tappedView.alpha = 0
        state = .tapped
        NotificationCenter.default.post(name: .didTapWord, object: self)
        
        UIView.animate(withDuration: 0.25) {
            self.tappedView.alpha = 1
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        print(#function)
        let tappedViewHeight = CGFloat.minimum(bounds.height, bounds.width) - 16
        tappedView.frame = CGRect(x: 0, y: 0, width: tappedViewHeight, height: tappedViewHeight)
        tappedView.center = CGPoint(x: bounds.midX, y: bounds.midY)
        tappedView.layer.cornerRadius = tappedViewHeight / 2
        
        wordLabel.frame = bounds.insetBy(dx: 8, dy: 8)
        ajustTextSize()
        
        
        blidFieldView.frame = bounds.insetBy(dx: 6, dy: 6)
    }
}
