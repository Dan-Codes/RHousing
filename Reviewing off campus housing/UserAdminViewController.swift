//
//  UserAdminViewController.swift
//  Reviewing off campus housing
//
//  Created by Silin Chen on 4/23/19.
//  Copyright © 2019 housing. All rights reserved.
//

import UIKit
import Firebase

public class AdminState {
    public var arr:[String] = []
    public static let shared = AdminState()
}
class UserAdminViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var PropertyTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
showReviews()
        
    }
    
    func showReviews(){
        AdminState.shared.arr = []
        db.collection("listings").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    AdminState.shared.arr.append("\(document.documentID) => \(document.data())")
                }
                // this line of code is critical! it makes sure the table view updates.
                self.PropertyTable.reloadData()
            }
        }
    
        
        
                

        
            
        
            
     
        
        PropertyTable.dataSource = self // not sure if this line is necessary. it seems to work with or without.
        
    } // end showReviews
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return arr.shared.reviewArr.count
        return AdminState.shared.arr.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // WANT TO IMPLEMENT:
        // if there are no reviews, don't display a blank table. rather, display a message "there are currently no reviews for this listing at this time."
        /* https://stackoverflow.com/questions/28532926/if-no-table-view-results-display-no-results-on-screen */
        // (maybe implement: if there are some reviews, but not enough to fit whole section, then table size should only be as big as necessary.)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PropertyContent")
//        cell?.textLabel!.numberOfLines = 0
//        cell?.textLabel!.lineBreakMode = .byWordWrapping
//        cell?.textLabel!.font = UIFont.systemFont(ofSize: 14.0)
//        cell?.textLabel?.textColor = UIColor.white
        let text = AdminState.shared.arr[indexPath.row]
        cell?.textLabel?.text = text
        
        return cell!
    }


}
