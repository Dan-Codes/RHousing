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
    public var didReview = false
    var reviewArr:[String] = []
    public static let shared = arr()
}



class displayListingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {    
    var AverageRating:Double = 0
    var countReviews:Double = 0
    var averageLocation:Double = 0.0
    var averageManagement:Double = 0.0
    var averageAmenities:Double = 0.0
    var countNewListings:Double = 0.0
    
    var info:String = "" //this is reference to a postal address
    var Em:String = "" //reference to a User email
    var dollarSign = "$"
    
    let date = Date()
    let formatter = DateFormatter()
    
    var listener:ListenerRegistration? = nil
    
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
    @IBOutlet weak var ReviewBG: UIImageView!
    @IBOutlet weak var RentBG: UIImageView!
    
    
    
    @IBAction func unwindToDsiplay(segue: UIStoryboardSegue) {}


    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        // This is for auto-refresh (after writing a review). Even w/o writing a review, it still runs to show the reviews.
        listener = db.collection("listings").document(info)
            .addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return }
                guard document.data() != nil else {
                    print("Document data was empty.")
                    return }
            
                self.view.sendSubviewToBack(self.ReviewBG)
                self.view.sendSubviewToBack(self.RentBG)
                
                self.showReviews() // where the juicy stuf happens
        }
    } //  end of viewDidLoad
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParent {
            listener?.remove()
        }
    }
    
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
                    
                    if (lRating != nil && mRating != nil && aRating != nil) {
                        self.countNewListings  += 1
                        self.averageLocation   += lRating!
                        self.averageManagement += mRating!
                        self.averageAmenities  += aRating! }
                    
                    self.AverageRating += Double(rating)
                    self.countReviews  += 1
                    
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
                    
                    let docRef = db.collection("Users").document(reviewer)
                    docRef.getDocument { (document, error) in
                        if let document = document, document.exists {
                            let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                            // print("Document data: \(dataDescription)")
                            let firstName = document.get("First Name") as? String ?? reviewer
                            let lastName = document.get("Last Name") as? String ?? " "
                            let lName = String(lastName.first!) + "."
                            
                            reviewString += ( isEdited ? ("Last edited ") : ("Posted ") ) + "by "
                            reviewString += ( isAnonymous ? ("Anonymous") : (firstName + " " + lName) )
                            reviewString += " on " + ( self.formatter.string(from: timestamp.dateValue()) ) + "\n"
                            
                            // append to the array of strings
                            
                            arr.shared.reviewArr.append(reviewString)
                            self.reviewTable.reloadData()
                            
                        } else { print("Document does not exist") }
                    }
                    
                } // end for loop
                
                // parsing first part of the address
                var count = 0
                var address1:String = ""
                
                for str in address.split(separator: " "){
                    if (str.last == ",") { break }
                    address1.append(contentsOf: str)
                    address1.append(contentsOf: " ")
                    count+=1 }
                
                self.label.text = (address1) // label for address
                
                self.label2.text = (landlordName as! String) // label for landlord
                
                if getRent.first == "$" {self.displayRent.text = getRent}
                else                    { self.displayRent.text = (self.dollarSign + "\(getRent)") } // label for rent
                
                
                //Calculates average review
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
                


                //Checks if there are any listings. If there are, it calculates average for star ratings
                if (self.countNewListings != 0 ) {
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
        //Setup cells
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel!.numberOfLines = 0
        cell?.textLabel!.lineBreakMode = .byWordWrapping
        cell?.textLabel!.font = UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.ultraLight)
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
            // !!! Use FieldPath instead of using user email directly !!!
            // !!! Because there is a dot in user email which will be recognized as dot notation by firestore!!!
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
        
        
        performSegue(withIdentifier: "listingToWrite", sender: self)
        
        
    } // end reviewListing func
    
    //sends postal address to the other controllers
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
        }
    }
    
    
    @IBAction func reportProblem(_ sender: UIButton) {
        performSegue(withIdentifier: "displayToReport", sender: self)
    }
    
    

} //end of class
