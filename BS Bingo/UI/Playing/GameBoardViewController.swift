//
//  GameBoardViewController.swift
//  BS Bingo
//
//  Created by Per Friis on 19/10/2018.
//  Copyright © 2018 Per Friis. All rights reserved.
//

import UIKit
import CoreData

extension Notification.Name {
    static let didSelectNewBoard = Notification.Name("didSelectNewBoard")
}

class GameBoardViewController: UIViewController {
    @IBOutlet var bingoView:BingoView!
    @IBOutlet weak var rowbingoView:BingoView!
    @IBOutlet weak var theStack:UIStackView!
    
    let viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var start = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let gameView = Bundle.main.loadNibNamed("GameBoard", owner: self, options: nil)?.first as? GameBoardView else {
            return
        }
        
        theStack.addArrangedSubview(gameView)
        
        NotificationCenter.default.addObserver(forName: .didSelectNewBoard, object: nil, queue: .main) { (notification) in
            guard let gameView = notification.object as? GameBoardView else {return}
            for v in self.theStack.subviews {

                v.removeFromSuperview()
                self.theStack.removeArrangedSubview(v)
            }
            
            self.theStack.addArrangedSubview(gameView)
            gameView.active = true
            gameView.isUserInteractionEnabled = true
            gameView.resetGame()
            self.start = Date()
        }
        
        NotificationCenter.default.addObserver(forName: .rowBingo, object: nil, queue: .main) { (notification) in
            self.rowbingoView.frame = self.view.bounds.insetBy(dx: 50, dy: (self.view.bounds.height / 2 ) - 100);
            
            let time = Int(-self.start.timeIntervalSinceNow)
            let minutes = time / 60
            self.rowbingoView.timeLabel.text = "\(minutes) minutes"
            self.view.addSubview(self.rowbingoView)
            DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                self.rowbingoView.removeFromSuperview()
            })
        }
        
        NotificationCenter.default.addObserver(forName: .bingo, object: nil, queue: .main) { (notification) in
            self.bingoView.frame = self.view.bounds.insetBy(dx: 50, dy: (self.view.bounds.height / 2 ) - 100);
            
            let time = Int(-self.start.timeIntervalSinceNow)
            let minutes = time / 60
            self.bingoView.timeLabel.text = "\(minutes) minutes"
            
            self.view.addSubview(self.bingoView)
            self.start  = Date()
        }
        
        
        NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: .main) { (notification) in
            gameView.setNeedsLayout()
        }
        
        NotificationCenter.default.addObserver(forName: .NSManagedObjectContextDidSave, object: nil, queue: .main) { (notification) in
            if gameView.words.count == 0 {
                gameView.words = BSWord.find(context: self.viewContext).map({$0.theWord!})
                gameView.resetGame()
            }
        }
        
        gameView.active = true
        gameView.words = BSWord.find(context: viewContext).map({$0.theWord!})
        gameView.resetGame()
        
        
        // Do any additional setup after loading the view.
    }
    
  
}
