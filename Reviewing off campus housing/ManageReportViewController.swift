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
        //Add a listener to database listening to any changes in "Reports" collection
        db.collection("Reports").document(RpState.shared.info)
            .addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return }
                guard document.data() != nil else {
                    print("Document data was empty.")
                    return }
                //Excuete when listener is created and changes detacted
                ReviewState.shared.arr = []
                self.showReports() // where the juicy stuf happens
        }
        
        // Do any additional setup after loading the view.
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPress.minimumPressDuration = 2.0 //long press recognizing duration
        tableView.addGestureRecognizer(longPress)
    } // end of viewDidLoad()
    
    //ability to delete a report by longpressing
    @objc func handleLongPress(sender: UILongPressGestureRecognizer){
        if sender.state == .began {
            let touchPoint = sender.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                // your code here, get the row for the indexPath or do whatever you want
                let alert = UIAlertController(title: "Deleting this report?", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: {(action) in print("Hello")}))
                alert.addAction(UIAlertAction(title: "Confirm", style: .destructive, handler: {(action) in
                    //When "Confirm" is selected, delete reviews both under property and user
                    // !!! Use FieldPath instead of using user email directly !!!
                    // !!! Because there is a dot in user email which will be recognized as dot notation by firestore!!!
                    let docPropertyRef = db.collection("Reports").document(RpState.shared.info)
                    let propertyfp = FieldPath([RpState.shared.reporter[indexPath.row]])

                    docPropertyRef.updateData([propertyfp : FieldValue.delete()])

                    return;
                }))
                self.present(alert, animated: true)
            }
        }
    }
  
    //displays reports
    func showReports(){
        RpState.shared.arr = []
        RpState.shared.reporter = []
        
        let docRef = db.collection("Reports").document(ReportState.shared.info) // read the desired document from Reports database
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                
                for (reporter, reportMap) in document.data()! { // loop through each map in the document
                    let reportMap = reportMap as! NSDictionary
                    let report = reportMap.value(forKey: "Report") as! String
                    
                    var reportString = ""
                    
                    reportString += "\"" + report + "\"\n\n"
                    reportString += "Reported by " + reporter
                    
                    RpState.shared.reporter.append(reporter)
                    RpState.shared.arr.append(reportString) // append whatever you want.
                } //end of for loop
                
            } // end of if statement
            else {
                print("oops")
            }
            
            self.tableView.reloadData()
            
        } // end of get doc
        
        tableView.dataSource = self // not sure if this line is necessary. it seems to work with or without.
        
    } // end of showReports()
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return arr.shared.reviewArr.count
        return RpState.shared.arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Setup cells
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReportContent", for: indexPath)
        cell.textLabel!.numberOfLines = 0
        cell.textLabel!.lineBreakMode = .byWordWrapping
        cell.textLabel?.textColor = UIColor.white
        cell.textLabel!.font = UIFont.systemFont(ofSize: 12.0, weight: UIFont.Weight.ultraLight)
        let text = RpState.shared.arr[indexPath.row]
        cell.textLabel?.text = text
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor(red: 129.0/255.0, green: 10.0/255.0, blue: 28.0/255.0, alpha: 1.0)
        cell.selectedBackgroundView = bgColorView
        
        return cell
    }
} //end of ManageReportViewController
