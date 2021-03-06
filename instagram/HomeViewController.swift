//
//  HomeViewController.swift
//  instagram
//
//  Created by 星野　花 on 2020/06/16.
//  Copyright © 2020 Kana.h. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var postArray: [PostData] = []
    var listener: ListenerRegistration!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: viewWillAppear")
        
        if(Auth.auth().currentUser != nil) {    //ログイン済の場合
            
            //listenerに登録していない場合、登録。
            if(listener == nil) {
                let postsRef = Firestore.firestore().collection(Const.PostPath).order(by: "date", descending: true)
                listener = postsRef.addSnapshotListener() {(QuerySnapshot, error) in
                    if let error = error {
                        print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                        return
                    }
                    
                    //PostDataをpostArrayに追加
                    self.postArray = QuerySnapshot!.documents.map { document in
                        print("DEBUG_PRINT: document取得 \(document.documentID)")
                        let postData = PostData(document: document)
                        return postData
                    }
                    
                    self.tableView.reloadData()
                }
            }
        } else {    //ログアウト、または未ログインの場合、postArrayをクリア
            if(listener != nil) {
                listener.remove()
                listener = nil
                postArray = []
                tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostTableViewCell
        cell.setPostData(postArray[indexPath.row])
        
        cell.likeButton.addTarget(self, action: #selector(handleButton(_:forEvent:)), for: .touchUpInside)
        cell.commentButton.addTarget(self, action: #selector(handleCommentButton(_:forEvent:)), for: .touchUpInside)
        
        return cell
    }
    
    //いいねボタンがタップした時
    @objc func handleButton(_ sender: UIButton, forEvent event: UIEvent) {
        print("DEBUG_PRINT: likeボタンがタップされました。")
        
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        let postData = postArray[indexPath!.row]
        
        if let myid = Auth.auth().currentUser?.uid {
            var updateValue: FieldValue
            if postData.isLiked {
                //いいねされている場合は、いいねのmyidを取り除く
                updateValue = FieldValue.arrayRemove([myid])
            } else {
                //いいねされていなかったら、myidを追加
                updateValue = FieldValue.arrayUnion([myid])
            }
            let postRef = Firestore.firestore().collection(Const.PostPath).document(postData.id)
            postRef.updateData(["likes": updateValue])
        }
    }
    
    //コメントボタンをタップした時
    @objc func handleCommentButton(_ sender: UIButton, forEvent event: UIEvent) {
        print("DEBUG_PRINT: コメントボタンがタップされました。")
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        // 配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]
        
        //ポップアップを出す
        var alertTextField: UITextField?
        var nameTextField: UITextField?
        let alert = UIAlertController(
            title: "名前とコメントを入力してください",
            message: "Please enter a name and comment",
            preferredStyle: UIAlertController.Style.alert)
        alert.addTextField(
            configurationHandler: {(textField: UITextField!) in
                textField.text = "Name"
                //textFieldのインスタンスをalertTextField変数に代入することで外の関数でも利用できるようにしています。
                nameTextField = textField
        })
        alert.addTextField(
            configurationHandler: {(textField: UITextField!) in
                textField.text = "Comment"
                //textFieldのインスタンスをalertTextField変数に代入することで外の関数でも利用できるようにしています。
                alertTextField = textField
        })
        
        //キャンセルボタンを押した時
        alert.addAction(
            UIAlertAction(
                title: "Cancel",
                style: UIAlertAction.Style.cancel,
                handler: nil))
        //OKボタンを押した時
        alert.addAction(
            UIAlertAction(
                title: "OK",
                style: UIAlertAction.Style.default) { _ in
                    if let content = alertTextField?.text, let name = nameTextField?.text {
                        //ログインしている場合
                        if (Auth.auth().currentUser?.uid != nil) {
                            //Firebase上のcommentを更新する
                            var updateValue: FieldValue
                            let comment = "\(name) : \(content)"
                            updateValue = FieldValue.arrayUnion([comment])
                            
                            //commentsに更新データを書き込む
                            let postRef = Firestore.firestore().collection(Const.PostPath).document(postData.id)
                            postRef.updateData(["comments": updateValue])
                            
                            //アプリ上のcommentを更新する
                            postData.comments.append("comments")
                            print("DEBUG_PRINT: コメントが更新されました。")
                        }
                    }
            }
        )
        self.present(alert, animated: true, completion: nil)
        
        //self.tableView.reloadData() を追加するかも
        
    }
}



/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destination.
 // Pass the selected object to the new view controller.
 }
 */
