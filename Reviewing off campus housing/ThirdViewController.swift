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

class ThirdViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var varLat:Double = 0
    var varLong:Double = 0
    
    
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
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
//    {
//        if segue.identifier == "ThirdtoTab" {
//        let vc = segue.destination as? FirstViewController
//        vc?.lat = varLat
//        let vc2 = segue.destination as? FirstViewController
//        vc2?.lat = varLong
//        }
//    }
    
    
    @IBAction func uploadProperty(_ sender: UIButton) {
        let str = adrs1.text! + " " + city.text! + ", " + state.text! + " " + zipcd.text!
        let landlordName = landlord.text!
        let costOfRent = rentCost.text!
        print(landlordName)
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(str) {
            placemarks, error in
            let placemark = placemarks?.first
            let lat = placemark?.location?.coordinate.latitude
            let lon = placemark?.location?.coordinate.longitude
            self.varLat = (lat)!
            self.varLong = (lon)!
            latlong().long = lon!
            latlong().lat = lat!
            print("Lat: \(lat), Lon: \(lon)")
            
            
            let adData: [String:Any] = [
                "address": str,
                "geopoint": GeoPoint(latitude: lat!, longitude: lon!),
                "reviews": ([:]),
                "landlordName": landlordName,
                "rent": costOfRent
            ]
            
            db.collection("listings").document(str).setData(adData) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                    self.performSegue(withIdentifier: "thirdtoTab", sender: self)
                    
                }
            }

        }
    /*
    // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    }
}
