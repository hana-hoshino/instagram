//
//  SettingViewController.swift
//  instagram
//
//  Created by 星野　花 on 2020/06/16.
//  Copyright © 2020 Kana.h. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class SettingViewController: UIViewController {
    
    @IBOutlet weak var displayNameTextField: UITextField!
    
    
    //表示名を変更
    @IBAction func handleChangeButton(_ sender: Any) {
        
        if let displayName = displayNameTextField.text {
            if (displayName.isEmpty) {
                SVProgressHUD.showError(withStatus: "ユーザ名を入力して下さい")
                return
            }
            let user = Auth.auth().currentUser
            if let user = user {
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = displayName
                changeRequest.commitChanges { error in
                    if let error = error {
                        SVProgressHUD.showError(withStatus: "ユーザ名の変更に失敗しました")
                        print("DEBUG_PRINT: " + error.localizedDescription)
                        return
                    }
                    print("DEBUG_PRINT: [displayName = \(user.displayName!)]の設定に成功しました。")
                    SVProgressHUD.showSuccess(withStatus: "ユーザ名を変更しました")
                }
            }
        }
        self.view.endEditing(true)
    }
    
    //ログアウト
    @IBAction func handleLogoutButton(_ sender: Any) {
        try! Auth.auth().signOut()
        let loginViewController = self.storyboard?.instantiateViewController(identifier: "Login")
        self.present(loginViewController!, animated: true, completion: nil)
        tabBarController?.selectedIndex = 0
    }
    
    
    //現在のユーザ名を表示
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let user = Auth.auth().currentUser
        if let user = user {
            displayNameTextField.text = user.displayName
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for ssegue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
