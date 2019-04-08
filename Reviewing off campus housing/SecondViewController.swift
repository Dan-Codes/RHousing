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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       // tabBarController?.selectedIndex = 1
        
    }
    
    
    @IBAction func darkMode(_ sender: UISwitch) {
        if !sender.isOn {

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

