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
        
        registerButton.addTarget(self, action: #selector(self.tapRegisterButton(_:)), for: UIControl.Event.touchUpInside)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    /// キーボードを閉じる
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    /// 登録ボタンがタップされたときの処理
    /// - Parameter sender: Buttonのインスタンス
    @objc func tapRegisterButton(_ sender: UIButton){
        guard let categoryText = self.categoryTextField.text, !categoryText.isEmpty else {
            return
        }
        
        let realm = try! Realm()
        let allCategories = realm.objects(Category.self)
        
        if allCategories.contains(where: {$0.name == categoryText}) {
            print("重複")
            showDuplicateAlert()
            return
        }
        
        let category = Category()
        category.name = categoryText
        
        if allCategories.isEmpty {
            print("新規")
            category.id = 0
        } else {
            print("2個以上目のカテゴリー")
            category.id = allCategories.max(ofProperty: "id")! + 1
        }
        
        try! realm.write {
            realm.add(category, update: .modified)
        }
        
        showRegisterAlert()
    }
    
    /// 登録アラートを表示
    func showRegisterAlert() {
        let registerAlert = UIAlertController(title: "登録成功", message: "登録に成功しました。", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            self.navigationController?.popViewController(animated: true)
        }
        
        registerAlert.addAction(okAction)
        self.present(registerAlert, animated: true, completion: nil)
    }
    
    /// 重複アラートの表示
    func showDuplicateAlert() {
        let duplicateAlert = UIAlertController(title: "カテゴリーの重複", message: "カテゴリーが重複したため、登録できませんでした。", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            self.navigationController?.popViewController(animated: true)
        }
        duplicateAlert.addAction(okAction)
        self.present(duplicateAlert, animated: true, completion: nil)
    }
}
