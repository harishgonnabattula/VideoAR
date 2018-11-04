//
//  DownloadAssestsControllerTableViewController.swift
//  VideoAR
//
//  Created by Ninja on 11/3/18.
//  Copyright © 2018 Ninja. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Firebase
import JGProgressHUD

class DownloadAssestsController: UITableViewController {

    
    lazy var db = Firestore.firestore()
    var dataSource = [QueryDocumentSnapshot]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUsers()
        self.tableView.tableFooterView = UIView()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dataSource.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "users", for: indexPath)
        cell.textLabel?.text = dataSource[indexPath.row].data()["name"] as? String
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let name = dataSource[indexPath.row].data()["name"] as! String
        downloadAssests(name: name)
    }
}

// Media Download Helper
extension DownloadAssestsController {
    
    // Fetch list of users of our app
    private func fetchUsers() {
        db.collection("users").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.dataSource = querySnapshot!.documents
            }
            self.tableView.reloadData()
        }
    }
    
    // Download Assests
    private func downloadAssests(name: String) {
        let storage = Storage.storage()
        // Create a root reference
        let storageRef = storage.reference()

        var hud = AlertHelper.showAlert(of: .Uploading, with: "Downloading")
        hud.show(in: self.view)
        
        for fileName in ["marker.jpg", "marker.mov"] {
            
            // Create a reference to 'images/marker.jpg or mov'
            let markerRef = storageRef.child(name + "/" + fileName)
            
            // File Manager
            let fileManager = FileManager.default
            do {
                let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
                let fileURL = documentDirectory.appendingPathComponent(fileName)
                // Download to the local filesystem
                let _ = markerRef.write(toFile: fileURL) { url, error in
                    
                    if let _ = error {
                        hud.dismiss()
                        hud = AlertHelper.showAlert(of: .Failure, info: "Failed to download Media Files")
                        hud.show(in: self.view)
                        hud.dismiss(afterDelay: DELAY_TIME)
                    } else {
                        // Local file URL is returned
                        if fileName.contains(".jpg") {
                            Assests.setImgUrl(url: url)
                        }
                        else {
                            hud.dismiss()
                            hud = AlertHelper.showAlert(of: .Success)
                            hud.show(in: self.view)
                            hud.dismiss(afterDelay: DELAY_TIME)
                            
                            Assests.setVidUrl(url: url)
                        }
                    }
                }
            } catch {
                print(error)
            }
        }
    }
}
