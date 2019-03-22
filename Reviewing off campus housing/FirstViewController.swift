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


class FirstViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        GMSServices.provideAPIKey("AIzaSyAcN8tyZ3brV52PRFzqbhQd5wuWnWgd_MQ")
        GMSPlacesClient.provideAPIKey("AIzaSyAcN8tyZ3brV52PRFzqbhQd5wuWnWgd_MQ")
    
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
                        let address = document.get("address")
                        
                        print(lat,long)
                    
                        print("**********************")
                        print("\(document.documentID) => \(document.data())")
                        
                        let position = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    
                        let marker = GMSMarker(position: position)
                    
                        marker.title = "Place"
                        marker.map = mapView
                        marker.snippet = "Test"
                        
                    }
                }
                    
            }
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

