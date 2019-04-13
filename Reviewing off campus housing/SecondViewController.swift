//
//  SecondViewController.swift
//  Reviewing off campus housing
//
//  Created by Silin Chen on 3/1/19.
//  Copyright © 2019 housing. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseUI

class SecondViewController: UIViewController {

    var email:String = ""
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       // tabBarController?.selectedIndex = 1
        print(email)
    }
    
    
    
    @IBAction func darkMode(_ sender: UISwitch) {
        if !sender.isOn {
//            db.collection("Users").document(email).setData([
//                "DarkMode": true
//            ]) { err in
//                if let err = err {
//                    print("Error writing document: \(err)")
//                } else {
//                    print("Document successfully written!")
//                }
//            }
//        }
//        else{
//            db.collection("Users").document(email).setData([
//                "DarkMode": false
//            ]) { err in
//                if let err = err {
//                    print("Error writing document: \(err)")
//                } else {
//                    print("Document successfully written!")
//                }
//        }
//
    }
    }
    
    @IBAction func logoutButton(_ sender: UIButton) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            performSegue(withIdentifier: "logout2", sender: (Any).self)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }

    }
    

}

