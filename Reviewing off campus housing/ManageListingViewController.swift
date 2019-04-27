//
//  ManageListingViewController.swift
//  Reviewing off campus housing
//
//  Created by Silin Chen on 4/24/19.
//  Copyright © 2019 housing. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

public class ReviewState {
    public var arr:[String] = []
    public var info:String = ""
    public var a:Int = 0
    public var reviewer:[String] = []
    
    public static let shared = ReviewState()
}

class ManageListingViewController: UIViewController, UITableViewDelegate,  UITableViewDataSource{
    @IBOutlet weak var newRent: UITextField!
    @IBOutlet weak var newLandlord: UITextField!
    
    let date = Date()
    let formatter = DateFormatter()
    
    @IBOutlet weak var reviewTable: UITableView!
    var detach:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ReviewState.shared.arr = []
        print(ReviewState.shared.arr)
        ReviewState.shared.info = AdminState.shared.add[AdminState.shared.row]
        
        let docRef = db.collection("listings").document(ReviewState.shared.info)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists { // go through the listings database
                
                self.newRent.text = document.get("rent") as? String ?? ""
                self.newLandlord.text = document.get("landlordName") as? String ?? ""
            }
        }
    
        let listener = db.collection("listings").document(ReviewState.shared.info)
            .addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return }
                guard document.data() != nil else {
                    print("Document data was empty.")
                    return }
                ReviewState.shared.arr = []
                self.showReviews() // where the juicy stuf happens
                }
        
        // Do any additional setup after loading the view.
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPress.minimumPressDuration = 2.0
        reviewTable.addGestureRecognizer(longPress)
    }
    
    @objc func handleLongPress(sender: UILongPressGestureRecognizer){
        if sender.state == .began {
            let touchPoint = sender.location(in: reviewTable)
            if let indexPath = reviewTable.indexPathForRow(at: touchPoint) {
                print(indexPath)
                // your code here, get the row for the indexPath or do whatever you want
                let alert = UIAlertController(title: "Are you sure you want to delete your review of this property?", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: {(action) in print("Hello")}))
                alert.addAction(UIAlertAction(title: "Confirm", style: .destructive, handler: {(action) in
                    
                    print(ReviewState.shared.reviewer[indexPath.row])
                            let docPropertyRef = db.collection("listings").document(ReviewState.shared.info)
                            let propertyfp = FieldPath(["reviews", ReviewState.shared.reviewer[indexPath.row]])
                            let docUserRef = db.collection("Users").document(ReviewState.shared.reviewer[indexPath.row])
                            let userfp = FieldPath(["Review History", ReviewState.shared.info])
                    
                            docPropertyRef.updateData([propertyfp : FieldValue.delete()])
                            docUserRef.updateData([userfp : FieldValue.delete()])
                    return;
                }))
                self.present(alert, animated: true)
            }
        }
    }
    
    func showReviews(){
        ReviewState.shared.arr = []
        let docRef = db.collection("listings").document(ReviewState.shared.info)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists { // go through the listings database
                
                //let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                //print("Document data: \(dataDescription)")
                
                // retrieve database values for a listing (address, landord, rent, and its reviews)
                let review = document.get("reviews") as! NSDictionary
                
                //Retreiving values from map of maps (reviews)
                //Also! make sure all fields in map are present and valid to present fatal errors. (like comments, rating, isAnon, etc all must be present)
                ReviewState.shared.arr = []
                var a:Int = 0
                for (reviewer, reviewMap) in review {// the "reviews" map for a listing contains another map: (key = reviewer, value = reviewMap)
                    a += 1
                    print(a)
                    var reviewString = "" // the string that each review gets parsed into. initialized blank for each review.
                    
                    // get values of a review from the reviewMap
                    let reviewer = reviewer as! String
                    let reviewMap = reviewMap as! NSDictionary // potential problem if nothing in reviewMap? (like a empty review map)
                    let comments = reviewMap.value(forKey: "comments") as? String ?? "No review in database"
                    let rating = reviewMap.value(forKey: "rating") as? Float ?? 0
                    let isAnonymous = reviewMap.value(forKey: "isAnonymous") as? Bool ?? false
                    let isEdited = reviewMap.value(forKey: "isEdited") as? Bool ?? false
                    let willLiveAgain = reviewMap.value(forKey: "willLiveAgain") as? Bool ?? false
                    let timestamp = reviewMap.value(forKey: "timeStamp") as? Timestamp ?? Timestamp(date: Date.init(timeInterval: -9999999999, since: Date()))
                    
                    
                    
                    // error handler for no timestamp is literally going 999999999 seconds before current time.
                    
                    let lRating = reviewMap.value(forKey: "locationRating") as? Double
                    let mRating = reviewMap.value(forKey: "managementRating") as? Double
                    let aRating = reviewMap.value(forKey: "amenitiesRating") as? Double
                    
                    // calculate average ratings
                    
                   
                    
                    
                    // add the review info for the review into the string
                    
                    self.formatter.dateFormat = "MM/dd/yyyy"
                    
                    if (comments == "This user has decided not to write a review") { reviewString += "\n"   + comments + ".\n\n"  }
                    else                                                           { reviewString += "\n\"" + comments + "\"\n\n" }
                    
                    reviewString += "Would live again? " + ( willLiveAgain ? ("Yes\n\n") : ("No\n\n") )
                    
                    reviewString += ( lRating == nil ? ("") : (String(format: "Location: %.1f\n", lRating!)) )
                        + ( aRating == nil ? ("") : (String(format: "Amenities: %.1f\n", aRating!)) )
                        + ( mRating == nil ? ("") : (String(format: "Management: %.1f\n", mRating!)) )
                        + String(format: "Overall Rating: %.1f\n", rating)
                        + "\n"
                    
                    ReviewState.shared.reviewer.append(reviewer)
                    
                    let docRef = db.collection("Users").document(reviewer)
                    docRef.getDocument { (document, error) in
                        if let document = document, document.exists {
                            let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                            
                            let firstName = document.get("First Name") as? String ?? reviewer
                            let lastName = document.get("Last Name") as? String ?? " "
                            let lName = String(lastName.first!) + "."
                            
                            reviewString += ( isEdited ? ("Last edited ") : ("Posted ") ) + "by "
                            reviewString += ( isAnonymous ? ("Anonymous") : (firstName + " " + lName) )
                            reviewString += " on " + ( self.formatter.string(from: timestamp.dateValue()) ) + "\n"
                            
                            // append to the array of strings
                            
                            ReviewState.shared.arr.append(reviewString)
                            self.reviewTable.reloadData()
                        } else {
                            print("Document does not exist")
                        }
                    }
                    
                } // end for loop
                

            } // end if document exists
                
            else { print("Document does not exist") } // end else
            
            // this line of code is critical! it makes sure the table view updates.
            self.reviewTable.reloadData()
            ReviewState.shared.arr = []
        } // end docRef.getDocument
        
        reviewTable.dataSource = self // not sure if this line is necessary. it seems to work with or without.
        
    } // end showReviews

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return arr.shared.reviewArr.count
        return ReviewState.shared.arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // WANT TO IMPLEMENT:
        // if there are no reviews, don't display a blank table. rather, display a message "there are currently no reviews for this listing at this time."
        /* https://stackoverflow.com/questions/28532926/if-no-table-view-results-display-no-results-on-screen */
        // (maybe implement: if there are some reviews, but not enough to fit whole section, then table size should only be as big as necessary.)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewContent", for: indexPath)
        cell.textLabel!.numberOfLines = 0
        cell.textLabel!.lineBreakMode = .byWordWrapping
        cell.textLabel?.textColor = UIColor.white
        cell.textLabel!.font = UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.ultraLight)
        let text = ReviewState.shared.arr[indexPath.row]
        cell.textLabel?.text = text
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor(red: 129.0/255.0, green: 10.0/255.0, blue: 28.0/255.0, alpha: 1.0)
        cell.selectedBackgroundView = bgColorView
        
        return cell
    }

    @IBAction func submit(_ sender: UIButton) {
        let docRef = db.collection("listings").document(ReviewState.shared.info)
        docRef.updateData([
            "rent": newRent.text!,
            "landlordName" : newLandlord.text!
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
                let alert = UIAlertController(title: "Success", message: "You have successfully updated the database data for this property.", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Got it", style: .default, handler: { action -> Void in
                    //self.performSegue(withIdentifier: "unwindToListingAdmin", sender: self)
                    print(ReviewState.shared.arr)
                }))
                self.present(alert, animated: true)
            }
        }
    }
}
