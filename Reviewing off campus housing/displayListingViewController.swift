//
//  displayListingViewController.swift
//  Reviewing off campus housing
//
//  Created by Daniel Li on 4/2/19.
//  Copyright © 2019 housing. All rights reserved.
//

import UIKit

class displayListingViewController: UIViewController {

    // adding a comment here from kevin

    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("displayu")
        print(info)
        
        
        let docRef = db.collection("listings").document(info)

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                //print("Document data: \(dataDescription)")
                let address = document.get("address") ?? ""
                let rent = (document.get("rent")) //?? 0
                let landlordName = document.get("landlordName")
                let review = document.get("reviews") ?? ""
                print(review)
                self.label.text = (address as! String)
                //print(address)
                
                self.label2.text = (landlordName as! String)
                //print(landlordName)
                
                //self.label3.text = rent
                
                
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
//

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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
