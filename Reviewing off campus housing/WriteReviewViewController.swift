//
//  WriteReviewViewController.swift
//  Reviewing off campus housing
//
//  Created by Daniel Li on 4/4/19.
//  Copyright © 2019 housing. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth


class WriteReviewViewController: UIViewController, UITextFieldDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        comment.delegate = self as? UITextViewDelegate
        let borderColor : UIColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
        comment.layer.borderColor = borderColor.cgColor
        comment.layer.borderWidth = 0.5
        comment.layer.cornerRadius = 5.0
        
        self.hideKeyboardWhenTap()  
        // Do any additional setup after loading the view.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    @IBOutlet weak var anonymous: UISwitch!
    @IBOutlet weak var liveAgain: UISwitch!
    @IBOutlet weak var rating: UISlider!
    @IBOutlet weak var comment: UITextView!
    @IBOutlet weak var ratingValue: UILabel!
    @IBAction func slideRate(_ sender: UISlider) {
        ratingValue.text = String(format: "%.1f", sender.value)
        //ratingValue.setValue(Float(), forKey: String(format: "%.1f", sender.value))
        if sender.value < 2.5 {
            liveAgain.setOn(false, animated: true)
        }
        else{
            liveAgain.setOn(true, animated: true)
        }
    }
    
    
    
    
    @IBAction func submit(_ sender: UIButton) {
        performSegue(withIdentifier: "writeToHome", sender: self)
        let time = Timestamp(date: Date())
        print(time)
        let user = Auth.auth().currentUser
        if let user = user {
            // The user's ID, unique to the Firebase project.
            // Do NOT use this value to authenticate with your backend server,
            // if you have one. Use getTokenWithCompletion:completion: instead.
            let email = user.email
            Em = email!
            
            print(Em)
            print(info)
            // ...
            
        }
        
        var docRef = db.collection("listings").document(info)
        docRef.setData([
            "reviews" : [
              "\(Em)" : [
                    "comments" : comment.text!,
                    "isAnonymous" : anonymous.isOn,
                    "isEdited" : false,
                    "rating" : rating.value,
                    "willLiveAgain" : liveAgain.isOn,
                    "timeStamp" : time
                    ]
                ]
        ], merge: true)
            { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    var info:String = ""
    var Em:String = ""
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


