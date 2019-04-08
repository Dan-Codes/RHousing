//
//  LoginViewController.swift
//  Reviewing off campus housing
//
//  Created by Justin Tang on 3/2/19.
//  Copyright © 2019 housing. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseUI


extension UIViewController{
    func hideKeyboardWhenTap(){
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKey))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKey(){
        view.endEditing(true)
    }
}

class LoginViewController: UIViewController, UITextFieldDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailText.delegate = self
        passText.delegate = self
        firstName.delegate = self
        lastName.delegate = self
        
        self.hideKeyboardWhenTap()
        
        // Do any additional setup after loading the view.
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
   
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passText: UITextField!
    @IBOutlet weak var signInSelect: UISegmentedControl!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    
   
    var isSignIn:Bool = true
    
    @IBAction func signInChange(_ sender: UISegmentedControl) {
        isSignIn = !isSignIn
        if isSignIn{
            signInButton.setTitle("Sign In", for: .normal)
            firstName.isHidden = true
            lastName.isHidden = true
        }
        else {
            firstName.isHidden = false
            lastName.isHidden = false
            signInButton.setTitle("Register", for: .normal)
        }
    }
    
    @IBAction func signIn(_ sender: UIButton) {
        //check if signed in or register
        if isSignIn{
            //sign in
            Auth.auth().signIn(withEmail: emailText.text!, password: passText.text!) { [weak self] user, error in
                //guard let strongSelf = self else { return }
                if user != nil{
                self?.performSegue(withIdentifier: "goHome", sender: self)
                }
                else{
                    return;
                    //error
                }
                }
            
        }
        else{
            //Register
            Auth.auth().createUser(withEmail: emailText.text!, password: passText.text!) { authResult, error in
                if authResult != nil{
                    //go Home
                    self.performSegue(withIdentifier: "goHome", sender: self)
                    
//                    var ref: DocumentReference? = nil
//                    ref = db.collection("Users").addDocument(data: [
//                        "Email": self.emailText.text!,
//                        "First Name" : self.firstName.text!,
//                        "Last Name" : self.lastName.text!
//                    ]) { err in
//                        if let err = err {
//                            print("Error adding document: \(err)")
//                        } else {
//                            print("Document added with ID: \(ref!.documentID)")
//                        }
//                    }
                    
                    db.collection("Users").document(self.emailText.text!).setData([
                        "Email": self.emailText.text!,
                        "First Name" : self.firstName.text!,
                        "Last Name" : self.lastName.text!
                    ]) { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                        } else {
                            print("Document successfully written!")
                        }
                    }
                }
                else{
                    //error
                }
            }        }
    }
}

extension LoginViewController: FUIAuthDelegate{
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {

        //check error
        if error != nil {
            //log error
            return
        }

        performSegue(withIdentifier: "goHome", sender: self)
    }
}
