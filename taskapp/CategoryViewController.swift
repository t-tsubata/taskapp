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
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        registerButton.addTarget(self, action: #selector(self.tapButton(_:)), for: UIControl.Event.touchUpInside)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    @objc func tapButton(_ sender: UIButton){
        let realm = try! Realm()
        let category = Category()
        let allCategories = realm.objects(Category.self)
        let successAlert = UIAlertController(title: "登録成功", message: "登録に成功しました。", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        successAlert.addAction(okAction)
        
        try! realm.write {
            if self.categoryTextField.text != "" {
                if allCategories.count != 0 {
                    if allCategories.contains(where: {$0.name == categoryTextField.text!}) {
                        print("重複")
                        let duplicationAlert = UIAlertController(title: "カテゴリーの重複", message: "カテゴリーが重複したため、登録できませんでした。", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                            self.dismiss(animated: true, completion: nil)
                        }
                        duplicationAlert.addAction(okAction)
                        self.present(duplicationAlert, animated: true, completion: nil)
                    } else {
                        print("2個以上目のカテゴリー")
                        category.id = allCategories.max(ofProperty: "id")! + 1
                        category.name = self.categoryTextField.text!
                        realm.add(category, update: .modified)
                        self.present(successAlert, animated: true, completion: nil)
                    }
                } else {
                    print("新規")
                    category.id = 0
                    category.name = self.categoryTextField.text!
                    realm.add(category, update: .modified)
                    self.present(successAlert, animated: true, completion: nil)
                }
            }
        }
    }
}
