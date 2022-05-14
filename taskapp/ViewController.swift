//
//  ViewController.swift
//  taskapp
//
//  Created by 津端 俊尚 on 2022/04/20.
//

import UIKit
import RealmSwift
import UserNotifications

// MARK: vars and lifecycle
class ViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            self.tableView.fillerRowHeight = UITableView.automaticDimension
            self.tableView.delegate = self
            self.tableView.dataSource = self
        }
    }
    
    @IBOutlet weak var categoryText: UITextField!
    private var pickerView = UIPickerView()
    
    // Realmインスタンスを取得する
    private let realm = try! Realm()
    
    // DB内のタスクが格納されるリスト。
    // 日付の近い順でソート：昇順
    // 以降内容をアップデートするとリスト内は自動的に更新される。
    private var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
    
    // DB内のカテゴリーが格納されるリスト。
    //private var categoryArray = try! Realm().objects(Category.self).sorted(byKeyPath: "id", ascending: true)
    private var categoryArray : [Category] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let list = try! Realm().objects(Category.self).sorted(byKeyPath: "id", ascending: true)
        let zeroCategory = Category()
        zeroCategory.id = 0
        zeroCategory.name = "すべてのカテゴリ"
        categoryArray = list.map {$0}
        categoryArray.append(zeroCategory)
        
        createPickerView()
    }
    
    // 入力画面から戻ってきた時に TableView を更新させる
    override func viewWillAppear(_ animated: Bool) {
        let list = try! Realm().objects(Category.self).sorted(byKeyPath: "id", ascending: true)
        categoryArray = list.map {$0}
        
        super.viewWillAppear(animated)
        tableView.reloadData()
        pickerView.reloadAllComponents()
    }
    
    // segue で画面遷移する時に呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let inputViewController:InputViewController = segue.destination as! InputViewController
        
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        } else {
            let task = Task()
            
            let allTasks = realm.objects(Task.self)
            if allTasks.count != 0 {
                task.id = allTasks.max(ofProperty: "id")! + 1
            }
            
            inputViewController.task = task
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        categoryText.endEditing(true)
    }
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }

    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // Cellに値を設定する
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString

        return cell
    }
}

// MARK: - UITableViewDelegate
extension ViewController: UITableViewDelegate {

    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue",sender: nil)
    }

    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
        return .delete
    }

    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // --- ここから ---
        if editingStyle == .delete {
            // 削除するタスクを取得する
            let task = self.taskArray[indexPath.row]
            
            // ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            // データベースから削除する
            try! realm.write {
                self.realm.delete(task)
                tableView.deleteRows(at: [indexPath], with: .fade)
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
    }
}

// MARK: - UIPickerViewDelegate
extension ViewController: UIPickerViewDelegate {
    
    // UIPickerViewの列の数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // UIPickerViewの行数、リストの数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryArray.count
    }
    
    func createPickerView() {
        pickerView.delegate = self
        categoryText.inputView = pickerView
        
        // toolbar
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44)
        //let doneButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(ViewController.donePicker))
        let doneButtonItem = UIBarButtonItem(title: "完了", style: .done, target: self, action: #selector(ViewController.donePicker))
        toolbar.setItems([doneButtonItem], animated: true)
        categoryText.inputAccessoryView = toolbar
    }
    
    @objc func donePicker() {
        categoryText.endEditing(true)
    }
}

// MARK: - UIPickerViewDataSource
extension ViewController: UIPickerViewDataSource {
    
    // UIPickerViewの最初の表示
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let text = categoryArray[row].name
        return text
    }
    
    // UIPickerViewのRowが選択された時の挙動
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let searchResults = realm.objects(Task.self).filter("category.id == %@", categoryArray[row].id)
        let allTasks = realm.objects(Task.self)
        
        categoryText.text = categoryArray[row].name
        
        if categoryArray[row].id == 0 {
            taskArray = allTasks
        } else {
            taskArray = searchResults
        }
        
        tableView.reloadData()
        
    }
}
