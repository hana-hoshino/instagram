//
//  PostData.swift
//  instagram
//
//  Created by 星野　花 on 2020/06/19.
//  Copyright © 2020 Kana.h. All rights reserved.
//

import UIKit
import Firebase

class PostData: NSObject {
    var id: String
    var name: String?
    var caption: String?
    var date: Date?
    var likes: [String] = []
    var isLiked: Bool = false
    var comments: [String] = []
    
    init(document:QueryDocumentSnapshot) {
        self.id = document.documentID
        let postDic = document.data()
        self.name = postDic["name"] as? String
        self.caption = postDic["caption"] as? String
        let timestamp = postDic["date"] as? Timestamp
        self.date = timestamp?.dateValue()
        if let likes = postDic["likes"] as? [String] {
            self.likes = likes
        }
        if let myid = Auth.auth().currentUser?.uid {
            if(self.likes.firstIndex(of: myid) != nil) {
                self.isLiked = true
            }
        }
        if let comments = postDic["comments"] as? [String] {
            self.comments = comments
        }
    }

}
