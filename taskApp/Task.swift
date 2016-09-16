//
//  Task.swift
//  taskApp
//
//  Created by 里舘 徹 on 2016/09/10.
//  Copyright © 2016年 tooru.satodate. All rights reserved.
//

import RealmSwift

class Task: Object {
    
    //　管理用　ID プライマリーキー
    dynamic var id = 0
    
    //　タイトル
    dynamic var title = ""
    
    //　内容
    dynamic var contents = ""
    
    //　日時
    dynamic var date = NSDate()
    
    // カテゴリー
    dynamic var category = ""
    
    /**
      id　をプライマリーキーとして設定
     */
    
    override static func primaryKey() -> String? {
        
        return "id"
    }
}
