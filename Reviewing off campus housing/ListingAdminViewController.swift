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
    public var add:[String] = []
    public var address:String = ""
    public var row:Int = 0
    public static let shared = AdminState()
}


class UserAdminViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    @IBOutlet weak var PropertyTable: UITableView!
    
    @IBAction func unwindToListingAdmin(segue: UIStoryboardSegue) {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Add a listener to database listening to any changes in "listings" collection
        db.collection("listings").addSnapshotListener { querySnapshot, error in
            guard (querySnapshot?.documents) != nil else {
                    print("Error fetching documents: \(error!)")
                    return
                }
                //Excuete when listener is created and changes detacted
                self.showProperties() // where the juicy stuf happens
        }
        
        
        //The cells can revoginize long press
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPress.minimumPressDuration = 2.0 //long press recognizing duration
        PropertyTable.addGestureRecognizer(longPress)
    }
    
    //objective-C function which handels long press
    @objc func handleLongPress(sender: UILongPressGestureRecognizer){
        if sender.state == .began {
            let touchPoint = sender.location(in: PropertyTable)
            if let indexPath = PropertyTable.indexPathForRow(at: touchPoint) {
                // your code here, get the row for the indexPath or do whatever you want
                let alert = UIAlertController(title: "Are you sure you want to delete this property?", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "No", style: .cancel))
                //When confirm is selected, delete the listing using Firebase functions
                alert.addAction(UIAlertAction(title: "Confirm", style: .destructive, handler: {(action) in
                    db.collection("listings").document(AdminState.shared.add[indexPath.row]).delete() { err in
                        if let err = err {
                            print("Error removing document: \(err)")
                        } else {
                            print("Document successfully removed!")
                            //print(ReviewState.shared.arr)
                        }
                    }
                    
                }))
                //Used to present alert popup
                self.present(alert, animated: true)
            }
        }
    }
    
    //use function to loop through database and fill table cells
    func showProperties(){
        //clear arrays and variable before each function call
        AdminState.shared.arr = []
        AdminState.shared.address = ""
        AdminState.shared.add = []
        
        //
        db.collection("listings").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    //print("\(document.documentID) => \(document.data())")
                    AdminState.shared.arr.append("\(document.documentID) => \(document.data())")
                    let adrs = document.get("address") as? String ?? ""
                    AdminState.shared.add.append(adrs)
                }
                // this line of code is critical! it makes sure the table view updates.
                self.PropertyTable.reloadData()
            }
        }
        
        PropertyTable.dataSource = self // not sure if this line is necessary. it seems to work with or without.
        
    } // end showReviews
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AdminState.shared.arr.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Pass values to next viewController
        AdminState.shared.row = indexPath.row
        ReviewState.shared.info = AdminState.shared.add[AdminState.shared.row]
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Set up cells
        let cell = tableView.dequeueReusableCell(withIdentifier: "PropertyContent", for: indexPath)
        cell.textLabel!.numberOfLines = 0
        cell.textLabel!.lineBreakMode = .byWordWrapping
        cell.textLabel?.textColor = UIColor.white
        cell.textLabel!.font = UIFont.systemFont(ofSize: 12.0, weight: UIFont.Weight.ultraLight)
        let text = AdminState.shared.arr[indexPath.row]
        cell.textLabel?.text = text
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor(red: 129.0/255.0, green: 10.0/255.0, blue: 28.0/255.0, alpha: 1.0)
        cell.selectedBackgroundView = bgColorView
        
        return cell
    }

} //end of class
