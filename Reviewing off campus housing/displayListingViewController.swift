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

class displayListingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    // adding a comment here from kevin
    
    var AverageRating:Double = 0
    var countReviews:Double = 0
    
    var reviewArr:[String] = ["sample"]
    let testArr = ["this is a long string that i am typing to see if the string goes to the second line yay", "ghi"]
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var AddressLabel: UILabel!
    @IBOutlet weak var landlordLabel: UILabel!
    @IBOutlet weak var rentPriceLabel: UILabel!
    @IBOutlet weak var avgRating: UILabel!
    
    // reviewTable connection
    @IBOutlet weak var reviewTable: UITableView!
    
    
    @IBOutlet weak var scrollReview: UIScrollView!
    @IBOutlet weak var reviewText: UITextView!
    
    @IBAction func unwindToDsiplay(segue: UIStoryboardSegue) {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        //AddressLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        //landlordLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        //rentPriceLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        //avgRating.font = UIFont.boldSystemFont(ofSize: 16.0)
        
        //scrollReview.contentLayoutGuide.bottomAnchor.constraint(equalTo: label.bottomAnchor).isActive = true

        // Do any additional setup after loading the view.
        
        print("initial string?")
        
        //showReviews()
        
//        db.collection("listings").document(info)
//            .addSnapshotListener { documentSnapshot, error in
//                guard let document = documentSnapshot else {
//                    print("Error fetching document: \(error!)")
//                    return
//                }
//                guard let data = document.data() else {
//                    print("Document data was empty.")
//                    return
//                }
//                //print("Current data: \(data)")
//                self.showReviews()
//        }
        
//        print("sleeping 2")
//        sleep(2)
        
        let docRef = db.collection("listings").document(info)
        docRef.getDocument { (document, error) in
            
            if let document = document, document.exists {
                // i got rid of the majority of the code here because i wanted to test to see if it was the code in this
                // section that was the problem or just the fact that we're utilizing getDocument. it turns out that
                // getDocument is the culprit. it runs after the print statement print("sandwich"), regardless of code that is inside.
                // the original code is at the bottom of this file. -kevin 4/18/2019
 
                print("test print here")
                var reviewString = "test" // current method of displaying reviews: a long chain of text
                self.reviewArr.append(reviewString)
                
                print("call from showReviews")
                print(self.reviewArr)
            }
                
            else {
                print("Document does not exist")
            }
            
        }

        print("call from viewDidLoad")
        //print(self.reviewArr)
        print(reviewArr)
        print("sandwich")
        
        //reviewTable.reloadData()

    } //  end of viewDidLoad
    
    var info:String = ""
    var Em:String = ""
    
    //func showReviews(){
        
    //}
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("count:" + String(self.reviewArr.count))
        print("reviewArr:")
        print(self.reviewArr)
        return reviewArr.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("HELLO")
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        let text = reviewArr[indexPath.row]
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
            if let err = err {
                print("Error removing document: \(err)")
            } else {
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
                    let alert = UIAlertController(title: "Warning", message: "You have already rated this property before. If you post another review, your previous review will be overwritten.", preferredStyle: .alert)
                    
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




/////////////
//// algorithm for database
//func showReviews(){
//    let docRef = db.collection("listings").document(info)
//
//    docRef.getDocument { (document, error) in
//        if let document = document, document.exists {
//
//            //let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
//            //print("Document data: \(dataDescription)")
//
//            let address = document.get("address") ?? ""
//            let rent = (document.get("rent"))
//            let landlordName = document.get("landlordName") ?? "Leasing manager unavailable"
//
//            //COMMENT THIS SECTION OF CODE OUT UNTIL THE CODE FOR ADDING AN EMPTY MAP WHEN SUBMITTING A NEW LISTING IS ADDED
//            /////////////////////////////////////////////////////////////////////////////////////////////////
//
//            let review = document.get("reviews") as! NSDictionary
//
//            //currently this gives a fatal error when a house w/ no reviews is clicked,
//            //but we should make sure that every listing comes with an NSDictionary (aka review map)
//            //when created.
//
//            //Retreiving values from map of maps (reviews)
//            //Also! make sure all fields in map are present and valid to present fatal errors. (like comments, rating, isAnon, etc all must be present)
//
//            var reviewString = "" // current method of displaying reviews: a long chain of text
//
//            for (reviewer, reviewMap) in review {
//                let reviewer = reviewer as! String
//                //print("reviewer: " + reviewer)
//
//                let reviewMap = reviewMap as! NSDictionary
//
//                //if reviewMap.count == 0 { // temporary fix. doesn't fix if some fields are missing, I think.
//                //    reviewString = "No review information for " + reviewer
//                //    break
//                //}
//
//                let comments = reviewMap.value(forKey: "comments") as! String
//                let rating = reviewMap.value(forKey: "rating") as! Float
//                self.AverageRating = self.AverageRating + Double(rating)
//                self.countReviews = self.countReviews + 1
//                let isAnonymous = reviewMap.value(forKey: "isAnonymous") as! Bool
//                let isEdited = reviewMap.value(forKey: "isEdited") as! Bool
//                let willLiveAgain = reviewMap.value(forKey: "willLiveAgain") as! Bool
//
//                print("comments: " + comments)
//                print("rating: " + String(rating))
//                print("isAnonymous: " + String(isAnonymous))
//                print("isEdited: " + String(isEdited))
//                print("willLiveAgain: " + String(willLiveAgain))
//
//                print("\n")
//
//                if isAnonymous == false {
//                    reviewString = reviewString + "Reviewer: " + String(reviewer) + "\n"
//                }
//                reviewString = reviewString + "Rating: " + String(format: "%.1f",rating) + "\n"
//                reviewString = reviewString + "Comments: \n" + comments + "\n"
//                reviewString = reviewString + "Would live again? " + (willLiveAgain ? "Yes" : "No")
//                reviewString = reviewString + "\n\n"
//
//                self.reviewArr.append(reviewString)
//            } // end for loop
//
//            print("test here")
//            print(self.reviewArr)
//
//            print("call from showReviews")
//            print(self.reviewArr)
//
//            print("hi")
//            print(self.reviewArr)
//            reviewTable.dataSource = self
//
//
//            //if reviewString == "" { reviewString = "There are no reviews." }
//            //self.reviewText.text = reviewString
//
//            // IMPORTANT NOTE TO SELF
//            // need to: for each review, put it in an array as its own element.
//            // then, use a tableView, iterate on the array, and show each element as its own cell.
//
//            /////////////////////////////////////////////////////////////////////////////////////////////////
//            //END COMMENT BLOCK
//
//            self.label.text = (address as! String) // label for address
//            self.label2.text = (landlordName as! String) // label for landlord
//
//            //if (rent != nil)  { self.label3.text = String(format: "%@", rent as! CVarArg) } // label for rent
//            //else              { self.label3.text = "No rent information" } // case of nothing
//
//            //self.mk = address as! String
//        } // end if document exists
//
//        else {
//            print("Document does not exist")
//        } // end else
//
//        if (self.countReviews != 0) {
//            let avgrate = (self.AverageRating/self.countReviews)
//            self.avgRating.text = String(format: "%.1f", avgrate) } // end if
//
//    } // end docRef.getDocument
//
//} // end showReviews
//
//
//
