//
//  LoginControllerViewController.swift
//  VideoAR
//
//  Created by Ninja on 11/2/18.
//  Copyright © 2018 Ninja. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import JGProgressHUD

typealias loginHandler = (_ status: LoginStatusCodes) -> Void


class LoginController: UIViewController {

    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    lazy var db = Firestore.firestore()
    var dimissGesture: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userNameField.delegate = self
        passwordField.delegate = self
        dimissGesture = UITapGestureRecognizer(target: self, action: #selector(LoginController.tapToDismissKeyboard(gesture:)))
        self.view.addGestureRecognizer(dimissGesture)
    }
    
    @IBAction func performLogin(_ sender: UIButton) {
        self.view.endEditing(true)
        self.view.isUserInteractionEnabled = false
        
        if validateTextFields() {
            //do Login stuff
            var hud = AlertHelper.showAlert(of: AlertStatus.Loading)
            hud.show(in: self.view)
            doLogin(email: self.userNameField.text!, password: self.passwordField.text!) { (status) in
                self.view.isUserInteractionEnabled = true
                hud.dismiss()
                if status == LoginStatusCodes.LoginSuccess {
                    self.saveToDB(name: String(self.userNameField.text!.split(separator: "@").first!))
                }
                else {
                    //show error
                    hud = AlertHelper.showAlert(of: AlertStatus.Failure)
                    hud.show(in: self.view)
                    hud.dismiss(afterDelay: DELAY_TIME)
                }
            }
        }
    }
    
    fileprivate func validateTextFields() -> Bool {
        if userNameField.text?.count == 0 || passwordField.text?.count == 0 {
            print("One/More TextFields is empty!")
            return false
        }
        return true
    }
}

// TextField delegates
extension LoginController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    @objc func tapToDismissKeyboard(gesture: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        var adjustedFrame = self.view.frame
        adjustedFrame.origin.y -= 30
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.view.frame = adjustedFrame
        }, completion: nil)
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        var adjustedFrame = self.view.frame
        adjustedFrame.origin.y += 30
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.view.frame = adjustedFrame
        }, completion: nil)
    }
}


// Firebase Login Helper
extension LoginController {
    private func doLogin(email: String, password: String, completionHandler: @escaping loginHandler) {
        //Call Firebase
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                if (error! as NSError).userInfo["error_name"] as! String == "ERROR_USER_NOT_FOUND" {
                    self.createUser(with: email, password: password
                        , createCompletionHandler: { (status) in
                            completionHandler(status)
                    })
                }
                else {
                    completionHandler(LoginStatusCodes.LoginFailed)
                }
            }
            else {
                guard let _ = user else {
                    completionHandler(LoginStatusCodes.LoginFailed)
                    return
                }
                completionHandler(LoginStatusCodes.LoginSuccess)
            }
        }
    }
    
    private func createUser(with email:String, password: String, createCompletionHandler: @escaping loginHandler) {
        // Call Firebase
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            guard let _ = user else {
                createCompletionHandler(LoginStatusCodes.LoginFailed)
                return
            }
            createCompletionHandler(LoginStatusCodes.LoginSuccess)
        }
    }
    
    private func saveToDB(name: String) {
        db.collection("users").document(name).setData([
            "name": "\(name)"
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
            }
    }
}




