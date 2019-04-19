//
//  ThirdViewController.swift
//  Reviewing off campus housing
//
//  Created by Silin Chen on 3/20/19.
//  Copyright © 2019 housing. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
import FirebaseUI
import FirebaseStorage
public class ThirdState {
    public var str:String = ""
    public var landlordName:String = ""
    public var costOfRent:String = ""
    public var isAdded = false
    public static let shared = ThirdState()
}
class ThirdViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var varLat:Double = 0
    var varLong:Double = 0
    //var didAdd:Bool = false
    
    
    let myPickerData = [String](arrayLiteral: "AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "DC", "FL", "GA",
                                "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD", "MA", "MI", "MN",
                                "MS", "MO", "MT", "NE", "NV", "NH", "NJ", "NM", "NY", "NC", "ND", "OH", "OK",
                                "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let thePicker = UIPickerView()
        thePicker.delegate = self
        state.inputView = thePicker
        
        adrs1.delegate = self
        adrs2.delegate = self
        city.delegate = self
        zipcd.delegate = self
        
        self.hideKeyboardWhenTap()
    }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            self.view.endEditing(true)
            return true
        }
    
        @IBOutlet weak var address1Label: UILabel!
        @IBOutlet weak var adrs1: UITextField!
        @IBOutlet weak var address2Label: UILabel!
        @IBOutlet weak var adrs2: UITextField!
        @IBOutlet weak var cityLabel: UILabel!
        @IBOutlet weak var city: UITextField!
        @IBOutlet weak var stateLabel: UILabel!
        @IBOutlet weak var state: UITextField!
        @IBOutlet weak var zipCodeLabel: UILabel!
        @IBOutlet weak var zipcd: UITextField!
        @IBOutlet weak var landlordLabel: UILabel!
        @IBOutlet weak var landlord: UITextField!
        @IBOutlet weak var rentCostLabel: UILabel!
        @IBOutlet weak var rentCost: UITextField!
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return myPickerData.count
    }
    
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return myPickerData[row]
    }
    
    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        state.text = myPickerData[row]
    }
    
    func checkDidAdd(lat: Double, long: Double) -> Bool {
        ThirdState.shared.isAdded = false
        db.collection("listings").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    if let geopoint = document.get("geopoint"){
                        let point = geopoint as! GeoPoint
                        print(point)
                        let lat = point.latitude
                        let long = point.longitude
                        if abs(lat - self.varLat) < 0.000001 || abs(long - self.varLong) < 0.000001{
                            ThirdState.shared.isAdded = true
                            print("changed to true")
                            let alert = UIAlertController(title: "Location already added", message: "", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action -> Void in
                            }))
                            self.present(alert, animated: true)
                            break
                        }
                    }
                }
                print("prereturning " + String(ThirdState.shared.isAdded))
                if !ThirdState.shared.isAdded{
                    let adData: [String:Any] = [
                        "address": ThirdState.shared.str,
                        "geopoint": GeoPoint(latitude: self.varLat, longitude: self.varLong),
                        "property": true,
                        "reviews": ([:]),
                        "landlordName": ThirdState.shared.landlordName,
                        "rent": ThirdState.shared.costOfRent
                    ]
                    //print("this is database Check")
                    //print(check)
                    
                    db.collection("listings").document(ThirdState.shared.str).setData(adData) { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                        } else {
                            print("Document successfully written!")
                            self.performSegue(withIdentifier: "thirdtoTab", sender: self)
                        }
                    }//end of write db
                }
            }
        }
        print("returning " + String(ThirdState.shared.isAdded))
        return ThirdState.shared.isAdded
    }
    
    @IBAction func uploadProperty(_ sender: UIButton) {
        ThirdState.shared.str = adrs1.text! + " " + city.text! + ", " + state.text! + " " + zipcd.text!
        ThirdState.shared.landlordName = landlord.text!
        ThirdState.shared.costOfRent = rentCost.text!
        //print(landlordName)
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(ThirdState.shared.str) {
            placemarks, error in
            let placemark = placemarks?.first
            let lat = placemark?.location?.coordinate.latitude
            let lon = placemark?.location?.coordinate.longitude
            self.varLat = (lat)!
            self.varLong = (lon)!
            AppState.shared.long = lon!
            AppState.shared.lat = lat!
            print("Lat: \(lat), Lon: \(lon)")
        }
            if !self.checkDidAdd(lat: self.varLat, long: self.varLong) {
                print("DONE")
                //print(check)
        }
    }
}
