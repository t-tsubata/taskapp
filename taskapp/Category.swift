//
//  Category.swift
//  taskapp
//
//  Created by 津端 俊尚 on 2022/04/30.
//

import RealmSwift

class Category: Object {
    
    // 管理用 ID。プライマリーキー
    @objc dynamic var id = 0
    
    // 名前
    @objc dynamic var name = ""
    
    // idをプライマリキーとして設定
    override static func primaryKey() -> String? {
        return "id"
    }
}
