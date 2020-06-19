//
//  TabBarController.swift
//  instagram
//
//  Created by 星野　花 on 2020/06/16.
//  Copyright © 2020 Kana.h. All rights reserved.
//

import UIKit
import Firebase

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBar.tintColor = UIColor(red: 0, green: 0.44, blue: 0.9, alpha: 1)
        self.tabBar.barTintColor = UIColor(red: 0.7, green: 0.8, blue: 0.7, alpha: 1)
        self.delegate = self
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        if(viewController is ImageSelectViewController) {
            let imageSelectViewController = storyboard!.instantiateViewController(identifier: "ImageSelect")
            present(imageSelectViewController, animated: true)
            return false
        } else {
            return true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if (Auth.auth().currentUser == nil) {
            let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login")
            self.present(loginViewController!, animated: true, completion: nil)
            
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
    
}
