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
        checkAuthorization()
    }

    @IBAction func logOut(_ sender: Any) {
        
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            self.selectedIndex = 0
            checkAuthorization()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
    }
    
    private func checkAuthorization() {
        if Auth.auth().currentUser == nil{
            self.present(Helper.getViewControllerBy(id: StoryBoardIDs.LOGIN), animated: true, completion: nil)
        }
    }
}
