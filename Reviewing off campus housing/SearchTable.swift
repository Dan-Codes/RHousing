//
//  SearchTable.swift
//  Reviewing off campus housing
//
//  Created by Kevin Fu on 4/23/19.
//  Copyright © 2019 housing. All rights reserved.
//




import UIKit
import Firebase

struct Listing : Comparable { // custom struct to create a Listing object
    static func < (lhs: Listing, rhs: Listing) -> Bool {
        return lhs.name < rhs.name
    }
    
    var name : String = ""
    var numReviews : Int = 0
    var rating : String = ""
    
    var price : String = ""
    var parsedPrice : String = ""
}

public class properties {
    var prop = [Listing]()
    var filterProp = [Listing]()
    
    var row:Int = 0
    public static let shared = properties()
}

class SearchTable: UITableViewController, UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {
    let searchController = UISearchController(searchResultsController: nil)

    @IBOutlet var propTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showProperties()
        
        // Setup the search controller
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search listings"
        searchController.delegate = self
        searchController.searchBar.sizeToFit()
        
        definesPresentationContext = true
        
        self.searchController.searchBar.isTranslucent = false
        self.searchController.searchBar.searchBarStyle = UISearchBar.Style.minimal
        self.searchController.searchBar.barTintColor = UIColor.black
        self.searchController.searchBar.tintColor = UIColor(red: 68.0/255.0, green: 154.0/255.0, blue: 178.0/255.0, alpha: 1.0) //(red: 8.0/255.0, green: 89.0/255.0, blue: 114.0/255.0, alpha: 1.0) //
        
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        searchController.searchBar.sizeToFit()
        self.tableView.tableHeaderView = searchController.searchBar
        
        // set up scope bar
        searchController.searchBar.scopeButtonTitles = ["Default", "Overall Rating", "Rent Price", "No. of Reviews"]
        searchController.searchBar.delegate = self as? UISearchBarDelegate
    
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        // this function gets called when something gets typed into search bar
        
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
        
    }
    
    func searchBarIsEmpty() -> Bool {
        // this function checks if search bar is empty
        
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        // this function updates search bar when scope button changes on tap
        
        if selectedScope == 0       { properties.shared.prop.sort() } // regular built in sort
        else if selectedScope == 1  { properties.shared.prop.sort { Float($0.rating)! > Float($1.rating)! } } // sorts based on rating
        else if selectedScope == 2  { properties.shared.prop.sort { Int($0.parsedPrice)! > Int($1.parsedPrice)! } } // sorts based on parsedPrice
        else                        { properties.shared.prop.sort { ($0.numReviews) > ($1.numReviews) } } // sorts based on numReviews
        
        updateSearchResults(for: searchController)
    }
    
    
    
    func filterContentForSearchText(_ searchText: String, scope: String) {
        // this function filters results according to what is typed in search bar. utilizes filterProp.
        
        properties.shared.filterProp = properties.shared.prop.filter({ (prop : Listing) -> Bool in
            return prop.name.lowercased().contains(searchText.lowercased())
        })
        
        propTable.reloadData()
    }

    
    func showProperties(){
        // this function appends stuff from database to array, and shows it in the table.
        
        db.collection("listings").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                properties.shared.prop = []

                for document in querySnapshot!.documents {
                    var list = Listing()
                    
                    let review = document.get("reviews") as! NSDictionary
                    
                    var totalRating = 0.0 as Float
                    var reviewCount = 0.0 as Float
                    for (_, reviewMap) in review {
                        let reviewMap = reviewMap as! NSDictionary
                    
                        let rating = reviewMap.value(forKey: "rating") as? Float ?? 0.0
                        totalRating += rating
                        reviewCount += 1
                    }
                    
                    let overallRating = totalRating / reviewCount
                    
                    list.name = document.get("address") as? String ?? "No name"
                    list.numReviews = review.count
                    
                    list.price = document.get("rent") as? String ?? "0"
                    if list.price == "" { list.price = "0" } // for debugging purposes
                    
                    list.parsedPrice = self.parsePrice(price: list.price)
                    
                    if reviewCount == 0.0 { list.rating = "0.0" }
                    else                  { list.rating = String(format: "%.1f", overallRating) as String }
                    
                    properties.shared.prop.append(list)
                } // end for

                self.propTable.reloadData()

            } // end else

        } // end getDocuments
        
    } // end showProperties
    
    func parsePrice(price : String) -> String {
        // this function gets a parsed version of the price. if the price was hyphenated, parsedPrice gets the first price before the hyphen.
        // else, parsedPrice would be equal to price.
        
        var parsedPrice = "" as String
        
        for char in price {
            if char != "-" && char != " " {
                parsedPrice += String(char)
            }
            else { break }
        }
        
        return parsedPrice
        
    }

    func isFiltering() -> Bool {
        // this function checks if search bar is filtering
        
        //let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        
        return searchController.isActive && (!searchBarIsEmpty()) // || searchBarScopeIsFiltering
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() && !searchBarIsEmpty() { return properties.shared.filterProp.count }
        return properties.shared.prop.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.textColor = UIColor.white
        cell.textLabel!.font = UIFont.systemFont(ofSize: 20.0, weight: UIFont.Weight.semibold)
        cell.detailTextLabel?.textColor = UIColor.white
        cell.detailTextLabel!.font = UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.ultraLight)
        
        if isFiltering() && !searchBarIsEmpty() {
            cell.textLabel?.text = properties.shared.filterProp[indexPath.row].name
            cell.detailTextLabel?.text = "Number of Reviews: " + String(properties.shared.filterProp[indexPath.row].numReviews) + "  |  Rating: " + String(properties.shared.filterProp[indexPath.row].rating) + "  |  Price: " + properties.shared.filterProp[indexPath.row].price
            return cell
        }
        
        // else...
        cell.textLabel?.text = properties.shared.prop[indexPath.row].name
        cell.detailTextLabel?.text = "Number of Reviews: " + String(properties.shared.prop[indexPath.row].numReviews) + "  |  Rating: " + String(properties.shared.prop[indexPath.row].rating) + "  |  Price: " + properties.shared.prop[indexPath.row].price
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // resizes table header when search bar's scope buttons are exposed. previously, they would cover
        // the first table cell. now, the first table cell will be visible.
        
        var headerHeight:CGFloat = 0.0
        
        if searchController.isActive { headerHeight = 42.0 }
        else                         { headerHeight = 0.0 }
        
        return headerHeight
    }
 
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //searchController.isActive = false
        // if want to get rid of search results when clicked, uncomment out above line
        
        if !isFiltering() {     //if !properties.shared.isFiltering
            //properties.shared.row = indexPath.row
            self.address = properties.shared.prop[indexPath.row].name
            performSegue(withIdentifier: "searchToDisplay", sender: self)
        }
        else{
            //properties.shared.row = indexPath.row
            self.address = properties.shared.filterProp[indexPath.row].name
            performSegue(withIdentifier: "searchToDisplay", sender: self)
        }
    }
    
    var address:String = ""
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is displayListingViewController
        {
            let vc = segue.destination as? displayListingViewController
            vc?.info = address
        }
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
