//
//  ErrorViewController.swift
//  Weather
//
//  Created by Ovsyankinds on 17/10/2017.
//  Copyright © 2017 Ovsyankinds. All rights reserved.
//

import UIKit
import CoreLocation

class ErrorViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var errorLabel: UILabel!
    
    var locationManager: CLLocationManager!
   
    @IBAction func enableLocation(){
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if(status == CLAuthorizationStatus.authorizedWhenInUse){
            print("autorized")
            //self.performSegue(withIdentifier: "errorViewController", sender: self)
        }else{
            print("Not authoriz")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        self.errorLabel.text! = "Необходимо разрешить определение местоположения"
        
    }

}
