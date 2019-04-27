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
import SmartystreetsSDK
public class ThirdState {
    public var str:String = ""
    public var landlordName:String = ""
    public var costOfRent:String = ""
    public var isAdded = false
    public var varLat = 0.0
    public var varLong = 0.0
    public static let shared = ThirdState()
}

class ThirdViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    var emailID:String = ""
    
    
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
    
    func isValidRent(rentCost : String) -> Bool {
        let checkRent = "[0-9]+[-]*[0-9]*"
        
        let testRent = NSPredicate(format:"SELF MATCHES ", checkRent)
        
        print("********************************************** IS VALID RENT")
        print(testRent.evaluate(with: rentCost))
        
        return testRent.evaluate(with: rentCost)
    }
    
    
    func run(address1: String, city: String, state: String) -> String {
//        let mobile = SSSharedCredentials(id: "3418379215808600", hostname: "Cribb")
//        let client = SSClientBuilder(signer: mobile).buildUsStreetApiClient()
                let client = SSClientBuilder(authId: "e364ec93-0e7e-2f4c-8b91-edc5c6168c98",
                                                    authToken: "uMFMctU3tpuT7sJ2bY64").buildUsStreetApiClient()
        
        let lookup = SSUSStreetLookup()
        lookup.street = address1
        lookup.city = city
        lookup.state = state
        
        do {
            try client?.send(lookup)
        } catch let error as NSError {
            print(String(format: "Domain: %@", error.domain))
            print(String(format: "Error Code: %i", error.code))
            print(String(format: "Description: %@", error.localizedDescription))
            return "Error sending request"
        }
        
        let results = lookup.result
        var output = String()
        
        if results?.count == 0 {
            output += "Error. Address is not valid"
            return output
        }
        
        let candidate: SSUSStreetCandidate = results?[0] as! SSUSStreetCandidate
        
        output += "Address is valid"
//        output += "\nZIP Code: " + candidate.components.zipCode
//        output += "\nCounty: " + candidate.metadata.countyName
//        output += "\nLatitude: " + String(format:"%f", candidate.metadata.latitude)
//        output += "\nLongitude: " + String(format:"%f", candidate.metadata.longitude)
        print("--------------" + output)
        return output;
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
                        if abs(lat - ThirdState.shared.varLat) < 0.000001 && abs(long - ThirdState.shared.varLong) < 0.000001{
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
                let user = Auth.auth().currentUser
                if let user = user {
                    // The user's ID, unique to the Firebase project.
                    // Do NOT use this value to authenticate with your backend server,
                    // if you have one. Use getTokenWithCompletion:completion: instead.
                    let email = user.email
                    self.emailID = email!
                }
                
                
                print("prereturning " + String(ThirdState.shared.isAdded))
                if !ThirdState.shared.isAdded{
                    let adData: [String:Any] = [
                        "address": ThirdState.shared.str,
                        "geopoint": GeoPoint(latitude: ThirdState.shared.varLat, longitude: ThirdState.shared.varLong),
                        "property": true,
                        "reviews": ([:]),
                        "landlordName": ThirdState.shared.landlordName,
                        "rent": ThirdState.shared.costOfRent,
                        "addedby" : String(self.emailID)
                    ]
                    //print("this is database Check")
                    db.collection("listings").document(ThirdState.shared.str).setData(adData) { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                        } else {
                            print("Document successfully written!")
                            AppState.shared.open = true
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
        if adrs1.text!.isEmpty || city.text!.isEmpty || state.text!.isEmpty || zipcd.text!.isEmpty || rentCost.text!.isEmpty  {
            let alert = UIAlertController(title: "Error", message: "You must include proper address fields.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action -> Void in
                return
            }))
            self.present(alert, animated: true)
            return
        }
        print(rentCost.text!.split(separator: "-")[0])
        if Int(zipcd.text!) == nil || zipcd.text!.count != 5{
            let alert = UIAlertController(title: "Error", message: "Zipcode not valid\nEnter a 5 digit zipcode", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action -> Void in
                return
            }))
            self.present(alert, animated: true)
            return
        }
        if Int(rentCost.text!) == nil && rentCost.text!.split(separator: "-").count == 1{
            if rentCost.text!.split(separator: "-").count == 1 {
            let alert = UIAlertController(title: "Error", message: "Rent range must be in this form ie. 900-1000 or $900", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action -> Void in
                return
            }))
            self.present(alert, animated: true)
            return
            }
        }
            if rentCost.text!.split(separator: "-").count == 2 && (Int(rentCost.text!.split(separator: "-")[0]) == nil || Int(rentCost.text!.split(separator: "-")[1]) == nil){
                let alert = UIAlertController(title: "Error", message: "Rent range must be in this form ie. 900-1000 or $900", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action -> Void in
                    return
                }))
                self.present(alert, animated: true)
                return
            }
        ThirdState.shared.landlordName = landlord.text!
        ThirdState.shared.costOfRent = rentCost.text!
        //print(landlordName)
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(ThirdState.shared.str) {
            placemarks, error in
            let placemark = placemarks?.first
            let lat = placemark?.location?.coordinate.latitude
            let lon = placemark?.location?.coordinate.longitude
             print("Lat: \(lat), Lon: \(lon)")
            //if lat == nil || lon == nil{
            if self.run(address1: self.adrs1.text!, city: self.city.text!, state: self.state.text!).first == "E"{
                let alert = UIAlertController(title: "This place does not exist", message: "Please check your input", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action -> Void in
                    return
                }))
                self.present(alert, animated: true)
                return
            }
            ThirdState.shared.varLat = (lat)!
            ThirdState.shared.varLong = (lon)!
            AppState.shared.long = lon!
            AppState.shared.lat = lat!
            
            if !self.checkDidAdd(lat: ThirdState.shared.varLat, long: ThirdState.shared.varLong) {
                print("DONE")
                //print(check)
            }
        }
        
    }
}
