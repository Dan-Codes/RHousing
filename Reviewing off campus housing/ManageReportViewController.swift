//
//  ManageReportViewController.swift
//  Reviewing off campus housing
//
//  Created by Silin Chen on 4/24/19.
//  Copyright © 2019 housing. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

public class RpState {
    public var arr:[String] = []
    public var info:String = ""
    public var reporter:[String] = []
    
    public static let shared = RpState()
}

class ManageReportViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        RpState.shared.info = ReportState.shared.info
        db.collection("Reports").document(RpState.shared.info)
            .addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return }
                guard document.data() != nil else {
                    print("Document data was empty.")
                    return }
                ReviewState.shared.arr = []
                self.showReports() // where the juicy stuf happens
        }
        
        // Do any additional setup after loading the view.
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPress.minimumPressDuration = 2.0
        tableView.addGestureRecognizer(longPress)
    }
    
    @objc func handleLongPress(sender: UILongPressGestureRecognizer){
        if sender.state == .began {
            let touchPoint = sender.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                print(indexPath)
                // your code here, get the row for the indexPath or do whatever you want
                let alert = UIAlertController(title: "Deleting this report?", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: {(action) in print("Hello")}))
                alert.addAction(UIAlertAction(title: "Confirm", style: .destructive, handler: {(action) in
                    
                
                    let docPropertyRef = db.collection("Reports").document(RpState.shared.info)
                    let propertyfp = FieldPath([RpState.shared.reporter[indexPath.row]])

                    docPropertyRef.updateData([propertyfp : FieldValue.delete()])

                    return;
                }))
                self.present(alert, animated: true)
            }
        }
    }
    
    func showReports(){
        RpState.shared.arr = []
        
        let docRef = db.collection("Reports").document(ReportState.shared.info) // read the desired document from Reports database
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                
                for (reporter, reportMap) in document.data()! { // loop through each map in the document
                    let reportMap = reportMap as! NSDictionary
                    let report = reportMap.value(forKey: "Report") as! String
                    
                    var reportString = ""
                    
                    reportString += "Reporter: " + reporter + "\n\n"
                    reportString += report + "\n"
                    
                    RpState.shared.reporter.append(reporter)
                    RpState.shared.arr.append(reportString) // append whatever you want.
                }
                
            }
            else {
                print("oops")
            }
            
            self.tableView.reloadData()
            
        }
        
        tableView.dataSource = self // not sure if this line is necessary. it seems to work with or without.
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return arr.shared.reviewArr.count
        return RpState.shared.arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReportContent")
        cell?.textLabel!.numberOfLines = 0
        cell?.textLabel!.lineBreakMode = .byWordWrapping
        cell?.textLabel?.textColor = UIColor.black
        cell?.textLabel!.font = UIFont.systemFont(ofSize: 12.0)
        let text = RpState.shared.arr[indexPath.row]
        cell?.textLabel?.text = text
        
        return cell!
    }
}
