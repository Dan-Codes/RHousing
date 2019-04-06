//
//  displayListingViewController.swift
//  Reviewing off campus housing
//
//  Created by Daniel Li on 4/2/19.
//  Copyright © 2019 housing. All rights reserved.
//

import UIKit

class displayListingViewController: UIViewController { // , UITableViewDataSource, UITableViewDelegate

    // adding a comment here from kevin
    
    
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var AddressLabel: UILabel!
    @IBOutlet weak var landlordLabel: UILabel!
    @IBOutlet weak var rentPriceLabel: UILabel!
    
    
    //@IBOutlet weak var reviewTable: UITableView!
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AddressLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        landlordLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        rentPriceLabel.font = UIFont.boldSystemFont(ofSize: 16.0)

        // Do any additional setup after loading the view.
        //print("displayu")
        //print(info)


        let docRef = db.collection("listings").document(info)

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {

                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                //print("Document data: \(dataDescription)")

                let address = document.get("address") ?? ""
                let rent = (document.get("rent"))
                let landlordName = document.get("landlordName") ?? ""
                //let review = document.get("reviews") as! NSDictionary //NSMapTable<AnyObject, AnyObject>
                // currently this gives a fatal error when a house w/ no reviews is clicked,
                // but we should make sure that every listing comes with an NSDictionary (aka review map)
                // when created.


                //for (key,val) in review {
                //    print(key)
                //    print("\n\n")
                //    let newVal = val as! NSDictionary
                //    for (key2, val2) in newVal {
                //        print(key2)
                //        print(val2)
                //    }
                //}


                // Retreiving values from map of maps (reviews)

                // make sure all fields in map are present and valid to present fatal errors.

//                for (reviewer, reviewMap) in review {
//                    let reviewer = reviewer as! String
//                    print("reviewer: " + reviewer)
//
//                    let reviewMap = reviewMap as! NSDictionary
//                    let comments = reviewMap.value(forKey: "comments") as! String
//                    let rating = reviewMap.value(forKey: "rating") as! Int
//                    let isAnonymous = reviewMap.value(forKey: "isAnonymous") as! Bool
//                    let isEdited = reviewMap.value(forKey: "isEdited") as! Bool
//                    let willLiveAgain = reviewMap.value(forKey: "willLiveAgain") as! Bool
//
//                    print("comments: " + comments)
//                    print("rating: " + String(rating))
//                    print("isAnonymous: " + String(isAnonymous))
//                    print("isEdited: " + String(isEdited))
//                    print("willLiveAgain: " + String(willLiveAgain))
//
//                    print("\n")
//                }



                self.label.text = address as! String
                self.label2.text = landlordName as! String

                // TROUBLE: how to set label with an int? rent is an int, and swift is complaining.
                //let newrent = rent as! String
                //self.label3.text = newrent as! String


                self.mk = address as! String
            } else {
                print("Document does not exist")
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
    var mk:String = ""
    var info:String = ""
    
    @IBAction func reviewListing(_ sender: UIButton) {
        performSegue(withIdentifier: "listingToWrite", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is WriteReviewViewController
        {
            let vc = segue.destination as? WriteReviewViewController
            vc?.info = mk
        }
    }
    
    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 10 // data.count
//
//    }
//
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//        // cell.textLabel?.text = data[indexPath.row]
//        return cell
//    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
