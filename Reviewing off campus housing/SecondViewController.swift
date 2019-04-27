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

var info:String = ""

public class ReviewHistory {
    var reviewHistories:[String] = []
    public var address:[String] = []
    public var tableRow:Int = 0
    public static let shared = ReviewHistory()
}

public class SecState {
    public var darkMode = true
    public static let shared = SecState()
}

class SecondViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var adminCheck:Bool = false
    
    let date = Date()
    let formatter = DateFormatter()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ReviewHistory.shared.reviewHistories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        cell?.textLabel!.numberOfLines = 0
        cell?.textLabel!.lineBreakMode = .byWordWrapping
        cell?.textLabel?.textColor = UIColor.white
        cell?.textLabel!.font = UIFont.systemFont(ofSize: 13.0, weight: UIFont.Weight.ultraLight)
        
        let text = ReviewHistory.shared.reviewHistories[indexPath.row]
        cell?.textLabel?.text = text
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ReviewHistory.shared.tableRow = indexPath.row
        print(ReviewHistory.shared.tableRow)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    var info:String = ""
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
                let user = Auth.auth().currentUser
                if let user = user {
                    // The user's ID, unique to the Firebase project.
                    // Do NOT use this value to authenticate with your backend server,
                    // if you have one. Use getTokenWithCompletion:completion: instead.
                    
                    let email = user.email
                    Em = email!
                    
                } // end if
            ReviewHistory.shared.tableRow = indexPath.row
                let alert = UIAlertController(title: "Are you sure you want to delete your review of this property?", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: {(action) in print("User did not delete review")}))
            
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {(action) in
                    let docPropertyRef = db.collection("listings").document(ReviewHistory.shared.address[ReviewHistory.shared.tableRow])
                    let propertyfp = FieldPath(["reviews", self.Em])
                    let docUserRef = db.collection("Users").document(self.Em)
                    let userfp = FieldPath(["Review History", ReviewHistory.shared.address[ReviewHistory.shared.tableRow]])
                    
                    docPropertyRef.updateData([propertyfp : FieldValue.delete()])
                    docUserRef.updateData([userfp : FieldValue.delete()])
                    print("Review deleted Users")
                    self.reviewHistory.reloadData()
                }))
                self.present(alert, animated: true)
                return;
            }
    }
    

    var Em:String = ""
    
    func showHistory(Em: String) {
        
        let docRef = db.collection("Users").document(Em)
        
        docRef.getDocument { (document, error) in
            
            if let document = document, document.exists {
                
                let reviewHis = document.get("Review History") as? NSDictionary
                ReviewHistory.shared.reviewHistories = []
                ReviewHistory.shared.address = []
                for (property, fields) in reviewHis ?? [:] {
                    
                    var thisReview = ""
                    
                    let fields = fields as! NSDictionary
                    
                    let address             = property as! String
                    let comments            = fields.value(forKey: "comments")          as! String
                    let isAnonymous         = fields.value(forKey: "isAnonymous")       as! Bool
                    let rating              = fields.value(forKey: "rating")            as? Double
                    let willLiveAgain       = fields.value(forKey: "willLiveAgain")     as! Bool
                    let amenitiesRating     = fields.value(forKey: "amenitiesRating")   as? Double
                    let locationRating      = fields.value(forKey: "locationRating")    as? Double
                    let managementRating    = fields.value(forKey: "managementRating")  as? Double
                    let isEdited            = fields.value(forKey: "isEdited")          as? Bool ?? false
                    let timestamp           = fields.value(forKey: "timeStamp")     as? Timestamp ?? Timestamp(date: Date.init(timeInterval: -9999999999, since: Date()))
                    
                    
                    // initialize date format
                    
                    self.formatter.dateFormat = "MM/dd/yyyy"
                    
                    // retrieve only address 1 field from entire address string
                    
                    var count = 0
                    var shortAddress:String = ""
                    
                    for str in address.split(separator: " "){
                        if (str.last == ",") { break }
                        shortAddress.append(contentsOf: " ")
                        shortAddress.append(contentsOf: str)
                        count += 1 }
                    
                    // append each field to string 'thisReview,' to be passed in as a string
                    // and printed out to each table view cell
                    
                    thisReview += "On:" + shortAddress + ":\n\n"
                    
                    thisReview += "\"" + comments + "\"\n\n"
                    
                    thisReview += "Would live again? " + ( willLiveAgain ? ("Yes\n\n") : ("No\n\n") )
                    
                    thisReview += ( locationRating == nil ? ("") : (String(format: "Location — %.1f\n", locationRating!)) )
                                  + ( amenitiesRating == nil ? ("") : (String(format: "Amenities — %.1f\n", amenitiesRating!)) )
                                  + ( managementRating == nil ? ("") : (String(format: "Management — %.1f\n", managementRating!)) )
                                  + String(format: "Overall Rating — %.1f\n", rating ?? "")
                                  + "\n"
                    
                    thisReview += "You " + ( isEdited ? ("last edited ") : ("posted ") ) + "this review, "
                    thisReview += ( isAnonymous ? ("anonymously, ") : ("including your name, ") )
                    thisReview += "on " + ( self.formatter.string(from: timestamp.dateValue()) ) + ".\n"
                    
                    thisReview += "________________________________________________"
                    
                    // append this entire review as a string element to reviewHistories[]
                    
                    ReviewHistory.shared.reviewHistories.append(thisReview)
                    ReviewHistory.shared.address.append(address)
                    
                }  // end reviewHis loop
                
                
            }  // end if document exists
                
            else { print("Document does not exist.") }
            
            // this line of code is critical because it makes sure the table view updates
            self.reviewHistory.reloadData()
            
        }  // end get document
        
        reviewHistory.dataSource = self  // might not be necessary
        
    }  // end function showHistory

    var email:String = ""
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var displayEmail: UILabel!
    @IBOutlet weak var darkModeSelect: UISwitch!
    @IBOutlet weak var reviewHistory: UITableView!
    @IBOutlet weak var googleMapsDarkMode: UIImageView!
    @IBOutlet weak var accountBG: UIImageView!
    @IBOutlet weak var historyBG: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       // tabBarController?.selectedIndex = 1
        
        let user = Auth.auth().currentUser
        if let user = user {
            // The user's ID, unique to the Firebase project.
            // Do NOT use this value to authenticate with your backend server,
            // if you have one. Use getTokenWithCompletion:completion: instead.
            email = user.email!
            db.collection("Users").document(email)
                .addSnapshotListener { documentSnapshot, error in
                    guard let document = documentSnapshot else {
                        print("Error fetching document: \(error!)")
                        return
                    }
                    guard let data = document.data() else {
                        print("Document data was empty.")
                        return
                    }
                    print("Refresh Table View")
                    self.showHistory(Em: self.email)
            }
            
        }
        
        showHistory(Em: email)
        
        // kevin's comment:
        // consider putting the below code into a function? kinda like how showHistory is implemented here, or how I implemented showReviews in displayListings.
        let docRef = db.collection("Users").document(email)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                //print("Document data: \(dataDescription)")
                
                self.adminCheck = (document.get("Admin") as? Bool ?? false)
                let fN = document.get("First Name") ?? ""
                let lN = document.get("Last Name") ?? ""
                self.firstName.text = (fN as! String) + " " + (lN as! String)
                let getEmail = document.get("Email") ?? ""
                self.displayEmail.text = (getEmail as! String)
                let darkModeBool = document.get("DarkMode") as! Bool
                if darkModeBool{
                    self.darkModeSelect.isOn = true
                }
                else{
                    self.darkModeSelect.isOn = false
                }
            } else { print("Document does not exist") }
        }  //  end getDocument
        
        view.sendSubviewToBack(googleMapsDarkMode)
        view.sendSubviewToBack(accountBG)
        view.sendSubviewToBack(historyBG)
        
    }  // end viewDidLoad()

    
   @IBAction func darkMode(_ sender: UISwitch) {
        if sender.isOn {
            SecState.shared.darkMode = true
            AppState.shared.darkMode = true
            let darkModeRef = db.collection("Users").document(email)
            darkModeRef.updateData([
                "DarkMode": true
            ]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
                    //FirstViewController().viewDidLoad()
                }
            }
        }
        else{
            SecState.shared.darkMode = false
            AppState.shared.darkMode = false
            let darkModeRef = db.collection("Users").document(email)
            darkModeRef.updateData([
                "DarkMode": false
            ]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
                    //FirstViewController().viewDidLoad()
                }
            }

    }
    }
    
    
    @IBAction func goAdmin(_ sender: UIButton) {
        if adminCheck{
        performSegue(withIdentifier: "goToAdmin", sender: self)
        }
        else{
            let alert = UIAlertController(title: "Sorry!", message: "You are not authorized to enter admin view.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action -> Void in
                return
            }))
            self.present(alert, animated: true)
            return
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

