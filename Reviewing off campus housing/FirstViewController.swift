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

var objgVC = FirstViewController()

class FirstViewController: UIViewController, GMSMapViewDelegate {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        GMSServices.provideAPIKey("AIzaSyAcN8tyZ3brV52PRFzqbhQd5wuWnWgd_MQ")
        GMSPlacesClient.provideAPIKey("AIzaSyAcN8tyZ3brV52PRFzqbhQd5wuWnWgd_MQ")
        //createMapView()
        //darkMode()
    
        
        printPin()
    }
    
    func createMapView(){
        let camera = GMSCameraPosition.camera(withLatitude: 43.038710, longitude: -76.134265, zoom: 15)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        view = mapView
    }
    func printPin(){
        let camera = GMSCameraPosition.camera(withLatitude: 43.038710, longitude: -76.134265, zoom: 15)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        view = mapView
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
        db.collection("listings").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                print("*****")
                for document in querySnapshot!.documents {
                    if let coords = document.get("geopoint"){
                        let point = coords as! GeoPoint
                        let lat = point.latitude
                        let long = point.longitude
                        let address = document.get("address")!
                        
//                        print(lat,long)
//                        
//                        print("**********************")
//                        print("\(document.documentID) => \(document.data())")
                        
                        let position = CLLocationCoordinate2D(latitude: lat, longitude: long)
                        let customRedMarker = UIColor(rgb: 0x820B1D)
                        let marker = GMSMarker(position: position)
                        marker.icon = GMSMarker.markerImage(with: customRedMarker)
                        marker.title = "\(String(describing: address))"
                        marker.map = mapView
                        marker.snippet = "Tap to see more details!"
                        mapView.delegate=self
                    }
                }
                
            }
        }
        
    }
    
    var mk:String? = nil
    
    func darkMode(){
        let camera = GMSCameraPosition.camera(withLatitude: 43.038710, longitude: -76.134265, zoom: 15)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        view = mapView
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
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        print("test")
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
            vc?.info = mk!
        }
    }
    
    @IBAction func logOut(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            performSegue(withIdentifier: "logout2", sender: (Any).self)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
}

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
