//
//  Memo.swift
//  GredMemo
//
//  Created by 박지홍 on 2020/02/16.
//  Copyright © 2020 gred. All rights reserved.
//

import Foundation

class Memo {
    var content: String
    var insertDate: Date
    
    init(content:String) {
        self.content = content
        insertDate = Date()
    }
    
    static var dummyMemoList = [
        Memo(content: "ABCD"),
        Memo(content: "EFGH")
    ]
}
