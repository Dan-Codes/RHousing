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
    public static let shared = ReportState()
}

class ReportAdminViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var reportTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        showReports()
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPress.minimumPressDuration = 2.0
        reportTable.addGestureRecognizer(longPress)

    }
    
    @objc func handleLongPress(sender: UILongPressGestureRecognizer){
        if sender.state == .began {
            let touchPoint = sender.location(in: reportTable)
            if let indexPath = reportTable.indexPathForRow(at: touchPoint) {
                // your code here, get the row for the indexPath or do whatever you want
                let alert = UIAlertController(title: "Are you sure you want to delete this report?", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: {(action) in print("Hello")}))
                self.present(alert, animated: true)
                print("DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD")
            }
        }
    }
    
    func showReports(){
        ReportState.shared.arr = []
        db.collection("Reports").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            }
            else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    ReportState.shared.arr.append("\(document.documentID) => \(document.data())")
                }
                // this line of code is critical! it makes sure the table view updates.
                self.reportTable.reloadData()
            }
        }
        
        
    } // end showReviews
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ReportState.shared.arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // WANT TO IMPLEMENT:
        // if there are no reviews, don't display a blank table. rather, display a message "there are currently no reviews for this listing at this time."
        /* https://stackoverflow.com/questions/28532926/if-no-table-view-results-display-no-results-on-screen */
        // (maybe implement: if there are some reviews, but not enough to fit whole section, then table size should only be as big as necessary.)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReportContent")
        cell?.textLabel!.numberOfLines = 0
        cell?.textLabel!.lineBreakMode = .byWordWrapping
        cell?.textLabel!.font = UIFont.systemFont(ofSize: 12.0)
        let text = ReportState.shared.arr[indexPath.row]
        cell?.textLabel?.text = text
        
        return cell!
    }
   

}
