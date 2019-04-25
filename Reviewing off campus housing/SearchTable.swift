//
//  SearchTable.swift
//  Reviewing off campus housing
//
//  Created by Kevin Fu on 4/23/19.
//  Copyright © 2019 housing. All rights reserved.
//

import UIKit
import Firebase

public class properties {
    var prop:[String] = []
    var filterProp:[String] = []
    public static let shared = properties()
}

class SearchTable: UITableViewController, UISearchResultsUpdating {
    let searchController = UISearchController(searchResultsController: nil)
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
    

    @IBOutlet var propTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showProperties()
        
        // Setup the search controller
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search listings"
        
        //navigationItem.searchController = searchController
        definesPresentationContext = true
        
        searchController.searchBar.sizeToFit()
        self.tableView.tableHeaderView = searchController.searchBar
        
        // set up scope bar
        searchController.searchBar.scopeButtonTitles = ["test 1", "test 2", "test 3", "test 4"]
        searchController.searchBar.delegate = self as? UISearchBarDelegate
        
        // setup the search footer
        // tableView.tableFooterView = searchFooter
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        // properties.shared.prop.filter()
        print("hello")
        properties.shared.filterProp = properties.shared.prop.filter({ (prop : String) -> Bool in
            return prop.lowercased().contains(searchText.lowercased()) 
        })
        
        propTable.reloadData()
    }
    
    func showProperties(){
        
        db.collection("listings").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                properties.shared.prop = []
                
                for document in querySnapshot!.documents {
                    //print("\(document.documentID) => \(document.data())")
                    //print("\(document.documentID)")
                    
                    properties.shared.prop.append(document.documentID)
                } // end for
                
                self.propTable.reloadData()
                
            } // end else
            
        } // end getDocuments
        
    } // end showProperties

    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
    
    // MARK: - Table view data source
    

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //print(properties.shared.prop.count)
        if isFiltering() {
            print("test2")
            return properties.shared.filterProp.count
        }
        
        return properties.shared.prop.count
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if isFiltering() {
            print("test")
            cell.textLabel?.text = properties.shared.filterProp[indexPath.row]
            cell.detailTextLabel?.text = "detailed text here"
            return cell
        }
        
        // else...
        cell.textLabel?.text = properties.shared.prop[indexPath.row]
        cell.detailTextLabel?.text = "detailed text here"
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
