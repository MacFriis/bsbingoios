//
//  GameBoard.swift
//  BS Bingo
//
//  Created by Per Friis on 19/10/2018.
//  Copyright © 2018 Per Friis. All rights reserved.
//

import UIKit

extension Notification.Name {
    static let rowBingo = Notification.Name("rowBingo")
    static let bingo = Notification.Name("bingo")
}

class GameBoardView: UIView {
     @IBOutlet var fields: [GameFieldView]!
    
    var active = true {
        didSet{
            for field in fields {
                field.rotate = active
                field.setNeedsLayout()
            }
        }
    }
    var rowBingo = false
    var fullBindo = false
    
    var activeWords:[String] = []
    
    var words:[String] = [] {
        didSet {
            updateWords()
        }
    }
    
    
    /// Check if the word list contains this word, in lowercase
    func contains(word:String) -> Bool {
        
        let wordSting = self.activeWords.joined(separator: " ")
        
        return wordSting.lowercased().contains(word.lowercased())
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        

        var blindCount:Int = 0
        while blindCount < 5 {
            let blind = fields.filter({$0.state != .blind && $0.wordLabel.text == ""}).randomElement()
            blind?.state = .blind
            blindCount += 1
        }
        
       updateWords()
        
        NotificationCenter.default.addObserver(forName: .didTapWord, object: nil, queue: .main) { (notification) in
            self.checkRow()
        }
        
      
    }
    
    func resetGame(){
        for field in fields {
            field.reset()
        }
        
        fullBindo = false
        rowBingo = false
        for col in 0..<statuses.count {
            for row in 0..<statuses[col].count {
                statuses[col][row] = false
            }
        }
    }
    
    var statuses = [[false,false,false,false],
                    [false,false,false,false],
                    [false,false,false,false],
                    [false,false,false,false],
                    [false,false,false,false]]
    
    func checkRow(){
    
        
        for index in 0..<fields.count {
            let colomn = index / 4
           statuses[colomn][index - (colomn * 4)] = fields[index].state != .ready
        }
        
        var fullbingo = 0
        for col in 0..<statuses.count {
            if statuses[col].filter({!$0}).count == 0 {
                if !rowBingo {
                    NotificationCenter.default.post(name: .rowBingo, object: nil)
                    print("row bingo")
                }
                fullbingo += 1
                rowBingo = true
            }
        }
        
        if fullbingo == 5 {
            NotificationCenter.default.post(name: .bingo, object: nil)
            print("full bingo")
//            for field in fields {
//                field.reset()
//            }
            resetGame()
        }
        
        
       
    }
    
    func updateWords(){
        for fieldView in fields.filter({$0.state != .blind}) {
            fieldView.wordLabel.text = words.randomElement()
        }
        
        activeWords = fields.map({$0.wordLabel.text ?? ""})
    }
}
