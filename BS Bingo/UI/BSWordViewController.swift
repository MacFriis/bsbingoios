//
//  BSWordViewController.swift
//  BS Bingo
//
//  Created by Per Friis on 22/10/2018.
//  Copyright © 2018 Per Friis. All rights reserved.
//

import UIKit
import CoreData

class BSWordViewController: UIViewController {
    
    @IBOutlet weak var newWordTextField:UITextField!
    @IBOutlet weak var categoriesPickerView:UIPickerView!
    @IBOutlet weak var scopeSegment:UISegmentedControl!

    var categories:[Category] = []
    
    let viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        categories = Category.find(context: viewContext)
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension BSWordViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let word = textField.text,
            word.count > 0,
            BSWord.find(predicate: NSPredicate(format: "theWord == %@", word), context: viewContext).count == 0 else {
                return
        }
        
        let bsword = BSWord(context: viewContext)
        bsword.theWord = word
        bsword.language = "en"
        bsword.category = categories[categoriesPickerView.selectedRow(inComponent: 0)]
        
        do {
            try viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    
}

extension BSWordViewController : UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
}

extension BSWordViewController : UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
       return categories[row].name
    }
}
