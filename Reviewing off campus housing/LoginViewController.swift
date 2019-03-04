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

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
   
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passText: UITextField!
    @IBOutlet weak var signInSelect: UISegmentedControl!
    @IBOutlet weak var signInButton: UIButton!
    var isSignIn:Bool = true
    
    @IBAction func signInChange(_ sender: UISegmentedControl) {
        isSignIn = !isSignIn
        if isSignIn{
            signInButton.setTitle("Sign In", for: .normal)
        }
        else {
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
