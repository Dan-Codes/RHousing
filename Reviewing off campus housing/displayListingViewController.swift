//
//  displayListingViewController.swift
//  Reviewing off campus housing
//
//  Created by Daniel Li on 4/2/19.
//  Copyright © 2019 housing. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import Cosmos

public class arr {
    // global stuff
    // arr.shared.reviewArr
    
    var reviewArr:[String] = []
    public static let shared = arr()
}



class displayListingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // adding a comment here from kevin
    
    var AverageRating:Double = 0
    var countReviews:Double = 0
    var averageLocation:Double = 0.0
    var averageManagement:Double = 0.0
    var averageAmenities:Double = 0.0
    var countNewListings:Double = 0.0
    
    var info:String = ""
    var Em:String = ""
    var dollarSign = "$"
    
    let date = Date()
    let formatter = DateFormatter()
    
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var AddressLabel: UILabel!
    @IBOutlet weak var landlordLabel: UILabel!
    @IBOutlet weak var avgRating: UILabel!
    @IBOutlet weak var displayAvgRating: CosmosView!
    @IBOutlet weak var rentTitle: UILabel!
    @IBOutlet weak var locationTitle: UILabel!
    @IBOutlet weak var managementTitle: UILabel!
    @IBOutlet weak var amenitiesTitle: UILabel!
    @IBOutlet weak var displayRent: UILabel!
    @IBOutlet weak var rating1: UILabel!
    @IBOutlet weak var rating2: UILabel!
    @IBOutlet weak var rating3: UILabel!
    @IBOutlet weak var reviewTable: UITableView!
    
    
    
    @IBAction func unwindToDsiplay(segue: UIStoryboardSegue) {}


    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        // This is for auto-refresh (after writing a review). Even w/o writing a review, it still runs to show the reviews.
        db.collection("listings").document(info)
            .addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return }
                guard document.data() != nil else {
                    print("Document data was empty.")
                    return }
            
                
                self.showReviews() // where the juicy stuf happens
        }
    } //  end of viewDidLoad
    
    func showReviews(){
        
        let docRef = db.collection("listings").document(info)
        
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
                arr.shared.reviewArr = []
                
                // initialization of values for rating values
                self.AverageRating = 0
                self.countReviews = 0
                self.averageLocation = 0.0
                self.averageManagement = 0.0
                self.averageAmenities = 0.0
                self.countNewListings = 0.0
                
                self.rentTitle.font = UIFont.boldSystemFont(ofSize: self.rentTitle.font.pointSize)
                
                
                //Retreiving values from map of maps (reviews)
                //Also! make sure all fields in map are present and valid to present fatal errors. (like comments, rating, isAnon, etc all must be present)
                
                for (reviewer, reviewMap) in review { // the "reviews" map for a listing contains another map: (key = reviewer, value = reviewMap)
                    var reviewString = "" // the string that each review gets parsed into. initialized blank for each review.
                    
                    // get values of a review from the reviewMap
                    let reviewer = reviewer as! String
                    let reviewMap = reviewMap as! NSDictionary // potential problem if nothing in reviewMap? (like a empty review map)
                    let comments = reviewMap.value(forKey: "comments") as! String
                    let rating = reviewMap.value(forKey: "rating") as! Float
                    let isAnonymous = reviewMap.value(forKey: "isAnonymous") as! Bool
                    let isEdited = reviewMap.value(forKey: "isEdited") as? Bool ?? false
                    let willLiveAgain = reviewMap.value(forKey: "willLiveAgain") as! Bool
                    let timestamp = reviewMap.value(forKey: "timeStamp") as? Timestamp ?? Timestamp(date: Date.init(timeInterval: -9999999999, since: Date()))
                    // error handler for no timestamp is literally going 999999999 seconds before current time.
                    
                    let lRating = reviewMap.value(forKey: "locationRating") as? Double
                    let mRating = reviewMap.value(forKey: "managementRating") as? Double
                    let aRating = reviewMap.value(forKey: "amenitiesRating") as? Double

                    // calculation of average ratings
                    if (lRating != nil && mRating != nil && aRating != nil) {
                        self.countNewListings = self.countNewListings + 1
                        
                        self.averageLocation = self.averageLocation + lRating!
                        self.averageManagement = self.averageManagement + mRating!
                        self.averageAmenities = self.averageAmenities + aRating!
                    }
                    
                    self.AverageRating = self.AverageRating + Double(rating)
                    self.countReviews = self.countReviews + 1
                    
                    // adding the review info for the review into the string
                    reviewString += (isAnonymous ? "[This reviewer has made their review anonymous.]\n\n" : "Reviewer: " + String(reviewer) + "\n\n")

                    reviewString += "Overall Rating: " + String(format: "%.1f",rating) + "\n"
                    reviewString += "Amenities Rating: " + (aRating == nil ? "N/A" : String(format: "%1.f",aRating!)) + "\n"
                    reviewString += "Management Rating: " + (mRating == nil ? "N/A" : String(format: "%1.f",mRating!)) + "\n"
                    reviewString += "Location Rating: " + (lRating == nil ? "N/A" : String(format: "%1.f",lRating!)) + "\n"
                    
                    reviewString += "\nComments: \n" + comments + "\n\n"
                    reviewString += "Would live again? " + (willLiveAgain ? "Yes" : "No")
                    
                    self.formatter.dateFormat = "MM/dd/yyyy"
                    reviewString += "\n\n[This review " + (isEdited ? "last edited on: " : "was written on: ") + (self.formatter.string(from: timestamp.dateValue())) + "]"
                    
                    // appending to the array of strings.
                    arr.shared.reviewArr.append(reviewString)
                    
                } // end for loop
                print("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")
                print(address.split(separator: " "))
                var count = 0
                var address1:String = ""
                for str in address.split(separator: " "){
                    if (str.last == ","){
                        break
                    }
                    address1.append(contentsOf: str)
                    address1.append(contentsOf: " ")
                    count+=1
                }
                self.label.text = (address1) // label for address
                self.label2.text = (landlordName as! String) // label for landlord
                
                if getRent.first == "$"{self.displayRent.text = getRent}
                else{
                self.displayRent.text = (self.dollarSign + "\(getRent)") // label for rent
                }
                
                
                if (self.countReviews != 0) {
                    let avgrate = (self.AverageRating/self.countReviews)
                    self.avgRating.text = String(format: "%.1f", avgrate)
                    
                    self.displayAvgRating.settings.updateOnTouch = false
                    self.displayAvgRating.settings.fillMode = .precise
                    self.displayAvgRating.rating = avgrate
                    
                } // end if
                else{
                    self.avgRating.text = "N/A"
                }
                


                
                if (self.countNewListings != 0) {
                    let avgrate = (self.averageLocation/self.countNewListings)
                    self.rating1.text = String(format: "%.1f", avgrate)
                    
                    let avgrate2 = (self.averageManagement/self.countNewListings)
                    self.rating2.text = String(format: "%.1f", avgrate2)
                    
                    let avgrate3 = (self.averageAmenities/self.countNewListings)
                    self.rating3.text = String(format: "%.1f", avgrate3)
                }
                else{
                    self.rating1.text = ""
                    self.rating2.text = ""
                    self.rating3.text = ""
                }
                
            } // end if document exists
                
            else { print("Document does not exist") } // end else
            
            // this line of code is critical! it makes sure the table view updates.
            self.reviewTable.reloadData()
            
        } // end docRef.getDocument
        
        reviewTable.dataSource = self // not sure if this line is necessary. it seems to work with or without.
        
    } // end showReviews
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.shared.reviewArr.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // WANT TO IMPLEMENT:
        // if there are no reviews, don't display a blank table. rather, display a message "there are currently no reviews for this listing at this time."
        /* https://stackoverflow.com/questions/28532926/if-no-table-view-results-display-no-results-on-screen */
        // (maybe implement: if there are some reviews, but not enough to fit whole section, then table size should only be as big as necessary.)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel!.numberOfLines = 0
        cell?.textLabel!.lineBreakMode = .byWordWrapping
        cell?.textLabel!.font = UIFont.systemFont(ofSize: 14.0)
        cell?.textLabel?.textColor = UIColor.white
        let text = arr.shared.reviewArr[indexPath.row]
        cell?.textLabel?.text = text
        
        return cell!
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1

    }
    
    @IBAction func deleteReview(_ sender: UIButton) {
        let user = Auth.auth().currentUser
        if let user = user {
            // The user's ID, unique to the Firebase project.
            // Do NOT use this value to authenticate with your backend server,
            // if you have one. Use getTokenWithCompletion:completion: instead.
            
            let email = user.email
            Em = email!
            
        } // end if
        
        let alert = UIAlertController(title: "Are you sure you want to delete your review of this property?", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: {(action) in print("Hello")}))

        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {(action) in
            let docPropertyRef = db.collection("listings").document(self.info)
            let propertyfp = FieldPath(["reviews", self.Em])
            let docUserRef = db.collection("Users").document(self.Em)
            let userfp = FieldPath(["Review History", self.info])
            
            docPropertyRef.updateData([propertyfp : FieldValue.delete()])
            docUserRef.updateData([userfp : FieldValue.delete()])
        }))
        self.present(alert, animated: true)
        return;
    }
    
    @IBAction func reviewListing(_ sender: UIButton) {
        let user = Auth.auth().currentUser
        if let user = user {
            // The user's ID, unique to the Firebase project.
            // Do NOT use this value to authenticate with your backend server,
            // if you have one. Use getTokenWithCompletion:completion: instead.
            
            let email = user.email
            Em = email!
            
        } // end if
        
        performSegue(withIdentifier: "listingToWrite", sender: self)
        
        let docRef = db.collection("listings").document(info)
        docRef.getDocument { (document,error) in
            if let document = document, document.exists {
                var emailExists:Bool = false
                let review = document.get("reviews") as! NSDictionary
                
                for (reviewer, _) in review {
                    let reviewer = reviewer as! String
                    if (reviewer == self.Em) {
                        emailExists = true
                    }
                } // end for lop
                
                if (emailExists) {
                    let alert = UIAlertController(title: "Warning", message: "You have already rated this property before. If you post another review, your previous review will be overwritten.", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Got it!", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                    
                } // end if
            } // end if let
        } // end getDocument
    } // end reviewListing func
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is WriteReviewViewController
        {
            let vc = segue.destination as? WriteReviewViewController
            vc?.info = info
        }
        if segue.destination is ReportViewController
        {
            let vc = segue.destination as? ReportViewController
            vc?.str = info
        }    }
    
    
    @IBAction func reportProblem(_ sender: UIButton) {
        performSegue(withIdentifier: "displayToReport", sender: self)
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
