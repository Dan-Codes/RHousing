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

class displayListingViewController: UIViewController {

    // adding a comment here from kevin
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var AddressLabel: UILabel!
    @IBOutlet weak var landlordLabel: UILabel!
    @IBOutlet weak var rentPriceLabel: UILabel!
    @IBOutlet weak var avgRating: UILabel!
    var AverageRating:Double = 0
    var countReviews:Double = 0
    
    
    
    @IBOutlet weak var scrollReview: UIScrollView!
    @IBOutlet weak var reviewText: UITextView!
    
    @IBAction func unwindToDsiplay(segue: UIStoryboardSegue) {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AddressLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        landlordLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        rentPriceLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        
        scrollReview.contentLayoutGuide.bottomAnchor.constraint(equalTo: label.bottomAnchor).isActive = true

        // Do any additional setup after loading the view.

        let docRef = db.collection("listings").document(info)

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {

                //let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                //print("Document data: \(dataDescription)")

                let address = document.get("address") ?? ""
                let rent = (document.get("rent"))
                let landlordName = document.get("landlordName") ?? "No Landlord Information"
                
                 //COMMENT THIS SECTION OF CODE OUT UNTIL THE CODE FOR ADDING AN EMPTY MAP WHEN SUBMITTING A NEW LISTING IS ADDED
                /////////////////////////////////////////////////////////////////////////////////////////////////
                
                let review = document.get("reviews") as! NSDictionary

                //currently this gives a fatal error when a house w/ no reviews is clicked,
                //but we should make sure that every listing comes with an NSDictionary (aka review map)
                //when created.

                //Retreiving values from map of maps (reviews)
                //Also! make sure all fields in map are present and valid to present fatal errors. (like comments, rating, isAnon, etc all must be present)

                var reviewString = "" // current method of displaying reviews: a long chain of text

                for (reviewer, reviewMap) in review {
                    let reviewer = reviewer as! String
                    print("reviewer: " + reviewer)

                    let reviewMap = reviewMap as! NSDictionary

                    if reviewMap.count == 0 { // temporary fix. doesn't fix if some fields are missing, I think.
                        reviewString = "No review information for " + reviewer
                        break
                    }

                    let comments = reviewMap.value(forKey: "comments") as! String
                    let rating = reviewMap.value(forKey: "rating") as! Float
                    self.AverageRating = self.AverageRating + Double(rating)
                    self.countReviews = self.countReviews + 1
                    let isAnonymous = reviewMap.value(forKey: "isAnonymous") as! Bool
                    let isEdited = reviewMap.value(forKey: "isEdited") as! Bool
                    let willLiveAgain = reviewMap.value(forKey: "willLiveAgain") as! Bool

                    print("comments: " + comments)
                    print("rating: " + String(rating))
                    print("isAnonymous: " + String(isAnonymous))
                    print("isEdited: " + String(isEdited))
                    print("willLiveAgain: " + String(willLiveAgain))

                    print("\n")

                    if isAnonymous == false {
                        reviewString = reviewString + "Reviewer: " + String(reviewer) + "\n"
                    }
                    reviewString = reviewString + "Rating: " + String(format: "%.1f",rating) + "\n"
                    reviewString = reviewString + "Comments: \n" + comments + "\n"
                    reviewString = reviewString + "Would live again? " + (willLiveAgain ? "Yes" : "No")
                    reviewString = reviewString + "\n\n"
                    }

                if reviewString == "" { reviewString = "There are no reviews." }
                self.reviewText.text = reviewString
                
                /////////////////////////////////////////////////////////////////////////////////////////////////
                //END COMMENT BLOCK

                self.label.text = (address as! String) // label for address
                self.label2.text = (landlordName as! String) // label for landlord
                
                if(rent != nil){
                    self.label3.text = String(format: "%@", rent as! CVarArg) // label for rent
                }
                else {
                    self.label3.text = "No Rent Information" // case of nothing
                }

                //self.mk = address as! String
            }
            else {
                print("Document does not exist")
            }
            if (self.countReviews != 0) {
            let avgrate = (self.AverageRating/self.countReviews)
            self.avgRating.text = String(format: "%.1f", avgrate)
            }
        }
 
//        let docRef = db.collection("listings").document("house")
//
//        docRef.getDocument { (document, error) in
//            if let rent = document.flatMap({
//                $0.data().flatMap({ (data) in
//                    return rent (dictionary: data)
//                })
//            }) {
//                print("City: \(city)")
//            } else {
//                print("Document does not exist")
//            }
//        }


    }
    var info:String = ""
    var Em:String = ""
    
    @IBAction func reviewListing(_ sender: UIButton) {
        let user = Auth.auth().currentUser
        if let user = user {
            // The user's ID, unique to the Firebase project.
            // Do NOT use this value to authenticate with your backend server,
            // if you have one. Use getTokenWithCompletion:completion: instead.
            let email = user.email
            Em = email!
            // ...
            
        }
        
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
                }
                
                if (emailExists) {
                    let alert = UIAlertController(title: "Careful!", message: "You have already written reviews before! New post will overwrite!", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                    
                }
                
                
            }
        }
        
        
    }
    
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
