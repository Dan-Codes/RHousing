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
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var AddressLabel: UILabel!
    @IBOutlet weak var landlordLabel: UILabel!
    @IBOutlet weak var rentPriceLabel: UILabel!
    @IBOutlet weak var avgRating: UILabel!
    
    @IBOutlet weak var reviewTable: UITableView!
    
    @IBAction func unwindToDsiplay(segue: UIStoryboardSegue) {}
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // don't really need this line of code below?
        // showReviews()
        
        // This is for auto-refresh (after writing a review). Even w/o writing a review, it still runs to show the reviews.
        db.collection("listings").document(info)
            .addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return }
                guard document.data() != nil else {
                    print("Document data was empty.")
                    return }
                
                self.showReviews()
        }
        
    } //  end of viewDidLoad
    
    var info:String = ""
    var Em:String = ""
    
    func showReviews(){
        
        let docRef = db.collection("listings").document(info)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                
                //let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                //print("Document data: \(dataDescription)")
                
                let address = document.get("address") ?? ""
                let landlordName = document.get("landlordName") ?? "Leasing manager unavailable"
                //let rent = (document.get("rent"))
                
                let review = document.get("reviews") as! NSDictionary
                
                //Retreiving values from map of maps (reviews)
                //Also! make sure all fields in map are present and valid to present fatal errors. (like comments, rating, isAnon, etc all must be present)
                
                arr.shared.reviewArr = []
                
                for (reviewer, reviewMap) in review {
                    var reviewString = ""
                    
                    let reviewer = reviewer as! String
                    let reviewMap = reviewMap as! NSDictionary // potential problem if nothing in reviewMap? (like empty review thing)
                    let comments = reviewMap.value(forKey: "comments") as! String
                    let rating = reviewMap.value(forKey: "rating") as! Float
                    let isAnonymous = reviewMap.value(forKey: "isAnonymous") as! Bool
                    let isEdited = reviewMap.value(forKey: "isEdited") as! Bool
                    let willLiveAgain = reviewMap.value(forKey: "willLiveAgain") as! Bool
                    
                    self.AverageRating = self.AverageRating + Double(rating)
                    self.countReviews = self.countReviews + 1
                    
//                    print("reviewer: " + reviewer)
//                    print("comments: " + comments)
//                    print("rating: " + String(rating))
//                    print("isAnonymous: " + String(isAnonymous))
//                    print("isEdited: " + String(isEdited))
//                    print("willLiveAgain: " + String(willLiveAgain))
//                    print("\n")
                    
                    if isAnonymous == false { reviewString = reviewString + "Reviewer: " + String(reviewer) + "\n" }
                    else { reviewString = reviewString + "[This reviewer has made their review anonymous.]\n" }
                    
                    reviewString = reviewString + "Rating: " + String(format: "%.1f",rating) + "\n"
                    reviewString = reviewString + "\nComments: \n" + comments + "\n\n"
                    reviewString = reviewString + "Would live again? " + (willLiveAgain ? "Yes" : "No")
                    
                    if isEdited { reviewString = reviewString + "\n\n[This comment has been edited.]" }
                    
                    arr.shared.reviewArr.append(reviewString) // adding to the array of strings.
                    
                } // end for loop
                
                self.label.text = (address as! String) // label for address
                self.label2.text = (landlordName as! String) // label for landlord
                
                //if (rent != nil)  { self.label3.text = String(format: "%@", rent as! CVarArg) } // label for rent
                //else              { self.label3.text = "No rent information" } // case of nothing
                
            } // end if document exists
                
            else { print("Document does not exist") } // end else
            
            if (self.countReviews != 0) {
                let avgrate = (self.AverageRating/self.countReviews)
                self.avgRating.text = String(format: "%.1f", avgrate)
            } // end if
            
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
        let alert = UIAlertController(title: "Are you sure you want to delete your review of this property?", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: {(action) in print("Hello")}))

        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {(action) in db.collection("listings").document(self.info).delete() { err in
            if let err = err { print("Error removing document: \(err)") }
            else {
                print("Document successfully removed!")
                print(self.Em)
            }

            }}))
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
