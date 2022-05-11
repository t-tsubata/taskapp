//
//  CategoryViewController.swift
//  taskapp
//
//  Created by 津端 俊尚 on 2022/04/30.
//

import UIKit
import RealmSwift

class CategoryViewController: UIViewController {

    @IBOutlet private weak var categoryTextField: UITextField!
    
    private let realm = try! Realm()
    var category: Category!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        categoryTextField.text = category.name
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        try! realm.write {
            if self.categoryTextField.text != "" {
                self.category.name = self.categoryTextField.text!
                self.realm.add(self.category, update: .modified)
            }
        }
        super.viewWillDisappear(animated)
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
}
