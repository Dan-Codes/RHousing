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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        print("EMAIL")
        print(emailID)
        let vc = segue.destination as? SecondViewController
        vc?.email = emailID
        let vc2 = segue.destination as? FirstViewController
        vc2?.emailID = emailID
    }

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
   
    var emailID:String = ""
    var isSignIn:Bool = true
    
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passText: UITextField!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!

    @IBAction func signInButton(_ sender: UIButton) {
        // check if signed in or register
        if isSignIn {
            
            // sign in
            Auth.auth().signIn(withEmail: emailText.text!, password: passText.text!) { [weak self] user, error in
                
                // guard let strongSelf = self else { return }
                if user != nil {
                    self?.emailID = self?.emailText.text ?? ""
                    self?.performSegue(withIdentifier: "goHome", sender: self)
                    
                } else {
                    let alert = UIAlertController(title: "Invalid input", message: "Your email and password do not match your account credentials. If you do not have an account, please sign up.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                    self!.present(alert, animated: true)
                    return;
                    //error
                }
                
            }
            
        }
            
        else {
            
            // register new user
            Auth.auth().createUser(withEmail: emailText.text!, password: passText.text!) { authResult, error in
                
                let last7 = String(self.emailText.text!.suffix(7))
                
                if authResult != nil && last7 == "syr.edu" {
                    
                    // goHome
                    self.performSegue(withIdentifier: "goHome", sender: self)
                    
                    db.collection("Users").document(self.emailText.text!).setData([
                        "Email": self.emailText.text!,
                        "DarkMode" : true,
                        "Admin" : false,
                        "First Name" : self.firstName.text!,
                        "Last Name" : self.lastName.text!
                    ]) { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                        } else {
                            print("Document successfully written!")
                        }
                    }
                    
                } else {
                    let alert = UIAlertController(title: "Invalid input", message: "Please make sure you typed a valid SU email and your password is longer than six characters. If you already have an account, click log in.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                    return;
                }
                
            }  // end Auth.auth().createUser()
            
        }  // end else
    }
    
    @IBAction func signInChange(_ sender: UISegmentedControl) {
        isSignIn = !isSignIn
        if isSignIn{
            firstName.isHidden = true
            lastName.isHidden = true
        }
        else {
            firstName.isHidden = false
            lastName.isHidden = false
        }
    }
    
    func getEmail() -> String{
        return emailID
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
