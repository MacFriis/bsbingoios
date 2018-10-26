//
//  GameBoardsCollectionViewController.swift
//  BS Bingo
//
//  Created by Per Friis on 21/10/2018.
//  Copyright © 2018 Per Friis. All rights reserved.
//

import UIKit

private let reuseIdentifier = "game board cell"

class GameBoardsCollectionViewController: UICollectionViewController {

    var viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var gameBoards:[GameBoardView] = []
    var filteredGameBorads:[GameBoardView] = []
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("Choose your game board", comment: "game borad select title")
        
        // setup search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "search BS words"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
    //    self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        createNewBoards()
        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

 


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return isFiltering ? filteredGameBorads.count :  gameBoards.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? GameBoardCollectionViewCell else {
            fatalError()
        }
    
        // Configure the cell
        let board = isFiltering ? filteredGameBorads[indexPath.row] :  gameBoards[indexPath.row]
    
        cell.theStack.addArrangedSubview(board)
        
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        let gameBoard = isFiltering ? filteredGameBorads.remove(at: indexPath.row) : gameBoards[indexPath.row]
        gameBoards.removeAll(where: {$0 == gameBoard})
        
        
        NotificationCenter.default.post(name: .didSelectNewBoard, object: gameBoard)
        if gameBoards.count == 0 {
            createNewBoards()
        } else {
            collectionView.reloadData()
        }
    }
    
    var searchBarIsEmpt: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpt
    }
    
    func filterContentForSearchText(searchText:String, scope: String = "All") {
        filteredGameBorads = gameBoards.filter({$0.contains(word: searchText)})
        
        print(filteredGameBorads.count)
        
        
        collectionView.reloadData()
    }
    
    func createNewBoards(count:Int = 5) {
        if gameBoards.count == 0 {
            for _ in 0..<5 {
                guard let gameView = Bundle.main.loadNibNamed("GameBoard", owner: self, options: nil)?.first as? GameBoardView else {
                    fatalError()
                }
                
                gameView.words = BSWord.find(context: viewContext).map({$0.theWord!})
                gameView.active = false
                gameView.isUserInteractionEnabled = false
                gameBoards.append(gameView)
            }
            
            collectionView.reloadData()
        }
    }
}

extension GameBoardsCollectionViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.bounds.width - 50
        let size = CGSize(width: width, height: width / 1.618)
        return size
    }
    
}


extension GameBoardsCollectionViewController : UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
       filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
}


class GameBoardCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var theStack:UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.borderColor = UIColor(named: "main")?.cgColor
        layer.borderWidth = 2
        layer.cornerRadius = 8
        clipsToBounds = true
    }
    
}
