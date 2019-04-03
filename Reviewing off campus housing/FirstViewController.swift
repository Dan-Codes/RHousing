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
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        GMSServices.provideAPIKey("AIzaSyAcN8tyZ3brV52PRFzqbhQd5wuWnWgd_MQ")
        GMSPlacesClient.provideAPIKey("AIzaSyAcN8tyZ3brV52PRFzqbhQd5wuWnWgd_MQ")
    
        
        printPin()
    }
    
    
    func printPin(){
        let camera = GMSCameraPosition.camera(withLatitude: 43.038710, longitude: -76.134265, zoom: 15)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        view = mapView
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
                        
                        print(lat,long)
                        
                        print("**********************")
                        print("\(document.documentID) => \(document.data())")
                        
                        let position = CLLocationCoordinate2D(latitude: lat, longitude: long)
                        
                        let marker = GMSMarker(position: position)
                        
                        marker.title = "\(String(describing: address))"
                        marker.map = mapView
                        marker.snippet = "\(document.get("address") ?? "")"
                        mapView.delegate=self
                    }
                }
                
            }
        }
        
    }
    
    var mkTitle:String? = nil
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        print("test")
        performSegue(withIdentifier: "displayListing" , sender: self)
        print(marker.title ?? "No longer valid!")
        
        mkTitle = marker.title
        //addrsId = marker.title
    }
    
    override func prepare (for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "displayListing") {
            let svc = segue.destination as! displayListingViewController
            svc.info = "NO"
        }
    }

    @IBAction func logOut(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            performSegue(withIdentifier: "logOut", sender: self)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    

}

