//
//  RootTabController.swift
//  VideoAR
//
//  Created by Ninja on 11/2/18.
//  Copyright © 2018 Ninja. All rights reserved.
//

import UIKit
import Firebase

class RootTabController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool) {
    }

    @IBAction func logOut(_ sender: Any) {
        
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            self.selectedIndex = 0
            AuthenticationHelper.loadVC()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
    }
}
