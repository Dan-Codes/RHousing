//
//  SearchTable.swift
//  Reviewing off campus housing
//
//  Created by Kevin Fu on 4/23/19.
//  Copyright © 2019 housing. All rights reserved.
//


import UIKit
import Firebase

struct Listing : Comparable {
    // custom struct to create a Listing object
    
    static func < (lhs: Listing, rhs: Listing) -> Bool {
        return lhs.name < rhs.name
    }
    
    var name : String = ""
    var numReviews : Int = 0
    var rating : String = ""
    
    var price : String = ""
    var parsedPrice : String = ""
}

//global variables
public class properties {
    // global arrays
    
    var prop = [Listing]()
    var filterProp = [Listing]()
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
        searchController.searchBar.placeholder = "Search for a property.."
        searchController.delegate = self
        searchController.searchBar.sizeToFit()
        
        definesPresentationContext = true
        
        searchController.searchBar.isTranslucent = false
        searchController.searchBar.searchBarStyle = UISearchBar.Style.prominent
        searchController.searchBar.barTintColor = UIColor.black
        searchController.searchBar.tintColor = UIColor(red: 8.0/255.0, green: 89.0/255.0, blue: 114.0/255.0, alpha: 1.0)
        
        //UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        searchController.searchBar.sizeToFit()
        self.tableView.tableHeaderView = searchController.searchBar
        
        // set up scope bar
        searchController.searchBar.scopeButtonTitles = ["Default", "Overall Rating", "Rent Price", "No. of Reviews"]
        searchController.searchBar.delegate = self
    
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

                for document in querySnapshot!.documents { // go through database, add Listing objects to array.
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
        return searchController.isActive && (!searchBarIsEmpty())
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // makes proper number of rows in table view based on count of array
        
        if isFiltering() && !searchBarIsEmpty() { return properties.shared.filterProp.count }
        return properties.shared.prop.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // puts stuff into table cells (depending on if isFiltering or not)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.textColor = UIColor(red: 68.0/255.0, green: 154.0/255.0, blue: 178.0/255.0, alpha: 1.0)
        cell.textLabel!.font = UIFont.systemFont(ofSize: 20.0, weight: UIFont.Weight.semibold)
        
        cell.detailTextLabel?.textColor = UIColor.white
        cell.detailTextLabel!.font = UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.ultraLight)
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor(red: 8.0/255.0, green: 89.0/255.0, blue: 114.0/255.0, alpha: 1.0)
        cell.selectedBackgroundView = bgColorView
        
        if isFiltering() && !searchBarIsEmpty() {
            cell.textLabel?.text = properties.shared.filterProp[indexPath.row].name
            cell.detailTextLabel?.text = "Reviews: " + String(properties.shared.filterProp[indexPath.row].numReviews) + "  |  Rating: " + String(properties.shared.filterProp[indexPath.row].rating) + "  |  Price: $" + properties.shared.filterProp[indexPath.row].price
            return cell
        }
        
        // else...
        cell.textLabel?.text = properties.shared.prop[indexPath.row].name
        cell.detailTextLabel?.text = "Reviews: " + String(properties.shared.prop[indexPath.row].numReviews) + "  |  Rating: " + String(properties.shared.prop[indexPath.row].rating) + "  |  Price: $" + properties.shared.prop[indexPath.row].price
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // resizes table header when search bar's scope buttons are exposed. previously, they would cover
        // the first table cell. now, the first table cell will be visible.
        
        var headerHeight:CGFloat = 0.0

        if searchController.isActive { headerHeight = 46.0 }
        else                         { headerHeight = 0.0 }
        
        return headerHeight
    }
 
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        // makes header of table view black
        
        let header = view as! UITableViewHeaderFooterView
        header.backgroundView?.backgroundColor = .black
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // function to segue to displayListingView
        
        //searchController.isActive = false
        // if want to get rid of search results when clicked, uncomment out above line
        
        if !isFiltering() {
            self.address = properties.shared.prop[indexPath.row].name
            performSegue(withIdentifier: "searchToDisplay", sender: self)
        }
        else {
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

} //end of SearchTable class
