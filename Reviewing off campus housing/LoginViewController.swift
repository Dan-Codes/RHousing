//
//  LoginViewController.swift
//  Reviewing off campus housing
//
//  Created by Justin Tang on 3/2/19.
//  Copyright © 2019 housing. All rights reserved.
//

import UIKit
import FirebaseUI

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginTap(_ sender: UIButton) {
        
        let authUI = FUIAuth.defaultAuthUI()
        
        guard authUI != nil else {
            return
        }
        
        //set ourselves as delegate
        authUI?.delegate = self
        
        //get reference to auth UI view controller
        let authViewController = authUI!.authViewController()
        
        //show
        present(authViewController, animated: true, completion: nil)
    
    }
    
//    @IBAction func Login(_ sender: UIButton) {
//        let authUI = FUIAuth.defaultAuthUI()
//
//        guard authUI != nil else {
//            return
//            }
//
//        //set ourselves as delegate
//        authUI?.delegate = self
//
//        //get reference to auth UI view controller
//        let authViewController = authUI!.authViewController()
//
//        //show
//        present(authViewController, animated: true, completion: nil)
//    }
    

    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
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
