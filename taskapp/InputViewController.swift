//
//  InputViewController.swift
//  taskapp
//
//  Created by 津端 俊尚 on 2022/04/20.
//

import UIKit
import RealmSwift
import UserNotifications

// MARK: vars and lifecycle
class InputViewController: UIViewController {
    
    @IBOutlet private weak var titleTextField: UITextField!
    @IBOutlet private weak var contentsTextView: UITextView!
    @IBOutlet private weak var datePicker: UIDatePicker!
    @IBOutlet private weak var categoryLabel: UILabel!
    @IBOutlet private weak var pickerView: UIPickerView! {
        didSet {
            pickerView.delegate = self
            pickerView.dataSource = self
        }
    }
    
    private let realm = try! Realm()
    
    var task: Task!
    private var category: Category!
    private var categoryName = ""
    // DB内のカテゴリーが格納されるリスト。
    private var categoryArray = try! Realm().objects(Category.self).sorted(byKeyPath: "id", ascending: true)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        self.titleTextField.text = task.title
        self.contentsTextView.text = task.contents
        self.categoryLabel.text = task.category?.name
        self.datePicker.date = task.date
    }
    
    // カテゴリ入力画面から戻ってきた時に PickerView を更新させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        pickerView.reloadAllComponents()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let predicate = NSPredicate(format: "name == %@", categoryName)
        category = realm.objects(Category.self).filter(predicate).first
        
        try! realm.write {
            self.task.title = self.titleTextField.text!
            if category != nil {
                self.task.category = self.category
            }
            self.task.contents = self.contentsTextView.text
            self.task.date = self.datePicker.date
            self.realm.add(self.task, update: .modified)
        }
        
        setNotification(task: task)
        
        super.viewWillDisappear(animated)
    }

    /// タスクのローカル通知を登録
    /// - Parameter task: タスククラスのインスタンス
    func setNotification(task: Task) {
        let content = UNMutableNotificationContent()
        // タイトルと内容を設定(中身がない場合メッセージ無しで音だけの通知になるので「(xxなし)」を表示する)
        if task.title == "" {
            content.title = "(タイトルなし)"
        } else {
            content.title = task.title
        }
        if task.contents == "" {
            content.body = "(内容なし)"
        } else {
            content.body = task.contents
        }
        content.sound = UNNotificationSound.default
        
        // ローカル通知が発動するtrigger（日付マッチ）を作成
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        // identifier, content, triggerからローカル通知を作成（identifierが同じだとローカル通知を上書き保存）
        let request = UNNotificationRequest(identifier: String(task.id), content: content, trigger: trigger)
        
        // ローカル通知を登録
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            print(error ?? "ローカル通知登録 OK")  // error が nil ならローカル通知の登録に成功したと表示します。errorが存在すればerrorを表示します。
        }
        
        // 未通知のローカル通知一覧をログ出力
        center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
            for request in requests {
                print("/---------------")
                print(request)
                print("---------------/")
            }
        }
    }
    
    /// キーボードを閉じる
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
}

// MARK: - UIPickerViewDelegate
extension InputViewController: UIPickerViewDelegate {
    
    /// PickerViewの列の数
    /// - Parameter pickerView: pickerviewのインスタンス
    /// - Returns: 1
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    /// Pickerの行数を返す
    /// - Parameters:
    ///   - pickerView: pickerviewのインスタンス
    ///   - component: pickerの列数
    /// - Returns: DB内のカテゴリーが格納されるリストの数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryArray.count
    }
}

// MARK: - UIPickerViewDataSource
extension InputViewController: UIPickerViewDataSource {
    
    /// PickerViewの表示
    /// - Parameters:
    ///   - pickerView: pickerviewのインスタンス
    ///   - row: pickerの列
    ///   - component: コンポーネントを識別する番号
    /// - Returns: カテゴリー名
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let text = categoryArray[row].name
        return text
    }
    
    /// Pickerの各列が選択されたときの挙動
    /// - Parameters:
    ///   - pickerView: pickerviewのインスタンス
    ///   - row: pickerの列
    ///   - component: コンポーネントを識別する番号
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        categoryLabel.text = categoryArray[row].name
        categoryName = categoryArray[row].name
    }
}
