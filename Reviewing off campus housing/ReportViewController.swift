//
//  ReportViewController.swift
//  Reviewing off campus housing
//
//  Created by Daniel Li on 4/6/19.
//  Copyright © 2019 housing. All rights reserved.
//

import UIKit
import Firebase

class ReportViewController: UIViewController, UITextViewDelegate {
    
    var str:String = ""
    var Em:String = ""
    
    @IBOutlet weak var living: UISwitch!
    @IBOutlet weak var lived: UISwitch!
    @IBOutlet weak var report: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let borderColor : UIColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
        report.layer.borderColor = borderColor.cgColor
        report.layer.borderWidth = 0.5
        report.layer.cornerRadius = 5.0
        report.delegate = self
        report.text = "Some of the information posted for this property is incorrect, I see spam or malicious content in one of the reviews, etc."
        report.textColor = UIColor.lightGray
        // Do any additional setup after loading the view.
        self.hideKeyboardWhenTap()
    }
    

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func textViewDidBeginEditing(_ report: UITextView) {
        if report.textColor == UIColor.lightGray {
            report.text = nil
            report.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ report: UITextView) {
        if report.text.isEmpty {
            report.text = "Some of the information posted for this property is incorrect, I see spam or malicious content in one of the reviews, etc."
            report.textColor = UIColor.lightGray
        }
    }
    
    // from kevin: "Currently live here" should be automatically false if "Lived here before?" is false.
    
    @IBAction func submit(_ sender: UIButton) {
        let time = Timestamp(date: Date())
        
        let user = Auth.auth().currentUser
        if let user = user {
            // The user's ID, unique to the Firebase project.
            // Do NOT use this value to authenticate with your backend server,
            // if you have one. Use getTokenWithCompletion:completion: instead.
            let email = user.email
            Em = email!
            
            print(Em)
            print(str)
        }
        
        
        let docRef = db.collection("Reports").document(str)
        docRef.setData([
            "\(Em)" : [
                "Report" : report.text!,
                "Current Resident" : living.isOn,
                "Past Resident" : lived.isOn,
                "timeStamp" : time
            ]
            ], merge: true)
        { err in
            if let err = err {
                let alert = UIAlertController(title: "Oops!", message: "Your report can't be submitted at this time. Please try again later.", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
                self.present(alert, animated: true)
                print("Error updating document: \(err)")
            } else {
                let alert = UIAlertController(title: "We hear you.", message: "Thank you for your report submission. We have received your issue and will work on it!", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Got it", style: .default, handler: { action -> Void in
                    self.performSegue(withIdentifier: "unwindToDisplay", sender: self)
                }))
                
                self.present(alert, animated: true)
                print("Document successfully updated")
                
            }
        }
        
    }
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
