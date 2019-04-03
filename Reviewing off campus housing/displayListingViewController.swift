//
//  displayListingViewController.swift
//  Reviewing off campus housing
//
//  Created by Daniel Li on 4/2/19.
//  Copyright © 2019 housing. All rights reserved.
//

import UIKit

class displayListingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("displayu")
        print(info)
        
        
        let docRef = db.collection("listings").document("house")

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
                let address = document.get("address") ?? ""
                let rent = (document.get("rent"))
                let landlordName = document.get("landlordName")
                let review = document.get("reviews") ?? ""
                print(review)
                print(address)
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
    
    var info:String = ""

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
