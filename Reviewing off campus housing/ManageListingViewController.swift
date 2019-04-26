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
    
    public static let shared = ReviewState()
}

class ManageListingViewController: UIViewController, UITableViewDelegate,  UITableViewDataSource{
    
    let date = Date()
    let formatter = DateFormatter()
    
    @IBOutlet weak var reviewTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        showReviews()
        // Do any additional setup after loading the view.
    }
    
    func showReviews(){
        print(AdminState.shared.add[AdminState.shared.row])
        let docRef = db.collection("listings").document(AdminState.shared.add[AdminState.shared.row])
        docRef.getDocument { (document, error) in
            if let document = document, document.exists { // go through the listings database
                
                //let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                //print("Document data: \(dataDescription)")
                
                // retrieve database values for a listing (address, landord, rent, and its reviews)
                var address = document.get("address") as? String ?? ""
                let landlordName = document.get("landlordName") ?? "Leasing manager unavailable"
                let getRent = document.get("rent") as? String ?? ""
                let review = document.get("reviews") as! NSDictionary
                
                // this is the array that the reviews get put into for the table view to read from. it's global.
                ReviewState.shared.arr = []
                
                //Retreiving values from map of maps (reviews)
                //Also! make sure all fields in map are present and valid to present fatal errors. (like comments, rating, isAnon, etc all must be present)
                
                for (reviewer, reviewMap) in review { // the "reviews" map for a listing contains another map: (key = reviewer, value = reviewMap)
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
                    
                    reviewString += "\n\"" + comments + "\"\n\n"
                    
                    reviewString += "Would live again? " + ( willLiveAgain ? ("Yes\n\n") : ("No\n\n") )
                    
                    reviewString += ( lRating == nil ? ("") : (String(format: "Location — %.1f\n", lRating!)) )
                        + ( aRating == nil ? ("") : (String(format: "Amenities — %.1f\n", aRating!)) )
                        + ( mRating == nil ? ("") : (String(format: "Management — %.1f\n", mRating!)) )
                        + String(format: "Overall Rating — %.1f\n", rating)
                        + "\n"
                    
                    
                    
                    let docRef = db.collection("Users").document(reviewer)
                    docRef.getDocument { (document, error) in
                        if let document = document, document.exists {
                            let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                            print("Document data: \(dataDescription)")
                            let firstName = document.get("First Name") as? String ?? reviewer
                            let lastName = document.get("Last Name") as? String ?? " "
                            let lName = String(lastName.first!)
                            
                            reviewString += ( isEdited ? ("Last edited ") : ("Posted ") ) + "by "
                            reviewString += ( isAnonymous ? ("anonymous") : (firstName + " " + lName + ".") )
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewContent")
        cell?.textLabel!.numberOfLines = 0
        cell?.textLabel!.lineBreakMode = .byWordWrapping
        cell?.textLabel?.textColor = UIColor.black
        cell?.textLabel!.font = UIFont.systemFont(ofSize: 12.0)
        let text = ReviewState.shared.arr[indexPath.row]
        cell?.textLabel?.text = text
        
        return cell!
    }

    
}
