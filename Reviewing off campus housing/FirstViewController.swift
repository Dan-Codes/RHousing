//
//  FirstViewController.swift
//  Reviewing off campus housing
//
//  Created by Silin Chen on 3/1/19.
//  Copyright © 2019 housing. All rights reserved.
//
import UIKit
import Firebase
import GoogleMaps
import GooglePlaces

public class AppState {
    public var lat = 43.038710
    public var long = -76.134265
    public var didAdd = false
    public var darkMode = false
    public var open = false
    public static let shared = AppState()
}

var objgVC = FirstViewController()
class FirstViewController: UIViewController, GMSMapViewDelegate {
    @IBAction func searchButton(_ sender: UIButton) {
        performSegue(withIdentifier: "search", sender: self)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var locationManager = CLLocationManager()
    //var resultsViewController: GMSAutocompleteResultsViewController? // GMSAutocompleteResultsViewController provides an interface that displays place autocomplete predictions in a table view.
    //var searchController: UISearchController?
    
    ///let searchController = UISearchController(searchResultsController: nil)
    
    var resultView: UITextView?
    var camera:GMSCameraPosition!
    var placesClient: GMSPlacesClient!
    var mapView: GMSMapView!
    var emailID:String = ""
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //print(emailID)
        GMSServices.provideAPIKey("AIzaSyAcN8tyZ3brV52PRFzqbhQd5wuWnWgd_MQ")
        GMSPlacesClient.provideAPIKey("AIzaSyAcN8tyZ3brV52PRFzqbhQd5wuWnWgd_MQ")
        //createMapView()
        //darkMode()
    
        //resultsViewController = GMSAutocompleteResultsViewController()
        //resultsViewController?.delegate = self as? GMSAutocompleteResultsViewControllerDelegate
        
       // searchController = UISearchController(searchResultsController: resultsViewController)
        //searchController?.searchResultsUpdater = resultsViewController
        
        // https://stackoverflow.com/questions/46832576/display-table-view-when-searchbar-from-searchcontroller-begin-edited-swift
        // -kevin: look into this.
        
        // Put the search bar in the navigation bar.
        //searchController?.searchBar.sizeToFit()
        //navigationItem.titleView = searchController?.searchBar
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        //definesPresentationContext = true
        
        // Prevent the navigation bar from being hidden when searching.
        //searchController?.hidesNavigationBarDuringPresentation = false
        
        let user = Auth.auth().currentUser
        if let user = user {
            // The user's ID, unique to the Firebase project.
            // Do NOT use this value to authenticate with your backend server,
            // if you have one. Use getTokenWithCompletion:completion: instead.
            let email = user.email
            emailID = email!
        }
        let docRef = db.collection("Users").document(emailID)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                //print("Document data: \(dataDescription)")
                let darkModeBool = document.get("DarkMode") as? Bool ?? false
                SecState.shared.darkMode = darkModeBool
                AppState.shared.darkMode = darkModeBool
                if (AppState.shared.darkMode){
                    self.printPin()
                }
            } else {
                print("Document does not exist")
            }
        }
         //Add a new document in collection "cities"
        db.collection("Users").document(emailID)
            .addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                guard let data = document.data() else {
                    print("Document data was empty.")
                    return
                }
                print("Dark mode changed")
                self.printPin()
        }
        
//        db.collection("listings").whereField("property", isEqualTo: true)
//            .addSnapshotListener { querySnapshot, error in
//                guard let documents = querySnapshot?.documents else {
//                    print("Error fetching documents: \(error!)")
//                    return
//                }
//                print("Listener detected changes")
//                self.printPin()
//        }
        //printPin()
       
    }
    
    //literates through the database to place pinpoints on the google maps on the listings properties
    func printPin(){
        camera = GMSCameraPosition.camera(withLatitude: AppState.shared.lat, longitude: AppState.shared.long, zoom: 15)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        view = mapView
        if AppState.shared.darkMode{
            print("darkmode is " + String(AppState.shared.darkMode))
        do {
            // Set the map style by passing the URL of the local file.
            if let styleURL = Bundle.main.url(forResource: "dark", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
        }
        db.collection("listings").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                print("*****")
                for document in querySnapshot!.documents {
                    if let coords = document.get("geopoint"){
                        let point = coords as? GeoPoint ?? GeoPoint.init(latitude: 0.0, longitude: 0.0)
                        let lat = point.latitude
                        let long = point.longitude
                        let address = document.get("address") as? String ?? "Address"
                        let mk = address
//                        print(lat,long)
//                        
//                        print("**********************")
//                        print("\(document.documentID) => \(document.data())")
                        
                        

//                        // parsing first part of the address
                        var count = 0
                        var address1:String = ""

                        let position = CLLocationCoordinate2D(latitude: lat, longitude: long)
                        //let customRedMarker = UIColor(rgb: 0x085972)  // comment out if using custom icon
                        let marker = GMSMarker(position: position)
                        marker.icon = UIImage(named: "cribbhouse") //GMSMarker.markerImage(with: customRedMarker)
                        marker.setIconSize(scaledToSize: .init(width: 40, height: 40))
                        for str in address.split(separator: " "){
                            if (str.last == ",") { break }
                            address1.append(contentsOf: str)
                            address1.append(contentsOf: " ")
                            count+=1 }
                        marker.title = address1
                        marker.accessibilityHint = address
                        marker.infoWindowAnchor = CGPoint(x: 0.5, y: 0.5)
                        marker.map = self.mapView
                        marker.snippet = "Tap to see reviews!"
                        self.mapView.delegate=self
                        if AppState.shared.open && (abs(lat - ThirdState.shared.varLat) < 0.000001 || abs(long - ThirdState.shared.varLong) < 0.000001){
                            self.mapView.selectedMarker = marker
                            AppState.shared.open = false
                        }
                    }
                } //end of for loop
                
            } //end of else
        } //end of db
        
    } //end of printPin()
    
    var mk:String? = nil
    var varAdd:String = ""
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        // print("test")
        varAdd = marker.accessibilityHint!
        mk = marker.title
        performSegue(withIdentifier: "displayListing" , sender: self)
        print(marker.title ?? "No longer valid!")
        
        //addrsId = marker.title
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is displayListingViewController
        {
            let vc = segue.destination as? displayListingViewController
            vc?.info = varAdd
            let vc2 = segue.destination as? SecondViewController
            vc2?.email = emailID
        }
    }
    
    
    
    
} //end of FirstViewController class

// for custom pin/marker icon
extension GMSMarker {
    func setIconSize(scaledToSize newSize: CGSize) {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        icon?.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        icon = newImage
    }
}


//Extension to quickly change the color of things in the storyboard
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}

