//
//  ReportAdminViewController.swift
//  Reviewing off campus housing
//
//  Created by Silin Chen on 4/23/19.
//  Copyright © 2019 housing. All rights reserved.
//

import UIKit
import Firebase

public class ReportState {
    public var arr:[String] = []
    public var add:[String] = []
    public var row:Int = 0
    public var info:String = ""
    public static let shared = ReportState()
}

class ReportAdminViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var reportTable: UITableView!
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        showReports()
    }
    
    func showReports(){
        ReportState.shared.arr = []
        db.collection("Reports").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            }
            else {
                for document in querySnapshot!.documents {
                    //print("\(document.documentID) => \(document.data())")
                    ReportState.shared.arr.append("\(document.documentID) => \(document.data())")
                    ReportState.shared.add.append("\(document.documentID)")
                }
                // this line of code is critical! it makes sure the table view updates.
                self.reportTable.reloadData()
            }
        }
        
        
    } // end showReviews
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ReportState.shared.arr.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ReportState.shared.row = indexPath.row
        ReportState.shared.info = ReportState.shared.add[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // WANT TO IMPLEMENT:
        // if there are no reviews, don't display a blank table. rather, display a message "there are currently no reviews for this listing at this time."
        /* https://stackoverflow.com/questions/28532926/if-no-table-view-results-display-no-results-on-screen */
        // (maybe implement: if there are some reviews, but not enough to fit whole section, then table size should only be as big as necessary.)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReportContent", for: indexPath)
        cell.textLabel!.numberOfLines = 0
        cell.textLabel!.lineBreakMode = .byWordWrapping
        cell.textLabel?.textColor = UIColor.white
        cell.textLabel!.font = UIFont.systemFont(ofSize: 12.0, weight: UIFont.Weight.ultraLight)
        
        let text = ReportState.shared.arr[indexPath.row]
        cell.textLabel?.text = text
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor(red: 129.0/255.0, green: 10.0/255.0, blue: 28.0/255.0, alpha: 1.0)
        cell.selectedBackgroundView = bgColorView
        
        return cell
    }
   

}
